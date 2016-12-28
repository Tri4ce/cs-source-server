#!/bin/sh

# arch-config.sh configures a generic Arch installation
# this should be run inside of the chroot install environment!

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