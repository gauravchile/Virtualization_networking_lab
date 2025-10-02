#!/bin/bash
# ===============================================
# test_lab.sh
# Central tester for Web, DB, and DNS servers
# Includes MySQL client auto-install for Debian & RHEL
# ===============================================

WEB_IP="10.192.225.166"
DB_IP="10.192.225.210"
DNS_IP="10.192.225.2"
MYSQL_USER="labuser"
MYSQL_PASS="labpass"
MYSQL_DB="labdb"

# ===== Install MySQL client if missing =====
if ! command -v mysql &>/dev/null; then
    echo "[*] MySQL client not found. Installing..."
    if [ -f /etc/debian_version ]; then
        sudo apt update  &>/dev/null
        sudo apt install mysql-client -y &>/dev/null
    elif [ -f /etc/redhat-release ]; then
        sudo yum install mysql -y &>/dev/null
    else
        echo "[!] Unsupported OS. Please install MySQL client manually."
        exit 1
    fi
fi

# ===== Test Web Server =====
echo "===== Testing Web Server ====="
if curl -s --max-time 5 http://$WEB_IP | grep -q "Welcome"; then
    echo "[+] Web OK"
else
    echo "[!] Web FAIL"
fi

# ===== Test DB Server =====
echo "===== Testing DB Server ====="
if mysql -h $DB_IP -u$MYSQL_USER -p$MYSQL_PASS -e "SHOW DATABASES;" 2>/dev/null | grep -q $MYSQL_DB; then
    echo "[+] DB OK"
else
    echo "[!] DB FAIL"
    echo "  --> Check MySQL service, firewall, bind-address, or user privileges!"
fi

# ===== Test DNS Server =====
echo "===== Testing DNS Server ====="
if dig @$DNS_IP google.com +short | grep -Eq "([0-9]{1,3}\.){3}[0-9]{1,3}"; then
    echo "[+] DNS OK"
else
    echo "[!] DNS FAIL"
fi

