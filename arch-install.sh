#!/bin/sh

# This script is derived from the forum post at http://forums.srcds.com/viewtopic/18513.
# It has been modified to work with an 80GB disk and use the UTC timezone for universal
# time-stamping.

# Create partitions for the boot loader and a / root to hold everything else.
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary ext2 1 3                  # Grub bios-gpt
parted /dev/sda mkpart primary ext2 3 259                # /boot
parted /dev/sda mkpart primary ext4 259 100%             # /

# grub needs a small part for it's core.img, otherwise not available with a bios-gpt drive
# http://www.gnu.org/software/grub/manual/html_node/BIOS-installation.html#BIOS-installation
parted /dev/sda set 1 bios_grub on
parted /dev/sda set 2 boot on
parted /dev/sda name 1 grub
parted /dev/sda name 2 boot
parted /dev/sda name 3 root

# Arch parted doesn't have the mkfs or mkpartfs commands
mkfs.ext2 /dev/sda2
mkfs.ext4 /dev/sda3

mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot

# Get current list of US mirrors
curl -o mirrorlist "https://www.archlinux.org/mirrorlist/?country=US&protocol=http&ip_version=4"

# Uncomment all mirrors
sed '/^#\S/ s|#||' -i mirrorlist

# Rank mirrors and sort them accordingly
/usr/bin/rankmirrors -n 0 mirrorlist > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel
genfstab -p /mnt >> /mnt/etc/fstab

# Move the git repository to /mnt/var/tmp for access after arch-chroot jailing
mv ~/cs-source-server /mnt/var/tmp

arch-chroot /mnt
