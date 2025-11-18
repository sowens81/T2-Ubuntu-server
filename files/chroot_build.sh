#!/bin/bash
set -eu -o pipefail

CODENAME=noble

echo >&2 "===]> Info: Configure chroot environment... "

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devpts devpts /dev/pts

export HOME=/root
export LC_ALL=C

echo "ubuntu-${CODENAME}-live" >/etc/hostname

echo >&2 "===]> Info: Configure apt sources... "
cat <<EOF >/etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu ${CODENAME} main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${CODENAME}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${CODENAME}-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${CODENAME}-backports main restricted universe multiverse
EOF

apt-get update

echo >&2 "===]> Info: Install essential toolchain... "
apt-get install -y systemd-sysv gnupg curl wget ca-certificates

echo >&2 "===]> Info: Add T2 Ubuntu Repo... "
mkdir -p /etc/apt/sources.list.d
curl -s https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg | gpg --dearmor \
  > /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg

curl -s -o /etc/apt/sources.list.d/t2.list \
  https://adityagarg8.github.io/t2-ubuntu-repo/t2.list

echo "deb [signed-by=/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg] \
https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/${CODENAME} ./" \
>> /etc/apt/sources.list.d/t2.list

apt-get update

echo >&2 "===]> Info: Configure machine-id + initctl divert... "
dbus-uuidgen > /etc/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

echo >&2 "===]> Info: Install core Live System packages... "

export DEBIAN_FRONTEND=noninteractive

apt-get install -y -qq \
  sudo \
  casper \
  netplan.io \
  openssh-server \
  locales \
  initramfs-tools \
  linux-firmware \
  intel-microcode \
  kmod \
  busybox-static \
  fdisk \
  gdisk \
  cloud-init \
  cloud-initramfs-dyn-netconf

echo >&2 "===]> Info: Install T2 kernel (version: ${KERNEL_VERSION})... "
apt-get install -y -qq \
  linux-t2=KVER-PREL-${CODENAME}

echo >&2 "===]> Info: Install T2 utilities and audio drivers... "
apt-get install -y -qq \
  git \
  nano \
  make \
  gcc \
  dkms \
  apple-t2-audio-config \
  apple-firmware-script

echo >&2 "===]> Info: Switch initramfs compression to gzip... "
sed -i 's/COMPRESS=lz4/COMPRESS=gzip/' /etc/initramfs-tools/initramfs.conf

echo >&2 "===]> Info: Configure T2 drivers... "
printf 'apple-bce\n' > /etc/modules-load.d/t2.conf

# Optional touchbar settings:
# printf 'options apple-ib-tb fnmode=1\n' > /etc/modprobe.d/apple-tb.conf

echo >&2 "===]> Info: Update initramfs for ${KERNEL_VERSION}... "
depmod -a "${KERNEL_VERSION}"
update-initramfs -u -v -k "${KERNEL_VERSION}"

echo >&2 "===]> Info: Configure locales... "
locale-gen --purge en_US.UTF-8
printf 'LANG="C.UTF-8"\nLANGUAGE="C.UTF-8"\n' > /etc/default/locale

echo >&2 "===]> Info: Add AMD GPU power mgmt rule... "
cat <<EOF >/etc/udev/rules.d/30-amdgpu-pm.rules
KERNEL=="card[012]", SUBSYSTEM=="drm", DRIVERS=="amdgpu", \
ATTR{device/power_dpm_force_performance_level}="low"
EOF

echo >&2 "===]> Info: Cleanup chroot... "
truncate -s 0 /etc/machine-id

rm -f /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

apt-get clean
rm -rf /tmp/* ~/.bash_history /tmp/setup_files

umount -lf /dev/pts || true
umount -lf /sys || true
umount -lf /proc || true

export HISTSIZE=0
echo >&2 "===]> Chroot build complete. ==="