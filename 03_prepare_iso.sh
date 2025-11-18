#!/bin/bash
set -eu -o pipefail

echo >&2 "===]> Info: Prepare GRUB UEFI image... "
cd "${IMAGE_PATH}"

grub-mkstandalone \
  --format=x86_64-efi \
  --output=isolinux/BOOTx64.EFI \
  --locales="" \
  --fonts="" \
  "boot/grub/grub.cfg=isolinux/grub.cfg"

(
  cd isolinux &&
    dd if=/dev/zero of=efiboot.img bs=1M count=10 &&
    mkfs.vfat efiboot.img &&
    mmd -i efiboot.img EFI EFI/BOOT &&
    mcopy -i efiboot.img BOOTx64.EFI ::EFI/BOOT/
)

echo >&2 "===]> Info: Prepare GRUB BIOS image... "

grub-mkstandalone \
  --format=i386-pc \
  --output=isolinux/core.img \
  --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
  --modules="linux16 linux normal iso9660 biosdisk search" \
  --locales="" \
  --fonts="" \
  "boot/grub/grub.cfg=isolinux/grub.cfg"

cat "/usr/lib/grub/i386-pc/cdboot.img" \
    "${IMAGE_PATH}/isolinux/core.img" \
    > "${IMAGE_PATH}/isolinux/bios.img"