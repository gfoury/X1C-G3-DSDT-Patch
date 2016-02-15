# BIOS settings for the X1 Carbon G3 (20BS, 20BT)

These are my settings. No advice given whether they are good. They work for me.

## Main

| Setting | Value|
| --- | --- |
| Version|1.10 |
| Embedded controller version|1.06 |

## Config

### Network

Setting | Value
| --- | --- |
Wake On LAN|AC Only
UEFI IPv4 Network Stack|Enabled
UEFI IPv6 Network Stack|Enabled
UEFI PXE Boot Priority|IPv4 First

### USB

I am not certain about the USB 3.0 Mode. It works on 10.11 with PCIID_XHCIMux and USBInjectAll.

Setting | Value
--- | ---
USB UEFI BIOS Support | **Enabled**
Always On USB | Enabled
| - Charge in Battery Mode | Enabled |
USB 3.0 Mode | **Auto**

### Keyboard and mouse

Setting|Value
--- | ---
TrackPoint | Enabled
Trackpad | Enabled
Fn and Ctrl Key swap | Disabled
Fn Sticky Key | Disabled
F1-F12 as Primary Function | Disabled

### Display

Note that Total Graphics Memory may not be the DVMT value.

Setting|Value
--- | ---
Boot Display Device | Thinkpad LCD
Total Graphics Memory | 256MB
Boot Time Extension | Disabled

### Power

Setting|Value
--- | ---
Intel (R) SpeedStep Technology | Enabled
| - Mode for AC | Maximum Perf |
| - Mode for Battery | Battery Opti |
Adaptive Thermal Management | - 
| - Scheme for AC | Maximize Per |
| - Scheme for Battery | Balanced |
CPU Power Management | Enabled
Power On with AC Attach | Disabled
Intel (R) Rapid Start Technology | Disabled

### Beep and alarm

Setting|Value
--- | ---
Password Beep | Disabled
Keyboard Beep | Disabled

### Intel NFF

Intel (R) NFF Control: Disabled

## Security

### Fingerprint

Setting|Value
--- | ---
Predesktop Authentication|Disabled
Reader Priority|External-&gt;Internal
Security Mode|Normal

### Security Chip

Setting|Value
--- | ---
Security Chip Selection|Discrete TPM
Security Chip|Active
Physical Presence for Provisioning|Disabled
Physical Presence for Clear|Enabled

### BIOS Update

Setting|Value
--- | ---
Flash BIOS Updating by End-Users|Enabled
Secure RollBack Prevention|Disabled

### Memory protection

Setting|Value
--- | ---
Exection Prevention|Enabled

### Virtalization

Setting|Value
--- | ---
Intel (R) Virtualization Technology|Enabled
Intel (R) VT-d Feature|**Disabled**

### I/O port access

All enabled

### Internal device access

Bottom Cover Tamper Detection: Disabled

### Computrace

Computrace Module Activation

Setting|Value
--- | ---
Current Setting|Enabled
Current State|Not Activated

### Secure Boot

Secure Boot: **Disabled**

## Startup

Boot: Clover start boot.efi at Macintosh HD

Setting|Value
--- | ---
Network Boot|PCI LAN
UEFI/Legacy Boot|**UEFI Only**
| - CSM Support|**Yes**|
Boot Mode|Diagnostics
Option key Display|Enabled
Boot device List F12 Option|Enabled
Boot Order Lock|Disabled
