#!/bin/sh

# This script is derived from the forum post at http://forums.srcds.com/viewtopic/18513.
# It has been modified to work with an 80GB disk and use the UTC timezone for universal
# time-stamping.

timedatectl set-ntp true

# Create partitions for the boot loader and a / root to hold everything else.
printf "\nCreating a new Partition Table..."
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary ext2 1 3                  # Grub bios-gpt
parted -s /dev/sda mkpart primary ext2 3 259                # /boot
parted -s /dev/sda mkpart primary ext4 259 100%             # /
printf "Complete."


# grub needs a small part for it's core.img, otherwise not available with a bios-gpt drive
# http://www.gnu.org/software/grub/manual/html_node/BIOS-installation.html#BIOS-installation
printf "\nNaming and Flagging Partitions..."
parted -s /dev/sda set 1 bios_grub on
parted -s /dev/sda set 2 boot on
parted -s /dev/sda name 1 grub
parted -s /dev/sda name 2 boot
parted -s /dev/sda name 3 root
printf "Complete."


# Arch parted doesn't have the mkfs or mkpartfs commands
printf "\nCreating File-systems on Partitions...\n"
mkfs.ext2 -qF /dev/sda2 > /dev/null
mkfs.ext4 -qF /dev/sda3 > /dev/null
printf "\nComplete."


mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot


# Get current list of US mirrors
printf "\nDownloading current mirrorlist and ranking all mirrors..."
curl -s -o mirrorlist "https://www.archlinux.org/mirrorlist/?country=US&protocol=http&ip_version=4"

# Uncomment all mirrors
sed '/^#\S/ s|#||' -i mirrorlist

# Rank mirrors and sort them accordingly
/usr/bin/rankmirrors -n 0 mirrorlist > /etc/pacman.d/mirrorlist

printf "Complete."


printf "\nInstalling base and base-devel packages through pacstrap...\n"
pacstrap /mnt base base-devel > /dev/null
printf "\nComplete."


printf "\nGenerating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
printf "Complete."

#cp -pR ~/cs-source-server /mnt/root

#arch-chroot /mnt /root/cs-source-server/arch-config.sh

#umount /mnt/boot
#umount /mnt
#reboot
