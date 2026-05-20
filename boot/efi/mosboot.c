/*
 * MOS UEFI chain loader — reads EFI/MOS/BOOT.CFG (ASCII) on loaded volume,
 * then LoadImage + StartImage of configured EFI binary.
 *
 * Build: gnu-efi + gcc (see Makefile in this directory).
 */

#include <efi.h>
#include <efilib.h>

#ifndef CFG_PRIMARY
#define CFG_PRIMARY L"EFI\\MOS\\BOOT.CFG"
#endif

typedef struct {
    CHAR16 path[256];
    CHAR16 title[128];
    int used;
} ENTRY;

#define MAX_ENTRIES 16

static ENTRY g_entries[MAX_ENTRIES];

static void Utf8cpAscii(const CHAR8 *in, CHAR16 *out, UINTN maxw)
{
    UINTN i = 0;
    UINTN k = 0;

    if (in[0] && in[0] != '\\' && in[0] != '/') {
        if (k + 1 >= maxw)
            return;
        out[k++] = L'\\';
    }
    while (in[i] && k + 1 < maxw) {
        CHAR8 c = in[i++];
        out[k++] = (CHAR16)((c == '/') ? '\\' : c);
    }
    out[k] = 0;
}

static void Trim(CHAR8 *s)
{
    CHAR8 *p = s;
    UINTN len, start = 0, i;

    while (p[start] == ' ' || p[start] == '\t')
        start++;

    len = 0;
    while (p[start + len])
        len++;

    while (len > 0 && (p[start + len - 1] == ' ' ||
                       p[start + len - 1] == '\t' ||
                       p[start + len - 1] == '\r' ||
                       p[start + len - 1] == '\n'))
        len--;

    for (i = 0; i < len; i++)
        s[i] = p[start + i];
    s[len] = 0;
}

static int StartsWith(const CHAR8 *s, const CHAR8 *p)
{
    UINTN i;
    for (i = 0; p[i]; i++)
        if (s[i] != p[i])
            return 0;
    return 1;
}

static int ParseEntryIndex(const CHAR8 *line)
{
    UINTN i = 7; /* "[entry" */
    UINTN n = 0;
    if (line[0] != '[')
        return -1;
    if (!StartsWith(line, "[entry"))
        return -1;
    while (line[i] >= '0' && line[i] <= '9') {
        n = n * 10 + (UINTN)(line[i] - '0');
        i++;
    }
    if (line[i] != ']')
        return -1;
    if (n >= MAX_ENTRIES)
        return -1;
    return (int)n;
}

static void ParseCfg(CHAR8 *buf, UINTN len)
{
    CHAR8 line[512];
    UINTN i = 0, li = 0;
    int cur = -1;

    ZeroMem(g_entries, sizeof(g_entries));

    while (i <= len) {
        CHAR8 c = (i < len) ? buf[i] : '\n';
        i++;
        if (c != '\n' && c != '\r') {
            if (li < sizeof(line) - 1)
                line[li++] = (CHAR8)c;
            continue;
        }
        line[li] = 0;
        li = 0;
        Trim(line);
        if (line[0] == '#' || line[0] == 0)
            continue;

        if (line[0] == '[') {
            int ix = ParseEntryIndex(line);
            if (ix >= 0) {
                cur = ix;
                g_entries[ix].used = 1;
            }
            continue;
        }

        if (cur < 0)
            continue;

        if (StartsWith(line, "path=")) {
            Utf8cpAscii(line + 5, g_entries[cur].path, 256);
        } else if (StartsWith(line, "title=")) {
            Utf8cpAscii(line + 6, g_entries[cur].title, 128);
        }
    }
}

static EFI_STATUS ReadAllFile(EFI_FILE *fh, CHAR8 **out_buf, UINTN *out_len)
{
    EFI_STATUS st;
    CHAR8 *buf = NULL;
    UINTN cap = 4096, len = 0;

    buf = AllocatePool(cap);
    if (!buf)
        return EFI_OUT_OF_RESOURCES;

    for (;;) {
        UINTN chunk = cap - len;
        if (chunk < 512) {
            CHAR8 *nb = AllocatePool(cap * 2);
            if (!nb) {
                FreePool(buf);
                return EFI_OUT_OF_RESOURCES;
            }
            CopyMem(nb, buf, len);
            FreePool(buf);
            buf = nb;
            cap *= 2;
            chunk = cap - len;
        }
        UINTN got = chunk;
        st = fh->Read(fh, &got, buf + len);
        if (EFI_ERROR(st)) {
            FreePool(buf);
            return st;
        }
        if (got == 0)
            break;
        len += got;
    }
    buf[len] = 0;
    *out_buf = buf;
    *out_len = len;
    return EFI_SUCCESS;
}

static EFI_STATUS OpenCfg(EFI_FILE *root, CHAR16 *rel)
{
    EFI_FILE *fh = NULL;
    EFI_STATUS st = root->Open(root, &fh, rel, EFI_FILE_MODE_READ, 0);
    CHAR8 *buf = NULL;
    UINTN len = 0;

    if (EFI_ERROR(st))
        return st;

    st = ReadAllFile(fh, &buf, &len);
    fh->Close(fh);
    if (EFI_ERROR(st))
        return st;

    ParseCfg(buf, len);
    FreePool(buf);
    return EFI_SUCCESS;
}

static EFI_STATUS ChainToPath(EFI_HANDLE loader_image,
                               EFI_HANDLE volume_device,
                               CHAR16 *rel_path)
{
    EFI_DEVICE_PATH *dp = FileDevicePath(volume_device, rel_path);
    EFI_HANDLE image = NULL;
    EFI_STATUS st;

    if (!dp)
        return EFI_INVALID_PARAMETER;

    st = BS->LoadImage(FALSE, loader_image, dp, NULL, 0, &image);
    if (EFI_ERROR(st))
        return st;

    return BS->StartImage(image, NULL, NULL);
}

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    EFI_STATUS st;
    EFI_LOADED_IMAGE *loaded = NULL;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *fs = NULL;
    EFI_FILE *root = NULL;
    UINTN i;

    InitializeLib(ImageHandle, SystemTable);
    Print(L"MOS UEFI loader\r\n");

    st = BS->HandleProtocol(ImageHandle, &LoadedImageProtocol, (VOID **)&loaded);
    if (EFI_ERROR(st))
        return st;

    st = BS->HandleProtocol(loaded->DeviceHandle, &FileSystemProtocol, (VOID **)&fs);
    if (EFI_ERROR(st))
        return st;

    st = fs->OpenVolume(fs, &root);
    if (EFI_ERROR(st))
        return st;

    st = OpenCfg(root, CFG_PRIMARY);
    if (EFI_ERROR(st))
        st = OpenCfg(root, L"EFI\\BOOT\\BOOT.CFG");

    if (EFI_ERROR(st)) {
        Print(L"No BOOT.CFG (%r), chaining fallback BOOTX64.EFI\r\n", st);
        return ChainToPath(ImageHandle, loaded->DeviceHandle,
                           L"\\EFI\\BOOT\\BOOTX64.EFI");
    }

    for (i = 0; i < MAX_ENTRIES; i++) {
        if (g_entries[i].used && g_entries[i].path[0]) {
            Print(L"Starting [%d] %s\r\n", i, g_entries[i].title);
            return ChainToPath(ImageHandle, loaded->DeviceHandle,
                               g_entries[i].path);
        }
    }

    Print(L"No entries in BOOT.CFG; fallback\r\n");
    return ChainToPath(ImageHandle, loaded->DeviceHandle,
                       L"\\EFI\\BOOT\\BOOTX64.EFI");
}
