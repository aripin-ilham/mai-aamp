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
clear
echo -e "${CYAN}"

echo "███╗   ███╗ █████╗ ██╗"
echo "████╗ ████║██╔══██╗██║"
echo "██╔████╔██║███████║██║"
echo "██║╚██╔╝██║██╔══██║██║"
echo "██║ ╚═╝ ██║██║  ██║██║"
echo "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝"

echo ""
echo "======================================="
echo "      AAMP MAI v8 ULTIMATE EDITION"
echo "======================================="
echo -e "${RESET}"

sleep 1

echo -e "${CYAN}Initializing Cyber Core...${RESET}"
sleep 0.4
echo -e "${CYAN}Injecting Neon Modules...${RESET}"
sleep 0.4
echo -e "${CYAN}Mounting Apache Engine...${RESET}"
sleep 0.4
echo -e "${CYAN}Binding MariaDB Kernel...${RESET}"
sleep 0.4
echo -e "${GREEN}System Ready ✔${RESET}"
sleep 0.6
echo ""
}

progress_bar(){
  local pid=$1
  local percent=0

  while kill -0 $pid 2>/dev/null; do
    percent=$((percent+2))
    if [ $percent -gt 98 ]; then percent=98; fi

    filled=$((percent/2))
    empty=$((50-filled))

    printf "\r${CYAN}Downloading Packages ["
    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s " $(seq 1 $empty)
    printf "] ${GREEN}%3d%%${RESET}" "$percent"

    sleep 0.2
  done

  printf "\r${CYAN}Downloading Packages ["
  printf "%0.s█" $(seq 1 50)
  printf "] ${GREEN}100%%${RESET}\n"
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

PID=$!
progress_bar $PID
wait $PID
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

echo "Installing MAI command..."

curl -fsSL https://raw.githubusercontent.com/aripin-ilham/mai-aamp/main/mai -o mai.tmp
tr -d '\r' < mai.tmp > mai.fixed
echo "#!/data/data/com.termux/files/usr/bin/bash" > "$PREFIX/bin/mai"
tail -n +2 mai.fixed >> "$PREFIX/bin/mai"
chmod +x "$PREFIX/bin/mai"
rm -f mai.tmp mai.fixed

echo "MAI command installed safely."

boot

echo -e "${YELLOW}Pilih opsi:${RESET}"
echo "1) Lanjut Install AAMP MAI"
echo "2) Batal"
echo ""
read -p "Masukkan pilihan: " choice

if [ "$choice" != "1" ]; then
  echo -e "${RED}Instalasi dibatalkan.${RESET}"
  exit 0
fi

check_disk
detect_hardware
echo -e "${CYAN}Installing Packages...${RESET}"
install_packages
download_files

echo -e "${GREEN}AAMP MAI v8 Installed.${RESET}"
echo -e "${CYAN}Type: mai${RESET}"
