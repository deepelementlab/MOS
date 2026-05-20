Building BOOTX64.EFI requires gnu-efi (distro package) and a linker script.

Typical Linux (Debian/Ubuntu):

  sudo apt install gnu-efi binutils gcc

  gcc -I/usr/include/efi -I/usr/include/efi/x86_64 \
    -fpic -ffreestanding -fno-stack-protector -fno-stack-check \
    -fshort-wchar -mno-red-zone -maccumulate-outgoing-args \
    -c mosboot.c -o mosboot.o

  ld -nostdlib -znocombreloc -T /usr/lib/elf_x86_64_efi.lds -shared \
    -Bsymbolic /usr/lib/crt0-efi-x86_64.o mosboot.o \
    -o mosboot.so -lefi -lgnuefi -L/usr/lib

  objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym \
    -j .rel -j .rela -j .reloc --target=efi-app-x86_64 \
    -O binary mosboot.so BOOTX64.EFI

Copy BOOTX64.EFI to ESP /EFI/BOOT/ or ship alongside EFI/MOS/BOOT.CFG.
