# Networking Troubleshooting Tools: Ping & ipconfig

This guide explains how to use Ping and ipconfig for basic network troubleshooting on Windows.

---

## Ping (Connectivity Test)

Ping checks whether a device can reach another device over the network using ICMP packets.

### What Ping Proves
- The target device is reachable
- There is basic network connectivity
- DNS resolution works (if using a hostname)

### Common Uses
- Test internet connectivity
- Test reachability of a server or router
- Check if DNS is resolving names correctly

### Examples
```cmd
ping 8.8.8.8
