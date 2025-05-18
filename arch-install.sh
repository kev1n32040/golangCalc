#!/bin/bash

set -e

# === Настройки ===
REPO_URL="https://github.com/hyprwm/Hyprland.git"
REPO_DIR="$HOME/Hyprland"
LOG_FILE="$HOME/hyprland_install.log"

# === Проверка наличия Hyprland ===
if command -v Hyprland >/dev/null 2>&1; then
    echo "[INFO] Hyprland уже установлен. Переустанавливаем..." | tee -a "$LOG_FILE"
    rm -rf "$REPO_DIR"
else
    echo "[INFO] Устанавливаем Hyprland впервые..." | tee -a "$LOG_FILE"
fi

# === Установка зависимостей ===
echo "[INFO] Установка зависимостей..." | tee -a "$LOG_FILE"
sudo apt update && sudo apt install -y \
  build-essential cmake meson git \
  wayland-protocols libwayland-dev libxkbcommon-dev libpixman-1-dev \
  libegl-dev libglvnd-dev libdrm-dev libvulkan-dev \
  libxcb1-dev libxcb-composite0-dev libxcb-xfixes0-dev \
  libxcb-image0-dev libxcb-render0-dev libxcb-icccm4-dev \
  libxcb-util0-dev libxcb-cursor-dev libx11-xcb-dev \
  libxrender-dev libxext-dev libx11-dev \
  ninja-build pkg-config python3-pip \
  libinput-dev libudev-dev libseat-dev libxcb-ewmh-dev \
  libpam0g-dev libdbus-1-dev libsystemd-dev

# === Клонирование репозитория ===
echo "[INFO] Клонируем репозиторий Hyprland..." | tee -a "$LOG_FILE"
git clone --recursive "$REPO_URL" "$REPO_DIR"
cd "$REPO_DIR"

# === Сборка Hyprland ===
echo "[INFO] Сборка Hyprland..." | tee -a "$LOG_FILE"
make all | tee -a "$LOG_FILE"
sudo make install | tee -a "$LOG_FILE"

# === Завершение ===
echo "[DONE] Hyprland установлен/переустановлен успешно!" | tee -a "$LOG_FILE"
