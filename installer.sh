#!/data/data/com.termux/files/usr/bin/bash

clear

PREFIX=/data/data/com.termux/files/usr
HTDOCS=/storage/emulated/0/htdocs
REPO=https://raw.githubusercontent.com/aripin-ilham/mai-aamp/main

banner(){
clear
echo "==========================================="
echo "        AAMP MAI INSTALLER v3.0"
echo "==========================================="
}

loading(){
echo -ne "Installing AAMP MAI... "
for i in {1..40}; do
    echo -ne "█"
    sleep 0.03
done
echo ""
}

banner
read -p "Yakin ingin install AAMP MAI? (y/n): " confirm
[ "$confirm" != "y" ] && exit

loading

# Silent update
pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1

# Install packages silently
pkg install php php-apache mariadb curl unzip -y > /dev/null 2>&1

# Storage setup
termux-setup-storage > /dev/null 2>&1
mkdir -p $HTDOCS

# Download dashboard
cd $HTDOCS || exit

curl -fsSL $REPO/web/index.php -o index.php > /dev/null 2>&1
curl -fsSL $REPO/web/phpinfo.php -o phpinfo.php > /dev/null 2>&1
curl -fsSL $REPO/web/phpmyadmin.zip -o phpmyadmin.zip > /dev/null 2>&1

# Extract phpMyAdmin
unzip -o phpmyadmin.zip > /dev/null 2>&1

PMFOLDER=$(ls -d phpMyAdmin* 2>/dev/null | head -n 1)
if [ -n "$PMFOLDER" ]; then
    mv "$PMFOLDER" phpmyadmin
fi

rm -f phpmyadmin.zip

# Create phpMyAdmin config
cat > phpmyadmin/config.inc.php <<EOF
<?php
\$cfg['blowfish_secret'] = 'mai_secure_key_123';
\$i = 0;
\$i++;
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['connect_type'] = 'tcp';
\$cfg['Servers'][\$i]['AllowNoPassword'] = true;
EOF

# Replace httpd.conf
curl -fsSL $REPO/httpd_mai.conf -o $PREFIX/etc/apache2/httpd.conf > /dev/null 2>&1

# Create global command mai
cat > $PREFIX/bin/mai <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

apache_status(){
pgrep httpd >/dev/null && echo -e "Apache : \033[32mRUNNING\033[0m" || echo -e "Apache : \033[31mSTOPPED\033[0m"
}

mysql_status(){
pgrep mysqld >/dev/null && echo -e "MySQL  : \033[32mRUNNING\033[0m" || echo -e "MySQL  : \033[31mSTOPPED\033[0m"
}

menu(){
clear
echo "========== AAMP MAI CONTROL =========="
apache_status
mysql_status
echo "======================================="
echo "1) Start Apache"
echo "2) Start MySQL"
echo "3) Start All"
echo "4) Stop All"
echo "5) Restart All"
echo "6) Exit"
echo "======================================="
read -p "Pilih: " opt

case $opt in
1) apachectl start ;;
2) mysqld >/dev/null 2>&1 & ;;
3) mysqld >/dev/null 2>&1 & sleep 2; apachectl start ;;
4) pkill mysqld >/dev/null 2>&1; apachectl stop ;;
5) pkill mysqld >/dev/null 2>&1; apachectl stop; mysqld >/dev/null 2>&1 & sleep 2; apachectl start ;;
6) exit ;;
*) menu ;;
esac

sleep 2
menu
}

menu
EOF

chmod +x $PREFIX/bin/mai

# Init MariaDB
mariadb-install-db > /dev/null 2>&1

clear
echo "==========================================="
echo "      INSTALASI SELESAI 🚀"
echo "==========================================="
echo "Dashboard  : http://localhost:8080"
echo "phpMyAdmin : http://localhost:8080/phpmyadmin"
echo ""
echo "Ketik: mai"
echo "Untuk masuk ke Control Menu"
echo "==========================================="

sleep 3

rm -- "$0"
