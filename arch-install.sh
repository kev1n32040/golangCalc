#!/bin/bash

echo "🔧 Установка необходимых пакетов..."
sudo pacman -S --noconfirm hyprland kitty waybar wofi network-manager-applet pipewire pipewire-pulse wireplumber \
xdg-desktop-portal-hyprland xdg-desktop-portal swaybg qt5-wayland qt6-wayland gtk3 \
ttf-font-awesome noto-fonts

echo "📁 Создание конфигураций..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi
mkdir -p ~/.config/autostart

# Установка обоев
mkdir -p ~/Pictures
curl -L -o ~/Pictures/wallpaper.jpg https://picsum.photos/1920/1080

# Генерация базового hyprland.conf
cat > ~/.config/hypr/hyprland.conf <<EOF
# ~/.config/hypr/hyprland.conf

# Основные настройки
monitor=,preferred,auto,1
exec-once = swaybg -i ~/Pictures/wallpaper.jpg -m fill
exec-once = waybar
exec-once = nm-applet
exec-once = wofi --show drun

# Курсор
env = XCURSOR_SIZE,24
exec-once = hyprctl setcursor Bibata-Modern-Ice 24

# Клавиши
bind = SUPER, Q, exec, kitty
bind = SUPER, M, exit,

# Фокус по наведению
misc {
  focus_on_activate = true
}

EOF

# Конфигурация Waybar (пустая, но работает)
cat > ~/.config/waybar/config <<EOF
{
    "layer": "top",
    "position": "top",
    "modules-left": ["clock"],
    "clock": {
        "format": "{:%H:%M:%S}"
    }
}
EOF

# Wofi конфиг (по умолчанию)
cat > ~/.config/wofi/config <<EOF
prompt=Search...
EOF

# Включаем NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Перезапуск xdg-desktop-portal
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland

echo "✅ Установка и настройка завершена."
echo "🔁 Перезапусти Hyprland командой: Hyprland"
