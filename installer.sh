#!/data/data/com.termux/files/usr/bin/bash
clear

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

REPO="https://raw.githubusercontent.com/aripin-ilham/mai-aamp/main"

banner(){
echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║        ⚡ MAI AAMP CYBER OS ⚡        ║"
echo "║     Muhammad Aripin Interface        ║"
echo "╚══════════════════════════════════════╝"
echo -e "${RESET}"
}

progress_bar(){
  echo -ne "${GREEN}"
  for i in {1..40}; do
    printf "█"
    sleep 0.03
  done
  echo -e "${RESET}"
}

boot_animation(){
clear
echo -e "${CYAN}Initializing Cyber Core...${RESET}"
sleep 0.5
echo -e "${CYAN}Loading Neon Modules...${RESET}"
sleep 0.5
echo -e "${CYAN}Bypassing Firewall...${RESET}"
sleep 0.5
echo -e "${GREEN}Access Granted.${RESET}"
sleep 1
}

banner
echo "1) Install AAMP MAI"
echo "2) Batal"
read -p "Pilih: " pilihan
[ "$pilihan" != "1" ] && exit

echo "Tekan 10 untuk melanjutkan instalasi:"
read lanjut
[ "$lanjut" != "10" ] && exit

boot_animation

echo -e "${YELLOW}Installing packages...${RESET}"
progress_bar

pkg update -y && pkg upgrade -y
pkg install php php-apache mariadb curl unzip -y

termux-setup-storage || true
mkdir -p /storage/emulated/0/htdocs

cd /storage/emulated/0/htdocs

echo -e "${CYAN}Downloading MAI files...${RESET}"
progress_bar

curl -fsSLO $REPO/web/index.php
curl -fsSLO $REPO/web/phpinfo.php
curl -fsSLO $REPO/web/phpmyadmin.zip
curl -fsSLo ~/httpd_mai.conf $REPO/httpd_mai.conf

unzip -o phpmyadmin.zip >/dev/null 2>&1
rm phpmyadmin.zip

mysql_install_db 2>/dev/null || true
cp ~/httpd_mai.conf $PREFIX/etc/apache2/httpd.conf

mysqld >/dev/null 2>&1 &
sleep 2
apachectl start >/dev/null 2>&1

echo -e "${GREEN}Membuat control menu MAI...${RESET}"

cat > $PREFIX/bin/mai << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

check_mysql(){
  if pgrep -f mysqld >/dev/null || pgrep -f mariadbd >/dev/null; then
    echo -e "${GREEN}RUNNING${RESET}"
  else
    echo -e "${RED}STOPPED${RESET}"
  fi
}

check_apache(){
  if pgrep -f httpd >/dev/null; then
    echo -e "${GREEN}RUNNING${RESET}"
  else
    echo -e "${RED}STOPPED${RESET}"
  fi
}

stop_mysql(){
  pkill mysqld 2>/dev/null
  pkill mariadbd 2>/dev/null
  sleep 1
}

uninstall(){
  echo "Ketik HAPUS untuk konfirmasi uninstall:"
  read confirm
  if [ "$confirm" = "HAPUS" ]; then
    stop_mysql
    apachectl stop
    pkg uninstall php php-apache mariadb -y
    rm -rf /storage/emulated/0/htdocs
    rm -f $PREFIX/bin/mai
    echo "AAMP berhasil dihapus."
    exit 0
  fi
}

while true; do
  clear
  echo -e "${CYAN}====== MAI AAMP CONTROL ======${RESET}"
  echo "MySQL  : $(check_mysql)"
  echo "Apache : $(check_apache)"
  echo
  echo "1) Start Apache"
  echo "2) Start MySQL"
  echo "3) Start Semua"
  echo "4) Stop Apache"
  echo "5) Stop MySQL"
  echo "6) Stop Semua"
  echo "7) Uninstall AAMP"
  echo "8) Exit"
  echo
  read -p "Pilih: " pilih

  case $pilih in
    1) apachectl start ;;
    2) mysqld >/dev/null 2>&1 & ;;
    3) mysqld >/dev/null 2>&1 &; sleep 2; apachectl start ;;
    4) apachectl stop ;;
    5) stop_mysql ;;
    6) stop_mysql; apachectl stop ;;
    7) uninstall ;;
    8) exit 0 ;;
  esac

  sleep 2
done
EOF

chmod +x $PREFIX/bin/mai

echo -e "${GREEN}Instalasi selesai.${RESET}"
progress_bar

echo "Installer akan dihapus..."
sleep 1
rm -- "$0"

echo "Masuk ke menu MAI..."
sleep 1


mai
