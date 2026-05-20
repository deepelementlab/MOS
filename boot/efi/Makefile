# gnu-efi UEFI application — Linux/macOS typical toolchain.
# Requires: gnu-efi, gcc, objcopy.

ARCH            ?= x86_64
PREFIX          ?= $(ARCH)-none-elf-
CC              ?= gcc
LD              ?= ld
OBJCOPY         ?= objcopy

EFIINC          ?= /usr/include
GNUEFI_INC      ?= $(EFIINC)/efi
LIBDIR          ?= /usr/lib

CFLAGS          := -I$(GNUEFI_INC) -fpic -ffreestanding -fno-stack-protector \
                   -fno-stack-check -fshort-wchar -mno-red-zone \
                   -DEFI_FUNCTION_WRAPPER -Wall -Wextra

LDFLAGS         := -nostdlib -znocombreloc -T $(SCRIPT) -shared -Bsymbolic \
                   -L$(LIBDIR) $(shell pkg-config --libs-only-L gnu-efi 2>/dev/null)

ifeq ($(wildcard $(SCRIPT)),)
  SCRIPT := elf_x86_64_efi.lds
endif

OBJS            := mosboot.o

.PHONY: all clean

all: BOOTX64.EFI

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Fallback link script fragment if distro lacks gnuefi helpers:
$(SCRIPT):
	@echo "SECTIONS { . = 0; .text : { *(.text) } .data : { *(.data) } .reloc : { *(.reloc) } }" > $@

BOOTX64.EFI: mosboot.o $(SCRIPT)
	@if pkg-config --exists gnu-efi 2>/dev/null; then \
	  $(LD) $(LDFLAGS) -o mosboot.so $< \
	    $$(pkg-config --libs gnu-efi) -lefi; \
	else \
	  echo "gnu-efi/pkg-config not found; skipping ELF link (install gnu-efi)"; \
	  exit 1; \
	fi
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym \
	  -j .rel -j .rela -j .reloc --target=efi-app-x86_64 -O binary mosboot.so $@

clean:
	rm -f *.o *.so BOOTX64.EFI elf_x86_64_efi.lds
