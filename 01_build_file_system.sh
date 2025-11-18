#!/bin/bash
set -eu -o pipefail

echo >&2 "===]> Info: Bootstrap filesystem... "
debootstrap \
  --arch=amd64 \
  --variant=minbase \
  noble \
  "${CHROOT_PATH}" \
  http://archive.ubuntu.com/ubuntu/

echo >&2 "===]> Info: Preparing chroot... "
mount --bind /dev "${CHROOT_PATH}/dev"
mount --bind /run "${CHROOT_PATH}/run"

cp -r "${ROOT_PATH}/files" "${CHROOT_PATH}/tmp/setup_files"

echo >&2 "===]> Info: Running chroot build script... "
chroot "${CHROOT_PATH}" /bin/bash -c "KERNEL_VERSION=${KERNEL_VERSION} /tmp/setup_files/chroot_build.sh"

echo >&2 "===]> Info: Cleanup chroot mounts... "
umount "${CHROOT_PATH}/dev" || true
# /run is skipped because Docker conflicts sometimes

echo >&2 "===]> Info: Patch GRUB (disable OS detection)... "
cp -rfv "${ROOT_PATH}/files/grub/30_os-prober" "${CHROOT_PATH}/etc/grub.d/30_os-prober"
chmod 755 "${CHROOT_PATH}/etc/grub.d/30_os-prober"