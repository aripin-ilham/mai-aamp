#!/data/data/com.termux/files/usr/bin/bash

PREFIX=/data/data/com.termux/files/usr
HTDOCS=/storage/emulated/0/htdocs

# ===== COLOR =====
RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ===== BOOT ANIMATION =====
boot_animation() {
clear
echo -e "${CYAN}"
echo "Initializing Cyber Core..."
sleep 0.6
echo "Loading Neon Modules..."
sleep 0.6
echo "Bypassing Firewall..."
sleep 1
echo -e "${GREEN}Access Granted.${RESET}"
sleep 1
clear
}

# ===== SPINNER =====
spinner() {
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${CYAN}Processing ${spin:$i:1}${RESET}"
    sleep .1
  done
  printf "\r"
}

# ===== PROGRESS BAR =====
progress_bar() {
  for i in {0..100}; do
    filled=$((i/2))
    empty=$((50-filled))
    printf "\rInstalling AAMP MAI... ["
    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s " $(seq 1 $empty)
    printf "] %3d%%" "$i"
    sleep 0.03
  done
  echo ""
}

# ===== INSTALL FUNCTION =====
install_aamp() {

boot_animation

echo -e "${CYAN}Installing packages...${RESET}"

(
pkg update -y >/dev/null 2>&1
pkg upgrade -y >/dev/null 2>&1
pkg install php-apache mariadb unzip -y >/dev/null 2>&1
) & spinner

progress_bar

termux-setup-storage >/dev/null 2>&1

mkdir -p $HTDOCS

echo "<?php phpinfo(); ?>" > $HTDOCS/phpinfo.php

# ===== CREATE MENU =====
cat > $PREFIX/bin/mai << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

status() {
echo "================ STATUS SERVICE ================"
pgrep mysqld >/dev/null && echo -e "MySQL  : ${GREEN}RUNNING${RESET}" || echo -e "MySQL  : ${RED}STOPPED${RESET}"
pgrep httpd >/dev/null && echo -e "Apache : ${GREEN}RUNNING${RESET}" || echo -e "Apache : ${RED}STOPPED${RESET}"
echo "================================================"
}

while true; do
clear
status
echo "============== AAMP CONTROL MENU =============="
echo "1) Aktifkan Apache"
echo "2) Aktifkan MySQL"
echo "3) Aktifkan Semua"
echo "4) Stop Semua"
echo "5) Uninstall AAMP"
echo "6) Exit"
echo "================================================"
read -p "Pilih: " pilih

case $pilih in
1) apachectl start ;;
2) mysqld >/dev/null 2>&1 & ;;
3) mysqld >/dev/null 2>&1 & sleep 2; apachectl start ;;
4) pkill mysqld; apachectl stop ;;
5)
   pkill mysqld
   apachectl stop
   pkg uninstall php-apache mariadb -y
   rm -rf /storage/emulated/0/htdocs
   rm /data/data/com.termux/files/usr/bin/mai
   echo "AAMP Removed."
   exit
   ;;
6) exit ;;
*) echo "Invalid"; sleep 1 ;;
esac
done
EOF

chmod +x $PREFIX/bin/mai

echo -e "${GREEN}"
echo "========================================"
echo "      AAMP MAI Installed Successfully"
echo "========================================"
echo -e "${RESET}"

sleep 1

echo "Launching MAI Menu..."
sleep 1
mai

rm -- "$0"
}

# ===== START =====
install_aamp
