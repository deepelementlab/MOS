;; Shared layout between Stage1 MBR and Stage2 build / mkimage tool

STAGE2_LBA              equ 1
STAGE2_SECTOR_COUNT     equ 128    ;; 128 * 512 = 64KiB for stage2.bin
STAGE2_LOAD_SEG         equ 0x1000 ;; linear 0x10000
STAGE2_LOAD_OFF         equ 0
