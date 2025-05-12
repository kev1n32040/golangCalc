#!/bin/bash
set -e

echo "==> Обновление ключей..."
sudo pacman-key --init || true
sudo pacman-key --populate archlinux || true
sudo pacman -Sy archlinux-keyring --noconfirm || true

echo "==> Установка зависимостей..."
sudo pacman -Syu --noconfirm || true
sudo pacman -S --noconfirm git base-devel xdg-desktop-portal xdg-desktop-portal-hyprland pipewire wireplumber \
    polkit xdg-utils grim slurp wl-clipboard wf-recorder waybar rofi \
    firefox neovim network-manager-applet blueman gvfs gvfs-mtp \
    hyprpaper thunar pavucontrol sddm || true

echo "==> Добавление репозитория Hyprland..."
sudo bash -c 'cat > /etc/pacman.conf <<EOF
[options]
HoldPkg     = pacman glibc
Architecture = auto
Color
CheckSpace
ParallelDownloads = 5
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

[hyprland]
Server = https://repo.hyprland.org
SigLevel = Optional TrustAll
EOF'

echo "==> Установка Hyprland..."
sudo pacman -Syu hyprland --noconfirm || true

echo "==> Настройка SDDM..."
sudo systemctl enable sddm

echo "==> Установка завершена! Теперь можно перезагрузиться."
