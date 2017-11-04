#!/bin/bash
#
# Created by: Nicholas Wereszczak
# Email:      nwereszczak@gmail.com
#
# Requirments:
# - Only works on x86_64 compatible machines
# - Minimum of 512GB of RAM
#

#
# Pre-installation
#

# Set keyboard layout; Default is US
echo "Set keyboard layout; Default is US"
echo "Using the default; US"
# ls /usr/share/kdb/keymaps/**/*.map.gz
# loadkeys de-latin # German

# Verify the boot mode
echo "Verify the boot mode"
if [ ! -d ls /sys/firmware/efi/efivars ];
then
    # bios
    echo "BIOS is available; continuing..."
else
    # uefi
    echo "UEFI is available, but is not spported in this script."
    echo "Using BIOS; continuing..."
fi

# Connect to the internet
echo "Connect to the internet"

# This script currently on supports wired internet with dhcp
echo "This script currently on supports wired internet with DHCP"

if [ ! ping -c 1 archlinux.org  &> /dev/null ];
then
    echo "ping failed; no internet; exiting..."
    exit 1
fi

# Update the system clock
timedatectl set-ntp true

# Partition the disks
echo "Partition the disks"

echo "Installing arch on the largest found disk..."
largest=$(lsblk | grep disk | awk '{print $4 " " $1}' | sort | head -n 1 | awk '{print $2}')
install_disk=/dev/$largest

echo -n "Is this a good question (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    : # pass
else
     echo "Exiting..."
     exit 1
fi

echo "Continuing installation on "$install_disk

echo "Using MBR/BIOS"
echo ""
echo "Disk will be setup like so..."
echo "Mount point   Partition   Partition type  Bootable flag   Size"
echo "[SWAP]        /dev/sdx1   Linux swap      No              2GB"
echo "/             /dev/sdx2   Linux           Yes             Remainder of the device"
echo ""

parted -s $install_disk mklabel msdos mkpart primary linux-swap 1MiB 2GiB
parted -s $install_disk mkpart primary ext4 2GiB 100%
parted -s $install_disk set 2 boot on

# Format the partitions
echo "Format the partitions"
swap=$install_disk1
root=$install_disk2

mkswap $swap
swapon $swap
mkfs.ext4 $root

# Mount the file systems
echo "Mount the file systems"
mount $root /mnt

# Mirror list
echo "Configure mirrorlist"

backup=/etc/pacman.d/mirrorlist.backup
cp /etc/pacman.d/mirrorlist $backup

yes | pacman -Sy reflector
reflector --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install the base packages
echo "Install the base packages + others"
pacstrap /mnt base base-devel nmap htop screen reflector grub

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Time zone
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
hwclock --systohc

# Locale
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Initramfs
mkinitcpio -p linux

# Root password
echo "password" | passwd --stdin

# Boot loader
echo "Boot loader"
echo "Install grub..."
grub-install --target=i386-pc $install_disk
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot
exit

# Unmount
umount -R /mnt

# Reboot system
reboot