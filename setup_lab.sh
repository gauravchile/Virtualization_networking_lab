#!/bin/bash
# ===============================================
# setup_lab.sh
# Auto setup Web, DB, or DNS server for lab
# Works on Debian/Ubuntu & RHEL/CentOS/Rocky
# Usage: sudo ./setup_lab.sh <role>
# Roles: web | db | dns
# ===============================================

set -euo pipefail

ROLE=${1:-}

if [ -z "$ROLE" ]; then
  echo "Usage: $0 <web|db|dns>"
  exit 1
fi

# Detect OS family (debian or rhel)
if [ -f /etc/debian_version ]; then
  OS_FAMILY="debian"
  PKG_UPDATE="apt update -y"
  PKG_INSTALL="apt install -y"
elif [ -f /etc/redhat-release ]; then
  OS_FAMILY="rhel"
  PKG_UPDATE="yum -y update"
  PKG_INSTALL="yum -y install"
else
  echo "[!] Unsupported OS"
  exit 1
fi

# ========== Web Server ==========
install_web() {
  echo "[*] Setting up Web Server..."
  if [ "$OS_FAMILY" = "debian" ]; then
    $PKG_UPDATE &>/dev/null
    $PKG_INSTALL apache2 curl &>/dev/null
    systemctl enable --now apache2
    echo "<h1>Welcome to Web Server</h1>" > /var/www/html/index.html
  else
    $PKG_UPDATE &>/dev/null
    $PKG_INSTALL httpd curl &>/dev/null
    systemctl enable --now httpd
    echo "<h1>Welcome to Web Server</h1>" > /var/www/html/index.html
  fi
  echo "[+] Web server configured!"
}

test_web() {
  echo "[*] Testing Web server..."
  curl -s http://localhost | grep "Welcome" && echo "[+] Web test OK" || echo "[!] Web test FAILED"
}

# ========== Database Server ==========
install_db() {
  echo "[*] Setting up Database Server..."
  if [ "$OS_FAMILY" = "debian" ]; then
    $PKG_UPDATE &>/dev/null
    DEBIAN_FRONTEND=noninteractive $PKG_INSTALL mysql-server &>/dev/null
    systemctl enable --now mysql
    mysql -e "CREATE DATABASE labdb;"
    mysql -e "CREATE USER 'labuser'@'%' IDENTIFIED BY 'labpass';"
    mysql -e "GRANT ALL PRIVILEGES ON labdb.* TO 'labuser'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
  else
    $PKG_UPDATE &>/dev/null
    $PKG_INSTALL mariadb-server &>/dev/null
    systemctl enable --now mariadb
    mysql -e "CREATE DATABASE labdb;"
    mysql -e "CREATE USER 'labuser'@'%' IDENTIFIED BY 'labpass';"
    mysql -e "GRANT ALL PRIVILEGES ON labdb.* TO 'labuser'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
  fi
  echo "[+] DB server configured!"
}

test_db() {
  echo "[*] Testing DB server..."
  mysql -ulabuser -plabpass -e "SHOW DATABASES;" | grep labdb && echo "[+] DB test OK" || echo "[!] DB test FAILED"
}

# ========== DNS Server ==========
install_dns() {
  echo "[*] Setting up DNS Server..."

  # Detect OS family
  if [ -f /etc/debian_version ]; then
    OS_FAMILY="debian"
    PKG_UPDATE="apt update -y"
    PKG_INSTALL="apt install -y"
  elif [ -f /etc/redhat-release ]; then
    OS_FAMILY="rhel"
    PKG_UPDATE="yum -y update"
    PKG_INSTALL="yum -y install"
  else
    echo "[!] Unsupported OS"
    exit 1
  fi

  if [ "$OS_FAMILY" = "debian" ]; then
    $PKG_UPDATE &>/dev/null
    $PKG_INSTALL bind9 bind9-utils dnsutils &>/dev/null
    CONF_FILE="/etc/bind/named.conf.options"

    mkdir -p /var/cache/bind

    cat > $CONF_FILE <<EOF
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 8.8.8.8; 1.1.1.1; };
    dnssec-validation no;
    listen-on { any; };
};
EOF

  elif [ "$OS_FAMILY" = "rhel" ]; then
    $PKG_UPDATE &>/dev/null
    $PKG_INSTALL bind bind-utils &>/dev/null
    CONF_FILE="/etc/named.conf"

    cat > $CONF_FILE <<EOF
options {
    directory "/var/named";
    recursion yes;
    allow-query { any; };
    forwarders { 8.8.8.8; 1.1.1.1; };
    dnssec-enable no;
    listen-on port 53 { any; };
};
EOF
    chown named:named /var/named
    restorecon -rv /var/named
  fi

  # Reload systemd and enable service
  systemctl daemon-reload
  systemctl enable --now named.service

  echo "[+] DNS server configured!"
}

test_dns() {
  echo "[*] Testing DNS server..."
  dig @localhost google.com +short | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" \
    && echo "[+] DNS test OK" \
    || { echo "[!] DNS test FAILED"; systemctl status named.service --no-pager; }
}

# ========== Main ==========
case "$ROLE" in
  web) install_web; test_web ;;
  db)  install_db; test_db ;;
  dns) install_dns; test_dns ;;
  *)   echo "Invalid role: $ROLE (use web|db|dns)" ;;
esac

