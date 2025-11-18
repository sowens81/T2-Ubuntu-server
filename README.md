
# Ubuntu Server 24.04 T2 Edition

This repository builds **Ubuntu Server 24.04 (Noble) ISOs optimized for Apple T2 Macs**. These ISOs allow you to install Ubuntu Server with working keyboard, trackpad, Wi-Fi, and audio on T2 Macs—no external keyboard or mouse required. The ISO filename format is:

```
ubuntu-24.04-server-t2-<KERNEL_VERSION>.iso
```

![CI](https://github.com/sowens81/T2-Ubuntu-server/actions/workflows/CI.yml/badge.svg?branch=LTS)

**If this repo helped you, consider supporting the [contributors](https://wiki.t2linux.org/contribute/).**

## What’s Included

- Ubuntu Server 24.04 (Noble) base
- Subiquity server installer (no desktop/GUI)
- T2 kernel and all Apple T2 hardware patches
- Drivers for:
    - apple-bce (keyboard/trackpad)
    - apple-ib (touchbar/iBridge)
    - apple-t2-audio
    - bcmwl-kernel-source (Wi-Fi)
- All server packages: `ubuntu-server-minimal`, `cloud-init`, `subiquity`, etc.

## Installation

1. Shrink your Mac partition in macOS.
2. Download the latest ISO from Releases (filename: `ubuntu-24.04-server-t2-<KERNEL_VERSION>.iso`).
3. Write the ISO to a USB drive:

    ```bash
    diskutil list # Find your USB device number
    diskutil umountDisk /dev/diskX
    sudo dd bs=4M if=ubuntu-24.04-server-t2-<KERNEL_VERSION>.iso of=/dev/diskX conv=fdatasync status=progress
    ```
4. Boot into Recovery mode and allow booting of external/unknown OS.
5. Reboot and hold the Option key until the boot menu appears.
6. Select "EFI Boot" (usually the third option).
7. The system will boot into the Ubuntu Server installer (Subiquity).
8. Follow the Subiquity prompts to install Ubuntu Server. Partition as needed (EFI, ext4 for `/`, swap optional).
9. Complete installation, shut down, and remove the USB drive.
10. Boot your new Ubuntu Server from the internal drive (hold Option and select the new EFI boot entry).

## Configuration

- See <https://wiki.t2linux.org/guides/wifi/> for Wi-Fi setup.
- To remap keyboard keys, create `/etc/modprobe.d/hid_apple.conf` and update GRUB. See <https://github.com/free5lot/hid-apple-patched>.
    ```conf
    # /etc/modprobe.d/hid_apple.conf
    options hid_apple swap_fn_leftctrl=1
    options hid_apple swap_opt_cmd=1
    ```

## Updating the Kernel

Follow [this guide](https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel?tab=readme-ov-file#installation) to update to newer T2 kernels.


## Known Issues & Troubleshooting

- Checksum may fail for `md5sum.txt` and `/boot/grub/bios.img` (harmless).
- TouchID and Thunderbolt are not supported.
- Microphone is recognized but may have low volume.
- `ctrl+x` does not work in GRUB; use `F10` to boot with custom kernel parameters.
- If keyboard/trackpad do not work in the installer, ensure you are using the correct T2 ISO and booted via "EFI Boot".


## Credits & Thanks

- @mikeeq - mbp-fedora
- @marcosfad - mbp-ubuntu
- @MCMrARM - reverse engineering
- @ozbenh - NVME patch
- @roadrunner2 - SPI (touchbar) driver
- @aunali1 - kernel CI and support
- @ppaulweber - keyboard/Macbook Air patches
- @kevineinarsson - audio settings


## Resources

- Discord: <https://discord.gg/Uw56rqW>
- T2Linux Wiki: <https://wiki.t2linux.org/>
- Kernel: <https://github.com/t2linux/T2-Debian-and-Ubuntu-Kernel>
- Patches: <https://github.com/t2linux/linux-t2-patches>
