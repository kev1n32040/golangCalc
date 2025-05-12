#!/bin/bash

# Обновляем систему
sudo pacman -Syu --noconfirm

# Устанавливаем Hyprland и окружение
sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland xdg-utils \
    wayland wlroots kitty thunar pipewire wireplumber \
    ttf-font-awesome ttf-jetbrains-mono ttf-nerd-fonts-symbols \
    network-manager-applet waybar wofi mako grim slurp swappy \
    polkit-gnome

# Копируем конфиги Hyprland
mkdir -p ~/.config/hypr
cp -r /etc/xdg/hypr/* ~/.config/hypr/

# Создаём .xinitrc с запуском Hyprland
echo "exec Hyprland" > ~/.xinitrc

# Создаём базовый конфиг для уведомлений
mkdir -p ~/.config/mako
cat <<EOF > ~/.config/mako/config
background-color=#1e1e2e
text-color=#ffffff
border-color=#89b4fa
EOF

# Сообщение о завершении
echo "Hyprland и окружение установлены. Используй 'Hyprland' или 'startx' для запуска."
