# Networking Basics: IP, DNS, and DHCP

This document explains core networking concepts used in daily IT support and troubleshooting.

## IP Address
An IP address uniquely identifies a device on a network.

### Types
- IPv4 (e.g. 192.168.1.10)
- IPv6 (e.g. 2001:db8::1)

### Common Commands
- Windows: `ipconfig`
- Linux: `ip a`

---

## DNS (Domain Name System)
DNS translates domain names into IP addresses.

### Common Issues
- Websites not loading
- DNS server not responding

### Troubleshooting
- Flush DNS cache
- Change DNS server (e.g. Google DNS 8.8.8.8)

### Commands
- Windows: `ipconfig /flushdns`
- Linux: `resolvectl status`

---

## DHCP (Dynamic Host Configuration Protocol)
DHCP automatically assigns IP configuration to devices.

### What DHCP Provides
- IP address
- Subnet mask
- Default gateway
- DNS server

### Common Issues
- Device has no IP address
- IP conflict

### Troubleshooting
- Renew IP lease
- Restart router or DHCP service

### Commands
- Windows: `ipconfig /release` / `ipconfig /renew`
- Linux: `dhclient`

---

## Quick Comparison
| Component | Purpose |
|---------|--------|
| IP | Device identification |
| DNS | Name resolution |
| DHCP | Automatic configuration |
