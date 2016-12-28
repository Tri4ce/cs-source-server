# Counter-Strike: Source Server on Arch Linux x64

This repository contains scripts and artifcats used to quickly provision a [Counter-Strike: Source](http://store.steampowered.com/app/240/) server on Arch Linux x64.
It is assumed that you are installing into a Virtual Machine (VM) Guest environment, but these instructions should also work similarly for a physical server install.


## Virtual Machine Configuration
Listed below are the specs and settings I confgured for a VM running inside of [Oracle VM VirtualBox](https://www.virtualbox.org/) on [Windows 10](https://www.microsoft.com/en-us/windows/).
Depending on the Hypervisor you're using (VMWare Player, Hyper-V, qemu) settings and milage may vary.

* Name: Arch Linux x64
* Type: Linux
* Version: Arch Linux (64-bit)
* System Memory: 4GB
* Removed Floppy Disk drive
* Disabled Audio
* Set Network Adapter to Bridged Mode
* Enable PAE/NX for Processor
* Disable USB Controller


## Quick Guide
The steps listed in this section are for an insanely quick setup (e.g. you're rebuilding an existing VM or building multiple servers).
For a detailed set of instructions and more information, please read below this section.

1. mount -o remount,size=1G /run/archiso/cowspace
2. pacman -Syy
3. pacman --noconfirm -S git
4. git clone https://github.com/Tri4ce/cs-source-server.git
5. cd cs-source-server
6. chmod +x *.sh
7. ./arch-install.sh
8. ./arch-config.sh
9. 


## Detailed Guide



### Get Arch Linux Live CD running

1. Download the [latest Arch Linux ISO](https://www.archlinux.org/download/)
2. Take a quick read through the [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/installation_guide) to become familiar with what to expect during this process
3. Add the Arch Linux ISO file as a CD-ROM drive to your Virtual Machine (or burn a physical copy to a CD/DVD or make a bootable USB stick)
4. Boot up your machine and wait for the Arch Linux boot menu to appear
5. Make sure **Boot Arch Linux (x86_64)** is highlighted and press **Enter**
6. Arch Linux should run through a bunch of startup routines and display the status for each. This is normal. Just wait.
7. Eventually you should have a shell logged-in as _root_.

### Installing git
In order to pull down the scripts from the Github Repository, we need to install git with the Arch package manager, pacman.
In order to do this, we need to bump up the size of the partition that the _root /_ is sitting inside of, so that there's enough space to install git 
(remember, we're still running off of the Live CD image right now, we haven't written anything to a physical disk, so it's still a RAM-based File-system)

1. mount -o remount,size=3G /run/archiso/cowspace
    * This will provide 3GB of space vs. the default 256MB
2. pacman -Syy
    * Make sure pacman has the latest package listings and sources
3. pacman -S git
    * Install the git client

### Clone the repository and run the scripts
Now that the git client is available, we can clone the repository holding the scripts.

1. git clone https://github.com/Tri4ce/cs-source-server.git
2. cd cs-source-server
3. chmod +x *.sh
4. ./arch-install.sh
5. ./arch-config.sh


## Citations / References

* mount(8) manpage - http://man7.org/linux/man-pages/man8/mount.8.html
* SRCDS on Arch Linux - http://forums.srcds.com/viewtopic/18513
* Arch Linux Installation Guide - https://wiki.archlinux.org/index.php/installation_guide
* GNU Parted (Arch Linux) - https://wiki.archlinux.org/index.php/GNU_Parted
* GRUB (Arch Linux) - https://wiki.archlinux.org/index.php/GRUB
* grow live rootfs ? - https://bbs.archlinux.org/viewtopic.php?id=210389
* pacman (Arch Linux) - https://wiki.archlinux.org/index.php/pacman
