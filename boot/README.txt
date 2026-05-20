MOS standalone multi-system bootloader (firmware/)
==================================================

This directory implements BIOS Stage1+Stage2 chain-loading and a UEFI
chain-loader. Legacy teaching code remains under boot/.

Layout
------
  bios/stage1/     MBR (512 bytes) loads Stage2 via INT 13h extended read.
  bios/stage2/     Real-mode menu: MBR partitions, GPT entries, VBR chain.
  efi/             UEFI x64 application (BOOTX64.EFI) using gnu-efi.
  common/          Example boot.cfg and schema notes.

Build (overview)
----------------
  See firmware/Makefile. UEFI needs gnu-efi headers/libs (typical on Linux).

Install image layout (tools/mkimage.py)
---------------------------------------
  Sector 0   : stage1/mbr.bin
  Sector 1+  : stage2/stage2.bin (padded)

QEMU
----
  See tools/qemu-bios.sh and tools/qemu-uefi.sh (run from WSL/Linux or Git Bash).

mkimage (BIOS disk)
-------------------
  mkdir -p build && python3 tools/mkimage.py --mbr firmware/bios/stage1/mbr.bin \\
    --stage2 firmware/bios/stage2/stage2.bin -o build/chain.img

Root Makefile
-------------
  make firmware   # builds BIOS bits with NASM
