# Troubleshooting Walkthroughs

This document contains real-world IT support troubleshooting scenarios, showing a structured and logical approach to diagnosing and fixing issues.

---

## Case 1: Connected to Wi-Fi but No Internet Access

### Symptoms
- Device shows connected to Wi-Fi
- Websites fail to load
- Other devices may work on the same network

### Initial Checks
- Confirmed Wi-Fi connection status
- Restarted browser and device

### Troubleshooting Steps
1. Ran `ipconfig`
   - IP address assigned correctly
   - Default gateway present

2. Pinged default gateway
✔ Successful reply

3. Pinged public IP
✔ Successful reply

4. Pinged domain name
❌ Failed – “Could not find host”

### Diagnosis
DNS resolution issue.

### Resolution
- Ran `ipconfig /flushdns`
- Changed DNS servers to:
- 8.8.8.8
- 8.8.4.4

### Outcome
Internet access restored and websites loaded normally.

---

## Case 2: Remote Desktop (RDP) Not Connecting

### Symptoms
- RDP connection fails with timeout error
- Works from home network but not office Wi-Fi

### Initial Checks
- Verified target PC was powered on
- Confirmed Remote Desktop enabled
- Confirmed correct username and password

### Troubleshooting Steps
1. Pinged target device
 ✔ Successful reply

2. Verified RDP service running on target machine

3. Checked Windows Firewall rules
- RDP allowed locally

4. Tested connection on different network
- Worked successfully outside office network

### Diagnosis
Office network firewall blocking port 3389 (RDP).

### Resolution
- Connected using company VPN
- Used approved remote access method

### Outcome
Successful remote connection established.

---

## Case 3: Device Assigned 169.254.x.x Address

### Symptoms
- No internet access
- IP address starts with 169.254.x.x

### Troubleshooting Steps
1. Ran `ipconfig /all`
- No DHCP server detected

2. Released and renewed IP
❌ No response from DHCP

3. Restarted router and network adapter

### Diagnosis
DHCP service not responding.

### Resolution
- Restarted router
- DHCP service restored

### Outcome
Device received valid IP address and internet access returned.

---

## Troubleshooting Approach Used
- Identify symptoms
- Check physical and basic configuration
- Isolate DNS, network, or service issues
- Apply fix and confirm resolution

This approach ensures consistent and effective IT support troubleshooting.
  
