#!/data/data/com.termux/files/usr/bin/bash

export TERM=xterm-256color

USER="aripin-ilham"
REPO="mai-aamp"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH"

CYAN="\033[1;36m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

clear

# =========================
# Boot Animation
# =========================
boot(){
  clear
  echo -e "${CYAN}"
  echo "======================================="
  echo "        AAMP MAI INSTALLER v6"
  echo "======================================="
  echo -e "${RESET}"
  sleep 1
}

# =========================
# Spinner
# =========================
spinner(){
  local pid=$!
  local spin='|/-\'
  local i=0
  tput civis
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${CYAN}Processing %s${RESET}" "${spin:$i:1}"
    sleep 0.1
  done
  printf "\r"
  tput cnorm
}

# =========================
# Disk Check
# =========================
check_disk(){
  FREE=$(df /data | awk 'NR==2 {print $4}')
  FREE_MB=$((FREE/1024))

  if [ "$FREE_MB" -lt 800 ]; then
    echo -e "${RED}Disk space too low! Minimum 800MB required.${RESET}"
    exit 1
  fi

  echo -e "${GREEN}Disk OK: ${FREE_MB}MB free${RESET}"
}

# =========================
# RAM Detect
# =========================
detect_ram(){
  RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  RAM_MB=$((RAM_KB/1024))

  echo -e "${GREEN}Detected RAM: ${RAM_MB}MB${RESET}"
}

# =========================
# Install Packages (Silent)
# =========================
install_packages(){
(
  pkg update -y >/dev/null 2>&1
  pkg upgrade -y >/dev/null 2>&1
  pkg install php-apache mariadb curl unzip -y >/dev/null 2>&1
) &
spinner
}

# =========================
# Download Files
# =========================
download_files(){

  termux-setup-storage >/dev/null 2>&1

  mkdir -p /storage/emulated/0/htdocs
  cd /storage/emulated/0/htdocs || exit

  echo -e "${CYAN}Downloading Web Files...${RESET}"

  curl -s -L "$BASE/web/index.php" -o index.php
  curl -s -L "$BASE/web/phpinfo.php" -o phpinfo.php
  curl -s -L "$BASE/web/phpmyadmin.zip" -o phpmyadmin.zip

  unzip -o phpmyadmin.zip >/dev/null 2>&1
  mv phpMyAdmin* phpmyadmin
  rm phpmyadmin.zip

  # config.inc.php dari root repo
  curl -s -L "$BASE/config.inc.php" -o phpmyadmin/config.inc.php

  # httpd-mai.conf dari root repo
  curl -s -L "$BASE/httpd-mai.conf" -o $PREFIX/etc/apache2/httpd.conf
}

# =========================
# Install MAI Menu
# =========================
install_menu(){
  curl -s -L "$BASE/mai" -o $PREFIX/bin/mai
  chmod +x $PREFIX/bin/mai
}

# =========================
# MAIN
# =========================
boot
check_disk
detect_ram

echo -e "${CYAN}Installing Packages...${RESET}"
install_packages

download_files
install_menu

echo ""
echo -e "${GREEN}AAMP MAI Installed Successfully.${RESET}"
echo -e "${CYAN}Type: mai${RESET}"
echo -e "${CYAN}Open: http://localhost:8080${RESET}"
echo ""
