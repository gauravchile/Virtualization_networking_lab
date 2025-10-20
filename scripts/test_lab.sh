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
# Install MySQL client if missing
# ----------------------------
if ! command -v mysql &>/dev/null; then
    show_progress "Installing MySQL client" 4
    if [ -f /etc/debian_version ]; then
        sudo apt update &>/dev/null
        sudo apt install mysql-client -y &>/dev/null
    elif [ -f /etc/redhat-release ]; then
        sudo yum install mysql -y &>/dev/null
    else
        echo "[!] Unsupported OS. Install MySQL client manually."
        exit 1
    fi
fi

# ----------------------------
# Test Web Server
# ----------------------------
show_progress "Testing Web Server" 3
if curl -s --max-time 5 http://$WEB_IP | grep -q "Welcome"; then
    echo "✅ Web OK"
else
    echo "[!] Web FAIL"
fi

# ----------------------------
# Test DB Server
# ----------------------------
show_progress "Testing DB Server" 3
if mysql -h $DB_IP -u$MYSQL_USER -p$MYSQL_PASS -e "SHOW DATABASES;" 2>/dev/null | grep -q $MYSQL_DB; then
    echo "✅ DB OK"
else
    echo "[!] DB FAIL"
    echo "  --> Check MySQL service, firewall, bind-address, or user privileges!"
fi

# ----------------------------
# Test DNS Server
# ----------------------------
show_progress "Testing DNS Server" 3
if dig @$DNS_IP google.com +short | grep -Eq "([0-9]{1,3}\.){3}[0-9]{1,3}"; then
    echo "✅ DNS OK"
else
    echo "[!] DNS FAIL"
fi
