# Set up keyring
pacman-key --init
pacman-key --populate archlinux

# Sync, refresh, and upgrade
pacman -Syu

# Install packages
pacman -S openssh
pacman -S lib32-glibc lib32-libstdc++6
