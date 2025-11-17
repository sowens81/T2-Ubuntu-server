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
deb http://archive.ubuntu.com/ubuntu ${CODENAME}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${CODENAME}-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${CODENAME}-backports main restricted universe multiverse
EOF

apt-get update


echo >&2 "===]> Info: Install base system packages..."
export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
  systemd-sysv \
  systemd \
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
  linux-firmware \
  kmod \
  binutils \
  sudo


echo >&2 "===]> Info: Add T2 kernel repository..."
mkdir -p /etc/apt/sources.list.d

curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" \
  | gpg --dearmor > /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg

curl -s --compressed -o /etc/apt/sources.list.d/t2.list \
  "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"

# Optional release-specific (may 404 if empty)
echo "deb [signed-by=/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg] \
https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/${CODENAME} ./" \
  >> /etc/apt/sources.list.d/t2.list

apt-get update


echo >&2 "===]> Info: Install Ubuntu Server live system..."
apt-get install -y \
  ubuntu-server-minimal \
  cloud-init \
  subiquity \
  grub-efi-amd64-signed \
  intel-microcode \
  thermald


echo >&2 "===]> Info: Install T2 kernel..."
# Install the latest available linux-t2 kernel (no version pinning!)
apt-get install -y linux-t2


echo >&2 "===]> Info: Install Apple T2 userland + drivers..."
apt-get install -y \
  dkms \
  git \
  make \
  gcc \
  apple-t2-audio-config \
  apple-firmware-script \
  bcmwl-kernel-source || true


echo >&2 "===]> Info: Enable Apple T2 kernel modules..."
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

# Ensure depmod exists (Docker sometimes strips it)
if [ ! -x /usr/sbin/depmod ]; then
    echo "WARNING: depmod missing, installing kmod..."
    apt-get install -y kmod
fi

# Run depmod + rebuild initramfs for the installed linux-t2
KVER="$(ls /lib/modules | grep t2 | head -n1)"
echo "Using kernel version: $KVER"

depmod -a "$KVER"
update-initramfs -u -k "$KVER"


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

echo >&2 "===]> Done building T2 Ubuntu Server chroot! ==="