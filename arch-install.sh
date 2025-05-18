#!/bin/bash

set -e

# === Настройки ===
REPO_URL="https://github.com/hyprwm/Hyprland.git"
REPO_DIR="$HOME/Hyprland"
LOG_FILE="$HOME/hyprland_install.log"
REQUIRED_CMAKE_VERSION="3.30.0"

# === Функция сравнения версий ===
version_ge() {
  [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# === Проверка и обновление CMake ===
CURRENT_CMAKE_VERSION=$(cmake --version 2>/dev/null | head -n1 | awk '{print $3}' || echo "0")

if ! version_ge "$CURRENT_CMAKE_VERSION" "$REQUIRED_CMAKE_VERSION"; then
  echo "[INFO] Обновляем CMake с $CURRENT_CMAKE_VERSION до $REQUIRED_CMAKE_VERSION+..." | tee -a "$LOG_FILE"
  sudo apt remove --purge --auto-remove cmake -y
  sudo apt install -y wget tar

  cd /tmp
  wget https://github.com/Kitware/CMake/releases/latest/download/cmake-*-linux-x86_64.tar.gz -O cmake.tar.gz
  mkdir cmake && tar -xzf cmake.tar.gz -C cmake --strip-components=1
  sudo cp -r cmake/* /usr/local/
  cmake --version | tee -a "$LOG_FILE"
else
  echo "[INFO] Подходящая версия CMake найдена: $CURRENT_CMAKE_VERSION" | tee -a "$LOG_FILE"
fi

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

echo "[DONE] Hyprland успешно установлен или переустановлен!" | tee -a "$LOG_FILE"
