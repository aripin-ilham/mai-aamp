#!/data/data/com.termux/files/usr/bin/bash

export TERM=xterm-256color

USER="aripin-ilham"
REPO="mai-aamp"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH"

VERSION_URL="$BASE/VERSION"

CYAN="\033[1;36m"
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

PREFIX=/data/data/com.termux/files/usr
HTDOCS=/storage/emulated/0/htdocs

clear

boot(){
echo -e "${CYAN}"
echo "======================================="
echo "      AAMP MAI v8 ULTIMATE EDITION"
echo "======================================="
echo -e "${RESET}"
sleep 1
}

spinner(){
local pid=$!
local spin='|/-\'
local i=0
while kill -0 $pid 2>/dev/null; do
  i=$(( (i+1) %4 ))
  printf "\r${CYAN}Processing %s${RESET}" "${spin:$i:1}"
  sleep 0.1
done
printf "\r"
}

check_disk(){
FREE=$(df /data | awk 'NR==2 {print $4}')
FREE_MB=$((FREE/1024))
if [ "$FREE_MB" -lt 800 ]; then
  echo -e "${RED}Disk space too low (min 800MB).${RESET}"
  exit 1
fi
echo -e "${GREEN}Disk OK: ${FREE_MB}MB free${RESET}"
}

detect_hardware(){
RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_MB=$((RAM/1024))
CPU=$(nproc 2>/dev/null || echo 1)
echo -e "${GREEN}RAM: ${RAM_MB}MB | CPU: ${CPU} Core${RESET}"
}

install_packages(){
(
pkg update -y >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1
pkg install php-apache mariadb curl unzip -y >/dev/null 2>&1
) &
spinner
}

download_files(){
mkdir -p "$HTDOCS"
cd "$HTDOCS" || exit

curl -s -L "$BASE/web/index.php" -o index.php
curl -s -L "$BASE/web/phpinfo.php" -o phpinfo.php
curl -s -L "$BASE/web/phpmyadmin.zip" -o phpmyadmin.zip

unzip -o phpmyadmin.zip >/dev/null 2>&1
mv phpMyAdmin* phpmyadmin 2>/dev/null
rm phpmyadmin.zip

curl -s -L "$BASE/config.inc.php" -o phpmyadmin/config.inc.php
curl -s -L "$BASE/httpd-mai.conf" -o "$PREFIX/etc/apache2/httpd.conf"
}

install_menu(){
curl -s -L "$BASE/mai" -o "$PREFIX/bin/mai"
chmod +x "$PREFIX/bin/mai"
}

boot
check_disk
detect_hardware
echo -e "${CYAN}Installing Packages...${RESET}"
install_packages
download_files
install_menu

echo -e "${GREEN}AAMP MAI v8 Installed.${RESET}"
echo -e "${CYAN}Type: mai${RESET}"
