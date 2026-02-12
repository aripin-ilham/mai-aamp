#!/data/data/com.termux/files/usr/bin/bash

clear

# ===== CYBER BOOT =====
echo "Initializing Cyber Core..."
sleep 1
echo "Loading Neon Modules..."
sleep 1
echo "Bypassing Firewall..."
sleep 1
echo "Access Granted."
sleep 1
clear

# ===== SPINNER =====
spinner() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r🚀 Installing AAMP MAI... ${spin:$i:1}"
        sleep .1
    done
    printf "\r✅ Installation Complete!     \n"
}

# ===== INSTALL PACKAGES (SILENT) =====
(
pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1
pkg install php-apache mariadb curl unzip -y > /dev/null 2>&1
) &

spinner

clear

# ===== STORAGE SETUP =====
if [ ! -d "/storage/emulated/0" ]; then
    termux-setup-storage > /dev/null 2>&1
fi

mkdir -p /storage/emulated/0/htdocs
cd /storage/emulated/0/htdocs || exit

# ===== DOWNLOAD FILES =====
echo "Downloading MAI Dashboard..."
curl -fsSL https://raw.githubusercontent.com/aripin-ilham/mai-aamp/main/web/index.php -o index.php > /dev/null 2>&1
curl -fsSL https://raw.githubusercontent.com/aripin-ilham/mai-aamp/main/web/phpinfo.php -o phpinfo.php > /dev/null 2>&1

# ===== CONFIG APACHE =====
cp $HOME/../usr/etc/apache2/httpd.conf $HOME/httpd.backup 2>/dev/null
curl -fsSL https://raw.githubusercontent.com/aripin-ilham/mai-aamp/main/httpd_mai.conf -o $PREFIX/etc/apache2/httpd.conf > /dev/null 2>&1

# ===== INIT DATABASE =====
if [ ! -d "$PREFIX/var/lib/mysql/mysql" ]; then
    mariadb-install-db > /dev/null 2>&1
fi

# ===== CREATE CONTROL MENU =====
cat > $PREFIX/bin/mai << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

status() {
    MYSQL=$(pgrep mysqld)
    APACHE=$(pgrep httpd)

    echo "========== STATUS SERVICE =========="
    if [ -n "$MYSQL" ]; then
        echo -e "MySQL  : \033[32mRUNNING\033[0m"
    else
        echo -e "MySQL  : \033[31mSTOPPED\033[0m"
    fi

    if [ -n "$APACHE" ]; then
        echo -e "Apache : \033[32mRUNNING\033[0m"
    else
        echo -e "Apache : \033[31mSTOPPED\033[0m"
    fi
    echo "===================================="
}

while true; do
clear
status
echo
echo "===== AAMP CONTROL MENU ====="
echo "1) Start Apache"
echo "2) Start MySQL"
echo "3) Start All"
echo "4) Stop All"
echo "5) Exit"
echo
read -p "Choose: " opt

case $opt in
1)
apachectl start > /dev/null 2>&1
;;
2)
mysqld_safe > /dev/null 2>&1 &
;;
3)
mysqld_safe > /dev/null 2>&1 &
sleep 2
apachectl start > /dev/null 2>&1
;;
4)
pkill mysqld > /dev/null 2>&1
apachectl stop > /dev/null 2>&1
;;
5)
exit
;;
esac
sleep 2
done
EOF

chmod +x $PREFIX/bin/mai

clear
echo "████████████████████████████████████████"
echo "🚀 AAMP MAI Installed Successfully!"
echo "Type: mai"
echo "Open: http://localhost:8080"
echo "████████████████████████████████████████"

sleep 3

rm -- "$0"
