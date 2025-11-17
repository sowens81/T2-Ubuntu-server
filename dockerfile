FROM ubuntu:24.04

# Prevent systemd from attempting to boot
ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

# Disable systemctl to prevent failures
RUN ln -sf /bin/true /usr/bin/systemctl

# Ensure PATH includes /usr/sbin for kmod, depmod, etc
ENV PATH="/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

# Install required tools for ISO building and chroot environments
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
        ca-certificates \
        curl \
        wget \
        gnupg \
        sudo \
        kmod \
        udev \
        dbus \
        systemd \
        systemd-sysv \
        iputils-ping \
        net-tools \
        vim \
        nano \
        bash-completion && \
    rm -rf /var/lib/apt/lists/*

# Disable systemd binary to avoid any chance it runs as PID1 inside container
RUN ln -sf /bin/true /bin/systemd

# Allow fuse inside container for grub-mkstandalone
RUN apt-get update && apt-get install -y fuse3 && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]