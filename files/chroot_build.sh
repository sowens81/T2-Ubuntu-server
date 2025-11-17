#!/bin/bash

set -eu -o pipefail

CODENAME=noble

echo >&2 "===]> Info: Configure environment..."
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts

export HOME=/root
export LC_ALL=C

echo "ubuntu-${CODENAME}-server" >/etc/hostname


echo >&2 "===]> Info: Configure APT sources..."
cat <<EOF >/etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu ${CODENAME} main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu ${CODENAME} main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu ${CODENAME}-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu ${CODENAME}-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu ${CODENAME}-security main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu ${CODENAME}-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu ${CODENAME}-backports main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu ${CODENAME}-backports main restricted universe multiverse

apt-get update


echo >&2 "===]> Info: Install essential base system..."
apt-get install -y \
  systemd-sysv \
  gnupg \
  curl \
  wget \
  ca-certificates \
  locales \
  netplan.io \
  network-manager \
  openssh-server \
  initramfs-tools \
  casper \
  linux-firmware


echo >&2 "===]> Info: Add T2 kernel repository..."
mkdir -p /etc/apt/sources.list.d

curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" \
  | gpg --dearmor > /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg

curl -s --compressed -o /etc/apt/sources.list.d/t2.list \
  "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"

echo "deb [signed-by=/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg] https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/${CODENAME} ./" \
  >> /etc/apt/sources.list.d/t2.list

apt-get update


echo >&2 "===]> Info: Install Ubuntu Server packages..."
export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
  ubuntu-server-minimal \
  cloud-init \
  subiquity \
  grub-efi-amd64-signed \
  intel-microcode \
  thermald


echo >&2 "===]> Info: Install T2 kernel..."
apt-get install -y linux-t2="${KERNEL_VERSION}"


echo >&2 "===]> Info: Install Apple T2 drivers..."
apt-get install -y \
  dkms \
  git \
  make \
  gcc \
  apple-firmware-script \
  apple-t2-audio-config \
  bcmwl-kernel-source || true


echo >&2 "===]> Info: Enable Apple T2 modules..."
cat <<EOF >/etc/modules-load.d/t2.conf
apple-bce
apple-ibridge
apple-ib-tb
apple-ib-als
EOF


echo >&2 "===]> Info: Configure NetworkManager (T2 WiFi quirks)..."
mkdir -p /etc/NetworkManager/conf.d

cat <<EOF >/etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[device]
wifi.scan-rand-mac-address=no
EOF


echo >&2 "===]> Info: Update initramfs..."
/usr/sbin/depmod -a "${KERNEL_VERSION}"
update-initramfs -u -k "${KERNEL_VERSION}"


echo >&2 "===]> Info: Configure locale..."
locale-gen --purge en_US.UTF-8 en_US
printf 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' >/etc/default/locale


echo >&2 "===]> Info: Cleanup chroot environment..."
truncate -s 0 /etc/machine-id
apt-get clean
rm -rf /tmp/* ~/.bash_history /tmp/setup_files

rm -f /sbin/initctl || true
dpkg-divert --rename --remove /sbin/initctl || true

umount -lf /dev/pts
umount -lf /sys
umount -lf /proc

export HISTSIZE=0