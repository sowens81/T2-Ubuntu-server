FROM ubuntu:24.04

ENV container docker
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# -------------------------------
# Install systemd + base packages
# -------------------------------
RUN apt-get update && \
    apt-get install -y \
        systemd \
        systemd-sysv \
        dbus \
        udev \
        kmod \
        ca-certificates \
        curl \
        wget \
        gnupg \
        sudo \
        vim \
        nano \
        iputils-ping \
        net-tools \
        dnsutils \
        software-properties-common \
        bash-completion && \
    apt-get clean

# -------------------------------
# Install all ISO-building tools
# -------------------------------
RUN apt-get update && \
    apt-get install -y \
        debootstrap \
        squashfs-tools \
        xorriso \
        isolinux \
        grub-pc-bin \
        grub-efi-amd64-bin \
        grub-common \
        mtools \
        dosfstools \
        rsync \
        parted \
        gdisk \
        binutils \
        build-essential \
        git && \
    apt-get clean

# -------------------------------
# Systemd setup
# -------------------------------
VOLUME [ "/sys/fs/cgroup" ]
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]