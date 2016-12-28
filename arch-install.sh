#!/bin/sh

# This script is derived from the forum post at http://forums.srcds.com/viewtopic/18513.
# It has been modified to work with an 80GB disk and use the UTC timezone for universal
# time-stamping.


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
genfstab -p /mnt >> /mnt/etc/fstab
printf "Complete."

# Move the git repository to /mnt/var/tmp for access after arch-chroot jailing
#cp -p ~/cs-source-server /mnt/var/tmp

arch-chroot /mnt

printf "\nSetting Timezone to UTC\n"
ln -s /usr/share/zoneinfo/UTC /etc/localtime

printf "\nSetting Locale to en_US\n"
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

printf "\nSetting time to UTC\n"
hwclock --systohc --utc

printf "\nSetting hostname\n"
echo "knifin-bitches.jgarfield.com" > /etc/hostname

printf "\nSetting Name Servers\n"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

printf "Creating an initial ramdisk environment in 10 seconds..." && sleep 10
mkinitcpio -p linux

printf "Installing Grub in 10 seconds..." && sleep 10
pacman -S grub-bios
grub-install --target=i386-pc --no-floppy --recheck /dev/sda
mkdir -p /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

#printf "\nSet root password!\n"
passwd

printf "Done! Rebooting in 10 seconds..." && sleep 10
exit
umount /mnt/boot
umount /mnt
reboot
