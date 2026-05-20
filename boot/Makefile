# MOS standalone firmware build (BIOS + optional UEFI if gnu-efi present)
# Run from firmware/ directory.

NASM ?= nasm
PYTHON ?= python3

BIOS_STAGE1 = bios/stage1/mbr.bin
BIOS_STAGE2 = bios/stage2/stage2.bin

.PHONY: all bios clean uefi

all: bios

bios: $(BIOS_STAGE1) $(BIOS_STAGE2)
	@echo "BIOS binaries built."

$(BIOS_STAGE1): bios/stage1/mbr.asm bios/include/stage2_layout.inc
	$(NASM) -f bin -o $@ bios/stage1/mbr.asm

$(BIOS_STAGE2): bios/stage2/stage2.asm bios/include/stage2_layout.inc
	$(NASM) -f bin -o $@ bios/stage2/stage2.asm

uefi:
	$(MAKE) -C efi

clean:
	rm -f $(BIOS_STAGE1) $(BIOS_STAGE2)
	-$(MAKE) -C efi clean
