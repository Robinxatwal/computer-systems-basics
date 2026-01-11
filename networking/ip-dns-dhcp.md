# Networking Basics: IP, DNS, and DHCP

This document explains core networking concepts commonly used in IT support and troubleshooting.

---

## IP Address
An IP address uniquely identifies a device on a network.

### Types
- **IPv4** (example: 192.168.1.10)
- **IPv6** (example: 2001:db8::1)

### Common Commands
- Windows: `ipconfig`
- Linux: `ip a`

---

## DNS (Domain Name System)
DNS translates domain names (like google.com) into IP addresses.

### Common Issues
- Websites not loading
- “DNS server not responding”

### Troubleshooting
- Flush DNS cache
- Change DNS server (e.g. 8.8.8.8)

### Commands
- Windows: `ipconfig /flushdns`
- Linux: `resolvectl status`

---

## DHCP (Dynamic Host Configuration Protocol)
DHCP automatically assigns network settings to devices.

### What DHCP Provides
- IP address
- Subnet mask
- Default gateway
- DNS server

### Common Issues
- Device has no IP address
- IP address starts with 169.254.x.x

### Troubleshooting
- Renew IP lease
- Restart router or DHCP service

### Commands
- Windows: `ipconfig /release` and `ipconfig /renew`
- Linux: `dhclient`
