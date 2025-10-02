# Project Structure
Virtualization_Networking_Lab/
 README.md
 docs/
    topology.png          # Network diagram
    db_install.log        # DB installation log
    dns_install.log       # DNS installation log
    web_install.log       # Web server installation log
    test.log              # Test results log
 scripts/
    setup_lab.sh          # VM creation & setup of all services on respective servers
    test_lab.sh  	  # Client testing
 configs/
    db_init.sql
    index.html
    named.conf.options

# Virtualization & Networking Lab

This project sets up a small **Linux server lab** using Multipass, VirtualBox, or Proxmox.  
The lab demonstrates networking, service hosting, and system administration skills.

## Features
- Virtualized lab with multiple servers
- Apache/Nginx web server with a sample site
- MySQL database server
- Optional: DNS & DHCP servers
- Automated setup scripts for easy deployment

## Skills Demonstrated
- Linux server administration
- Networking (IP config, routing, service ports)
- Web & database hosting
- DNS & DHCP configuration

## Usage
1. Clone repo:
 
   git clone https://github.com/<your-username>/Virtualization_Networking_Lab.git
   cd Virtualization_Networking_Lab

