#!/bin/bash

set -e

echo "🔧 Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo "📦 Установка зависимостей через APT..."
sudo apt install -y \
  build-essential cmake meson ninja-build git curl wget unzip \
  libwayland-dev libxkbcommon-dev libxkbcommon-x11-dev wayland-protocols \
  libegl1-mesa-dev libgles2-mesa-dev libdrm-dev libgbm-dev libinput-dev \
  libxcb1-dev libxcb-composite0-dev libxcb-xfixes0-dev libpixman-1-dev \
  libudev-dev libseat-dev libxcb-ewmh-dev libxcb-icccm4-dev \
  libxcb-image0-dev libxcb-util0-dev libxcb-randr0-dev libxcb-xinerama0-dev \
  libxcb-xkb-dev libglm-dev libvulkan-dev vulkan-tools \
  xdg-desktop-portal xdg-desktop-portal-wlr wl-clipboard \
  grim slurp wofi waybar foot \
  cargo libgtk-3-dev libpango1.0-dev libevdev-dev \
  libgdk-pixbuf2.0-dev libdbus-1-dev libcairo2-dev libglib2.0-dev

echo "🧱 Сборка mako..."
git clone https://github.com/emersion/mako.git
cd mako
meson build
ninja -C build
sudo ninja -C build install
cd ..
rm -rf mako

echo "🧱 Сборка swww..."
git clone https://github.com/Lioness100/swww.git
cd swww
cargo build --release
sudo cp target/release/swww* /usr/local/bin/
cd ..
rm -rf swww

echo "📁 Клонирование Hyprland..."
git clone https://github.com/hyprwm/Hyprland.git --recursive
cd Hyprland
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
cd ../..
rm -rf Hyprland

echo "📁 Создание конфигурации..."
mkdir -p ~/.config/hypr
cat <<EOF > ~/.config/hypr/hyprland.conf
exec-once = swww-daemon & swww img ~/Pictures/wallpapers/default.jpg
exec-once = waybar &
exec-once = foot &
exec-once = mako
exec-once = wofi --show drun

monitor=,preferred,auto,1
EOF

echo "🌄 Загрузка обоев..."
mkdir -p ~/Pictures/wallpapers
wget -O ~/Pictures/wallpapers/default.jpg https://w.wallhaven.cc/full/6o/wallhaven-6owq7q.jpg

echo
echo "✅ Установка завершена."
echo "➡ Выйдите в TTY (Ctrl+Alt+F3), войдите и запустите Hyprland командой:"
echo
echo "    Hyprland"
