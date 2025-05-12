#!/bin/bash

set -e

echo "== Проверка подключения к сети..."
if ! ping -c 1 archlinux.org &>/dev/null; then
    echo ">> Нет подключения. Запускаю dhcpcd..."
    sudo dhcpcd || { echo "× Не удалось подключиться к сети"; exit 1; }
fi

echo "== Обновление зеркал..."
if command -v reflector &>/dev/null; then
    sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || echo ">> Reflector не сработал, продолжаю..."
else
    echo ">> Reflector не установлен. Добавляю зеркала вручную..."
    sudo bash -c 'cat > /etc/pacman.d/mirrorlist' <<EOF
Server = https://mirror.yandex.ru/archlinux/\$repo/os/\$arch
Server = https://mirror.alpix.eu/archlinux/\$repo/os/\$arch
EOF
fi

echo "== Обновление базы пакетов..."
sudo pacman -Syyu --noconfirm || echo ">> Обновление с ошибками, продолжаю..."

echo "== Установка Hyprland и зависимостей..."
sudo pacman -S --noconfirm hyprland \
  xdg-desktop-portal-hyprland \
  waybar kitty thunar rofi dmenu foot \
  wl-clipboard brightnessctl playerctl grim slurp pavucontrol \
  network-manager-applet nm-connection-editor \
  sddm

echo "== Включение SDDM..."
sudo systemctl enable sddm.service

echo "== Создание пользователя (если нужно)..."
read -p "Введите имя пользователя: " USERNAME
if ! id "$USERNAME" &>/dev/null; then
    sudo useradd -m -G wheel -s /bin/bash "$USERNAME"
    sudo passwd "$USERNAME"
fi

echo "== Настройка конфигов Hyprland..."
sudo -u "$USERNAME" bash -c '
mkdir -p ~/.config/hypr
cp -r /etc/xdg/hypr/* ~/.config/hypr/*
