# 🖥️ Virtualization & Networking Lab

Set up a **small Linux server lab** using **Multipass, VirtualBox, or Proxmox**.  
The lab demonstrates networking, service hosting, and system administration skills.

![Linux](https://img.shields.io/badge/Linux-Compatible-blue) ![Bash](https://img.shields.io/badge/Shell-Bash-green) ![Networking](https://img.shields.io/badge/Network-Lab-orange) ![Virtualization](https://img.shields.io/badge/Virtualization-VirtualBox-blue)

---

## 📁 Project Structure

```
Virtualization_Networking_Lab/
│
├─ README.md
├─ docs/
│   ├─ topology.png          # Network diagram
│   ├─ db_install.log        # DB installation log
│   ├─ dns_install.log       # DNS installation log
│   ├─ web_install.log       # Web server installation log
│   └─ test.log              # Test results log
├─ scripts/
│   ├─ setup_lab.sh          # VM creation & setup of all services
│   └─ test_lab.sh           # Client testing
└─ configs/
    ├─ db_init.sql
    ├─ index.html
    └─ named.conf.options
```

---

## 🌟 Features

- Virtualized lab with **multiple Linux servers**  
- Apache/Nginx web server with a **sample website**  
- MySQL database server  
- Optional: **DNS & DHCP servers**  
- Automated setup scripts for **easy deployment**

---

## 🎯 Skills Demonstrated

- Linux server administration  
- Networking (IP configuration, routing, service ports)  
- Web & database hosting  
- DNS & DHCP configuration  

---

## ⚙️ Usage

1. **Clone the repository**

```bash
git clone https://github.com/gauravchile/Virtualization_Networking_Lab.git
cd Virtualization_Networking_Lab
```

2. **Run setup script**

```bash
chmod +x scripts/setup_lab.sh
./scripts/setup_lab.sh
```

3. **Test the lab**

```bash
chmod +x scripts/test_lab.sh
./scripts/test_lab.sh
```

> 💡 Tip: Ensure virtualization is enabled in your BIOS/UEFI and that you have network access to your VMs.

---

## 💡 Pro Tips

- Use this lab for **DevOps or Sysadmin practice**  
- Expand by adding more servers or services (FTP, Mail, etc.)  
- Check logs in `docs/` for troubleshooting
