#!/bin/bash
set -eu -o pipefail

echo >&2 "===]> Info: Create ISO root directory... "
cd "${WORKING_PATH}"

rm -rf "${IMAGE_PATH}" || true
mkdir -p "${IMAGE_PATH}"/{casper,install,isolinux,snap,usr/lib}

echo >&2 "===]> Info: Copy kernel + initrd... "
cp "${CHROOT_PATH}/boot/vmlinuz-${KERNEL_VERSION}" "${IMAGE_PATH}/casper/vmlinuz"
cp "${CHROOT_PATH}/boot/initrd.img-${KERNEL_VERSION}" "${IMAGE_PATH}/casper/initrd"

echo >&2 "===]> Info: Download and extract Subiquity installer... "
ISO_NAME="ubuntu-24.04-live-server-amd64.iso"

if [ ! -f "${WORKING_PATH}/${ISO_NAME}" ]; then
    wget -O "${WORKING_PATH}/${ISO_NAME}" \
    https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso
fi

mkdir -p /mnt/subiquity
mount -o loop "${WORKING_PATH}/${ISO_NAME}" /mnt/subiquity

# Copy subiquity directories
mkdir -p "${IMAGE_PATH}/subiquity"
cp -a /mnt/subiquity/subiquity "${IMAGE_PATH}/"

mkdir -p "${IMAGE_PATH}/usr/lib/subiquity"
cp -a /mnt/subiquity/usr/lib/subiquity/* "${IMAGE_PATH}/usr/lib/subiquity/"

mkdir -p "${IMAGE_PATH}/snap"
cp -a /mnt/subiquity/snap/subiquity "${IMAGE_PATH}/snap/"

umount /mnt/subiquity || true

echo >&2 "===]> Info: Add autoinstall metadata... "
touch "${IMAGE_PATH}/ubuntu"
mkdir -p "${IMAGE_PATH}/autoinstall"
cp "${ROOT_PATH}/files/autoinstall/user-data" "${IMAGE_PATH}/autoinstall/user-data"
cp "${ROOT_PATH}/files/autoinstall/meta-data" "${IMAGE_PATH}/autoinstall/meta-data"

echo >&2 "===]> Info: Add GRUB configuration... "
cp "${ROOT_PATH}/files/grub/grub.cfg" "${IMAGE_PATH}/isolinux/grub.cfg"

echo >&2 "===]> Info: Compress filesystem to squashfs... "
mksquashfs "${CHROOT_PATH}" "${IMAGE_PATH}/casper/filesystem.squashfs"
printf "%s" "$(du -sx --block-size=1 "${CHROOT_PATH}" | cut -f1)" > \
"${IMAGE_PATH}/casper/filesystem.size"

echo >&2 "===]> Info: Generate manifest... "
chroot "${CHROOT_PATH}" \
  dpkg-query -W --showformat='${Package} ${Version}\n' \
  | tee "${IMAGE_PATH}/casper/filesystem.manifest"

cp "${IMAGE_PATH}/casper/filesystem.manifest" \
   "${IMAGE_PATH}/casper/filesystem.manifest-desktop"

REMOVE='ubiquity casper lupin-casper discover discover-data os-prober laptop-detect'

for i in $REMOVE; do
  sed -i "/${i}/d" "${IMAGE_PATH}/casper/filesystem.manifest-desktop"
done

echo >&2 "===]> Info: Create README.diskdefines... "
cat <<EOF > "${IMAGE_PATH}/README.diskdefines"
#define DISKNAME  Ubuntu T2 24.04 LTS "Noble Numbat" - amd64
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF