#!/bin/bash

# If terminal is not already in pxe folder, change it so that it is during script runtime
if ! pwd | grep -q pxe; then
    pushd ./pxe
fi

# Create tftpboot directory structure
mkdir -p tftpboot/boot/bios/pxelinux.cfg
mkdir -p tftpboot/boot/uefi/pxelinux.cfg
mkdir -p tftpboot/grub/fonts
mkdir -p tftpboot/init
mkdir -p tftpboot/iso_mount

# Download Ubuntu 20 iso
wget https://releases.ubuntu.com/20.04/ubuntu-20.04.2-live-server-amd64.iso -q --show-progress -O ubuntu.iso

# Mount Ubuntu iso
mkdir ubuntu-iso
sudo mount -o loop ./ubuntu.iso ./ubuntu-iso/

# Copy pxe dependencies to proper directory for container usage
cp -p ./ubuntu-iso/casper/vmlinuz                           ./tftpboot/init
cp -p ./ubuntu-iso/casper/initrd                            ./tftpboot/init
cp -p /usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed ./tftpboot/boot/uefi/grubx64.efi
cp -p /usr/lib/shim/shimx64.efi.signed                      ./tftpboot/boot/uefi/bootx64.efi
cp -p /usr/lib/PXELINUX/pxelinux.0                          ./tftpboot/boot/bios
cp -p /usr/lib/syslinux/modules/bios/ldlinux.c32            ./tftpboot/boot/bios
cp -p /usr/lib/syslinux/modules/bios/libcom32.c32           ./tftpboot/boot/bios
cp -p /usr/lib/syslinux/modules/bios/libutil.c32            ./tftpboot/boot/bios
cp -p /usr/lib/syslinux/modules/bios/vesamenu.c32           ./tftpboot/boot/bios
cp -p /usr/share/grub/unicode.pf2                           ./tftpboot/grub/fonts

# Install network boot dependencies
PACKAGES="pxelinux shim shim-signed grub-efi-amd64-signed grub-common"
sudo apt install $PACKAGES

# Go back to original directory
popd