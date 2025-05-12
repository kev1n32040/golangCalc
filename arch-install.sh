#!/bin/bash

# Arch Linux Auto Install Script (BIOS + UEFI)
# Timezone: Asia/Krasnoyarsk
# Author: kev1n32040

set -euo pipefail

echo "==> Удаление повреждённых пакетов и обновление ключей..."
rm -f /var/cache/pacman/pkg/*.pkg.tar.*

pacman -Sy --noconfirm archlinux-keyring

pacman-key --init
pacman-key --populate

echo "==> Проверка ключей завершена."

# Variables
disk="/dev/sda"
hostname="archlinux"
username="user"
password="password"
timezone="Asia/Krasnoyarsk"
locale="en_US.UTF-8 UTF-8"
locale_conf="en_US.UTF-8"

# Check boot mode
if [ -d /sys/firmware/efi ]; then
    boot_mode="UEFI"
else
    boot_mode="BIOS"
fi

echo "Installing in $boot_mode mode."

# Clear and partition disk
wipefs -af "$disk"
sgdisk -Zo "$disk"

if [ "$boot_mode" = "UEFI" ]; then
    sgdisk -n1:0:+300M -t1:ef00 "$disk"
    sgdisk -n2:0:0     -t2:8300 "$disk"
    part_boot="${disk}1"
    part_root="${disk}2"
else
    sgdisk -a 1 -n1:2048:+1M -t1:ef02 "$disk"
    sgdisk -n2:0:0     -t2:8300 "$disk"
    part_root="${disk}2"
fi

sleep 2

# Format partitions
if [ "$boot_mode" = "UEFI" ]; then
    mkfs.fat -F32 "$part_boot"
fi
mkfs.ext4 -F "$part_root"

# Mount
mount "$part_root" /mnt
if [ "$boot_mode" = "UEFI" ]; then
    mkdir -p /mnt/boot
    mount "$part_boot" /mnt/boot
fi

# Install base system
pacstrap /mnt base linux linux-firmware bash sudo nano networkmanager grub efibootmgr

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and configure system
arch-chroot /mnt /bin/bash <<EOF

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

echo "$locale" > /etc/locale.gen
locale-gen

echo "LANG=$locale_conf" > /etc/locale.conf
echo "$hostname" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\t$hostname.localdomain\t$hostname" > /etc/hosts

useradd -m -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd
echo "root:$password" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable NetworkManager

if [ "$boot_mode" = "UEFI" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    grub-install --target=i386-pc "$disk"
fi

grub-mkconfig -o /boot/grub/grub.cfg
EOF

# Done
echo -e "\nInstallation complete! You can reboot now."
