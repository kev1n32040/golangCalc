#!/bin/bash

set -e

echo "🔧 Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo "📦 Установка зависимостей..."
sudo apt install -y \
  build-essential cmake meson ninja-build git curl wget unzip \
  libwayland-dev libxkbcommon-dev libxkbcommon-x11-dev wayland-protocols \
  libegl1-mesa-dev libgles2-mesa-dev libdrm-dev libgbm-dev libinput-dev \
  libxcb1-dev libxcb-composite0-dev libxcb-xfixes0-dev libpixman-1-dev \
  libudev-dev libseat-dev libxcb-ewmh-dev libxcb-icccm4-dev \
  libxcb-image0-dev libxcb-util0-dev libxcb-randr0-dev libxcb-xinerama0-dev \
  libxcb-xkb-dev libglm-dev libvulkan-dev vulkan-utils \
  xdg-desktop-portal xdg-desktop-portal-wlr wl-clipboard \
  grim slurp wofi waybar foot mako swww

echo "📁 Клонирование Hyprland..."
git clone https://github.com/hyprwm/Hyprland.git --recursive
cd Hyprland

echo "⚙️ Сборка Hyprland..."
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
cd ../..

echo "📁 Создание конфигурации..."
mkdir -p ~/.config/hypr
cp -r Hyprland/example/* ~/.config/hypr/

echo "🖼 Установка обоев и стилей (swww, themes)..."
mkdir -p ~/Pictures/wallpapers
wget -O ~/Pictures/wallpapers/default.jpg https://w.wallhaven.cc/full/6o/wallhaven-6owq7q.jpg

cat <<EOF > ~/.config/hypr/hyprland.conf
source=~/.config/hypr/conf/main.conf
EOF

mkdir -p ~/.config/hypr/conf

cat <<EOF > ~/.config/hypr/conf/main.conf
exec-once = swww-daemon & swww img ~/Pictures/wallpapers/default.jpg
exec-once = waybar &
exec-once = foot &
exec-once = mako
exec-once = wofi --show drun

monitor=,preferred,auto,1
EOF

echo "📥 Установка Hyprland завершена."
echo "🖥 Выйдите в TTY (Ctrl+Alt+F2), войдите и запустите Hyprland командой:"
echo
echo "    Hyprland"
