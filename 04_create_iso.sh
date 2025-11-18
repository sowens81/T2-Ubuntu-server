#!/bin/bash
set -eu -o pipefail

cd "${IMAGE_PATH}"

echo >&2 "===]> Info: Create md5sum.txt... "
(find . -type f -print0 | xargs -0 md5sum > md5sum.txt)

echo >&2 "===]> Info: Build final ISO image... "

xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "UBUNTU_T2_24_04" \
  -b boot/grub/bios.img \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -c boot/grub/boot.cat \
  --grub2-boot-info \
  --grub2-mbr "/usr/lib/grub/i386-pc/boot_hybrid.img" \
  -eltorito-alt-boot \
  -e "EFI/efiboot.img" \
  -no-emul-boot \
  -isohybrid-mbr "${ROOT_PATH}/files/isohdpfx.bin" \
  -isohybrid-apm-hfsplus \
  -isohybrid-gpt-basdat \
  -output "${ROOT_PATH}/ubuntu-24.04-${KERNEL_VERSION}-T2.iso" \
  -graft-points \
  "." \
  /boot/grub/bios.img=isolinux/bios.img \
  /EFI/efiboot.img=isolinux/efiboot.img