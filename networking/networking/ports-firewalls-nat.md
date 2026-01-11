# Ports, Firewalls, and NAT (Practical Networking)

This guide explains how ports, firewalls, and NAT affect real-world connectivity and troubleshooting.

## Ports (What service is running where)
A port is a numbered “door” on a device. A service listens on a port, and clients connect to it.

### Common Ports You Should Know
- 20/21 – FTP (file transfer)
- 22 – SSH (secure remote access, Linux)
- 23 – Telnet (insecure, legacy)
- 25 – SMTP (sending email)
- 53 – DNS
- 67/68 – DHCP
- 80 – HTTP (web)
- 443 – HTTPS (secure web)
- 110 – POP3 (email)
- 143 – IMAP (email)
- 3389 – RDP (Remote Desktop)
- 445 – SMB (Windows file sharing)

### Quick checks
- “Website not loading” → usually 80/443
- “RDP not working” → 3389 (and firewall rules)
- “File share not working” → 445 (often blocked on public networks)

---

## Firewalls (What traffic is allowed or blocked)
A firewall filters network traffic based on rules (port, app, IP, direction).

### Why firewalls break things
- The service is running, but the firewall blocks inbound traffic
- An outbound rule blocks an app from connecting
- The network firewall (router/company firewall) blocks a port

### Basic troubleshooting mindset
1. Is the service running?
2. Is the port open on the machine?
3. Is the firewall allowing it?
4. Is something upstream blocking it (router/network)?

### Windows checks
- Windows Defender Firewall can block inbound ports like 3389 (RDP) or 445 (SMB).
- Temporarily turning firewall off is a test (not a solution). Re-enable afterward.

---

## NAT (Why private IPs can reach the internet)
NAT (Network Address Translation) lets many devices on a private network share one public IP.

### Private vs Public IP
- Private IP ranges:
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16
- Public IP: assigned by ISP and visible on the internet

### Common NAT-related issue: Port Forwarding
If you want to access an internal service from outside (like a home server), you often need port forwarding on the router.

Example:
- External: PublicIP:3389 → Internal: 192.168.1.50:3389

---

## Quick Troubleshooting Checklist (Real-world)
### Scenario: “I can browse, but one app can’t connect”
- Check DNS (try a different DNS server)
- Check firewall outbound rules
- Check if the app uses a blocked port

### Scenario: “RDP doesn’t work”
- Confirm the PC is ON and RDP is enabled
- Confirm you are on the correct network/VPN
- Confirm port 3389 is allowed (firewall + network)
- If outside home network: check router port forwarding (not recommended unless secured)

### Scenario: “File sharing doesn’t work”
- Check network profile (public/private)
- Check SMB settings and firewall rules
- Test connectivity to the PC (ping + name resolution)
