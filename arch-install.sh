#!/bin/bash

# Установим зависимости
sudo pacman -Syu --needed --noconfirm \
  base-devel git cmake meson ninja \
  wayland wayland-protocols \
  libxkbcommon libinput libxcb xcb-util \
  pixman xcb-util-image xcb-util-wm \
  cairo pango \
  gtk3 \
  vulkan-headers vulkan-icd-loader \
  glslang \
  libdrm libcap \
  systemd \
  xwayland \
  hyprland \
  waybar \
  kitty \
  xdg-desktop-portal xdg-desktop-portal-hyprland \
  ttf-font-awesome noto-fonts \
  network-manager-applet \
  pipewire wireplumber \
  sddm

# Клонируем репозиторий Hyprland
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland || exit 1

# Создаем build директорию
mkdir build
cd build || exit 1

# Генерация сборки и установка
cmake ..
make -j$(nproc)
sudo make install
