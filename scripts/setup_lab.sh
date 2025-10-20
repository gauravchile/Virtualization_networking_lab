#!/bin/bash
# ============================================================
# setup_lab.sh
# Auto setup Web, DB, or DNS server for lab
# Works on Debian/Ubuntu & RHEL/CentOS/Rocky
# Usage: sudo ./setup_lab.sh <role>
# Roles: web | db | dns
# ============================================================

set -euo pipefail

ROLE=${1:-}

if [ -z "$ROLE" ]; then
  echo "Usage: $0 <web|db|dns>"
  exit 1
fi

# ----------------------------
# Spinner + percentage function
# ----------------------------
show_progress() {
    local msg=$1
    local duration=${2:-3}
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    local end_time=$((SECONDS + duration))
    local progress=0
    while [ $SECONDS -lt $end_time ]; do
        for f in "${frames[@]}"; do
            printf "\r%s  %s... %d%%" "$f" "$msg" "$progress"
            sleep 0.1
            progress=$((progress + RANDOM % 5))
            [ $progress -ge 99 ] && progress=99
        done
    done
    printf "\r✅  %s... 100%%\n" "$msg"
}

# ----------------------------
# Detect OS family
# ----------------------------
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

# ----------------------------
# Web Server
# ----------------------------
install_web() {
    show_progress "Installing Web Server" 4
    if [ "$OS_FAMILY" = "debian" ]; then
        $PKG_UPDATE &>/dev/null
        $PKG_INSTALL apache2 curl &>/dev/null
        systemctl enable --now apache2 &>/dev/null
        echo "<h1>Welcome to Web Server</h1>" > /var/www/html/index.html
    else
        $PKG_UPDATE &>/dev/null
        $PKG_INSTALL httpd curl &>/dev/null
        systemctl enable --now httpd &>/dev/null
        echo "<h1>Welcome to Web Server</h1>" > /var/www/html/index.html
    fi
    echo "✅ Web server configured!"
}

test_web() {
    show_progress "Testing Web Server" 2
    curl -s http://localhost | grep "Welcome" &>/dev/null && echo "✅ Web test OK" || echo "[!] Web test FAILED"
}

# ----------------------------
# Database Server
# ----------------------------
install_db() {
    show_progress "Installing DB Server" 5
    if [ "$OS_FAMILY" = "debian" ]; then
        DEBIAN_FRONTEND=noninteractive $PKG_INSTALL mysql-server &>/dev/null
        systemctl enable --now mysql &>/dev/null
        mysql -e "CREATE DATABASE labdb;"
        mysql -e "CREATE USER 'labuser'@'%' IDENTIFIED BY 'labpass';"
        mysql -e "GRANT ALL PRIVILEGES ON labdb.* TO 'labuser'@'%';"
        mysql -e "FLUSH PRIVILEGES;"
    else
        $PKG_INSTALL mariadb-server &>/dev/null
        systemctl enable --now mariadb &>/dev/null
        mysql -e "CREATE DATABASE labdb;"
        mysql -e "CREATE USER 'labuser'@'%' IDENTIFIED BY 'labpass';"
        mysql -e "GRANT ALL PRIVILEGES ON labdb.* TO 'labuser'@'%';"
        mysql -e "FLUSH PRIVILEGES;"
    fi
    echo "✅ DB server configured!"
}

test_db() {
    show_progress "Testing DB Server" 2
    mysql -ulabuser -plabpass -e "SHOW DATABASES;" | grep labdb &>/dev/null \
        && echo "✅ DB test OK" \
        || echo "[!] DB test FAILED"
}

# ----------------------------
# DNS Server
# ----------------------------
install_dns() {
    show_progress "Installing DNS Server" 5
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
    else
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
        restorecon -rv /var/named &>/dev/null || true
    fi
    systemctl daemon-reload
    systemctl enable --now named.service &>/dev/null
    echo "✅ DNS server configured!"
}

test_dns() {
    show_progress "Testing DNS Server" 2
    dig @localhost google.com +short | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" \
        && echo "✅ DNS test OK" \
        || { echo "[!] DNS test FAILED"; systemctl status named.service --no-pager; }
}

# ----------------------------
# Main
# ----------------------------
case "$ROLE" in
    web) install_web; test_web ;;
    db)  install_db; test_db ;;
    dns) install_dns; test_dns ;;
    *)   echo "[!] Invalid role: $ROLE (use web|db|dns)" ;;
esac
