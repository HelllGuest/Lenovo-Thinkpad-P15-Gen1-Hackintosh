# ThinkPad P15 Gen1 Hackintosh

macOS Sonoma 14.8.2 on Lenovo ThinkPad P15 Gen1

## System Specifications

| Component | Details |
|-----------|---------|
| **Model** | Lenovo ThinkPad P15 Gen1 (20SUS2FJ04) |
| **CPU** | Intel Core i7-10850H @ 2.70GHz (Comet Lake-H, 6C/12T) |
| **iGPU** | Intel UHD Graphics 630 (Comet Lake-H GT2) |
| **dGPU** | NVIDIA Quadro T1000 4GB (disabled) |
| **RAM** | 64GB DDR4-3200 (16GB Crucial + 32GB Samsung + 16GB Micron) |
| **Storage** | Kingston SNV2S 2TB NVMe + Toshiba KXG6 1TB NVMe |
| **Display** | 15.6" FHD 1920x1080 IPS (N156HCE-EN1) |
| **Audio** | Realtek ALC285 |
| **Ethernet** | Intel I219-LM |
| **WiFi** | Intel Wi-Fi 6 AX201 160MHz |
| **Bluetooth** | Intel AX201 |
| **Thunderbolt** | Intel Titan Ridge JHL7540 |
| **Card Reader** | Realtek RTS525A |
| **Battery** | 94Wh Li-Polymer (LGC) |
| **BIOS** | N30ET61W (1.97) |

## macOS Version

- **macOS**: Sonoma 14.8.2
- **OpenCore**: 1.0.6
- **SMBIOS**: MacBookPro16,1

## What Works

| Feature | Status | Notes |
|---------|--------|-------|
| CPU Power Management | ✅ | SSDT-PLUG, XCPM native |
| Intel UHD 630 | ✅ | WhateverGreen, full acceleration |
| Audio | ✅ | AppleALC, layout-id 61 |
| Ethernet | ✅ | IntelMausiEthernet |
| WiFi | ✅ | AirportItlwm |
| Bluetooth | ✅ | IntelBluetoothFirmware |
| USB Ports | ✅ | USBMap, all ports working |
| Trackpad | ✅ | VoodooPS2, multi-touch gestures |
| TrackPoint | ✅ | Full functionality |
| Keyboard | ✅ | All keys including Fn keys |
| Brightness Keys | ✅ | BrightnessKeys.kext (Fn+F5/F6) |
| Sleep/Wake | ✅ | S3 sleep working |
| Battery | ✅ | SMCBatteryManager |
| ThinkPad Features | ✅ | YogaSMC (fan control, battery threshold) |
| SD Card Reader | ✅ | Sinetek-rtsx |
| NVMe | ✅ | NVMeFix for power management |

## What Doesn't Work

| Feature | Status | Notes |
|---------|--------|-------|
| NVIDIA Quadro T1000 | ❌ | Disabled via SSDT-DGPU (unsupported since Mojave) |
| Fingerprint Reader | ❌ | Synaptics, not supported in macOS |
| Thunderbolt 3 | ⚠️ | SSDT-TBOLT, cold-plug works, hot-plug untested |

## Known Issues

## Repository Structure

```
.
├── EFI/
│   ├── BOOT/
│   │   └── BOOTx64.efi
│   └── OC/
│       ├── ACPI/              # Compiled SSDT patches (.aml)
│       ├── Drivers/           # UEFI drivers
│       ├── Kexts/             # Kernel extensions
│       ├── Tools/             # UEFI utilities
│       ├── config.plist       # OpenCore configuration
│       └── OpenCore.efi       # Bootloader
├── Source/                    # SSDT source files (.dsl) with comments
├── Docs/                      # Documentation
└── Tools/                     # Helper scripts
```

## ACPI Patches (SSDTs)

| SSDT | Purpose | Required |
|------|---------|----------|
| SSDT-XOSI | OS detection override (Darwin → Windows) | Yes |
| SSDT-EC | Embedded Controller compatibility | Yes |
| SSDT-ECRW | EC Read/Write methods for YogaSMC | Yes |
| SSDT-PLUG | CPU power management (XCPM) | Yes |
| SSDT-DGPU | Disable NVIDIA dGPU | Yes |
| SSDT-HKEY | ThinkPad hotkey support | Yes |
| SSDT-INIT | OS initialization flags | Yes |
| SSDT-PNLF | Backlight control | Yes |
| SSDT-ALS0 | Fake ambient light sensor | Optional |
| SSDT-MCHC | Memory controller device | Yes |
| SSDT-USBX | USB power properties | Yes |
| SSDT-SBUS | SMBus/BUS0 device | Yes |
| SSDT-RHUB | USB hub reset | Yes |
| SSDT-TBOLT | Thunderbolt 3 (Intel Titan Ridge) | Optional |

**Source Code**: Commented DSL sources available in [Source/](Source/)

**Loading Order**: See [Docs/SSDT-LOADING-ORDER.md](Docs/SSDT-LOADING-ORDER.md)

## Kexts

### Essential (Load First)
- **Lilu** - Patching engine
- **VirtualSMC** - SMC emulation
- **WhateverGreen** - Graphics patching
- **AppleALC** - Audio codec support

### SMC Plugins
- **SMCBatteryManager** - Battery status reporting
- **SMCProcessor** - CPU temperature sensors
- **SMCSuperIO** - Fan speed monitoring
- **SMCLightSensor** - Ambient light sensor

### Input
- **VoodooPS2Controller** - Keyboard, trackpad, TrackPoint
- **BrightnessKeys** - Brightness hotkeys

### Network
- **IntelMausiEthernet** - Intel I219-LM Ethernet
- **AirportItlwm** - Intel AX201 WiFi
- **IntelBluetoothFirmware** - Bluetooth firmware
- **IntelBTPatcher** - Bluetooth patches
- **BlueToolFixup** - Bluetooth compatibility

### Storage & USB
- **NVMeFix** - NVMe power management
- **USBToolBox** - USB mapping companion
- **USBMap** - USB port map
- **Sinetek-rtsx** - Realtek SD card reader

### ThinkPad Specific
- **YogaSMC** - ThinkPad EC features, fan control
- **ECEnabler** - EC field access

### Other
- **RestrictEvents** - System event patches

## Installation

### Prerequisites
1. USB drive (16GB+)
2. macOS installer (Sonoma 14.x recommended)
3. Another Mac or Hackintosh to prepare USB

### Steps
1. Create macOS installer USB using `createinstallmedia`
2. Mount USB EFI partition and copy `EFI` folder
3. **Generate unique SMBIOS** using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS)
4. Boot from USB, install macOS
5. Copy EFI to internal drive's EFI partition
6. Reboot and enjoy

**Detailed Guide**: [Dortania's OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)

## Post-Installation

### Generate SMBIOS (Required!)
```bash
# Use GenSMBIOS to generate unique values
python GenSMBIOS.py
# Select: MacBookPro16,1
# Update config.plist with MLB, SystemSerialNumber, SystemUUID
```

### YogaSMC Features
After installing [YogaSMC](https://github.com/zhen-zen/YogaSMC/releases/latest):
- Battery conservation mode (charge threshold)
- Fan speed control
- Keyboard backlight control
- Fn key customization
- PrtSc key mapping (maps to F13 for screenshot shortcuts)

### Disable Hibernation (Recommended)
```bash
sudo pmset -a hibernatemode 0
sudo rm -f /var/vm/sleepimage
sudo mkdir /var/vm/sleepimage
sudo pmset -a standby 0
sudo pmset -a autopoweroff 0
```

## Troubleshooting

### Black Screen on Boot
- Add `-v` to boot-args for verbose mode
- Try `-igfxvesa` to test without graphics acceleration
- Check SSDT loading order

### No Audio
- Verify AppleALC.kext is loaded: `kextstat | grep AppleALC`
- Current layout-id is 61, alternatives: 11, 15, 21, 66
- Reset NVRAM from OpenCore picker

### No WiFi
- AirportItlwm requires matching macOS version
- Check kext is loaded: `kextstat | grep itlwm`
- Try [HeliPort](https://github.com/OpenIntelWireless/HeliPort) for manual connection



### Sleep Issues
- Disable hibernation (see above)
- Disable Power Nap in System Preferences
- Check `pmset -g` for current settings

## Documentation

| Document | Description |
|----------|-------------|
| [Source/README.md](Source/README.md) | SSDT source files guide |
| [Docs/SSDT-LOADING-ORDER.md](Docs/SSDT-LOADING-ORDER.md) | ACPI loading sequence |
| [Docs/EC-FIELDS-REFERENCE.md](Docs/EC-FIELDS-REFERENCE.md) | EC field mappings from DSDT |

## Tools

### Included (`Tools/`)
- **battery-diagnostics.sh** - Battery health and status diagnostics
- **screenshot-key-setup.sh** - PrtSc key setup guide for screenshots

### External
- [Hackintool](https://github.com/benbaker76/Hackintool) - Swiss army knife for Hackintosh
- [IORegistryExplorer](https://github.com/khronokernel/IORegistryClone) - IORegistry browser
- [ProperTree](https://github.com/corpnewt/ProperTree) - plist editor

## Credits

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, VirtualSMC, WhateverGreen, AppleALC
- [zhen-zen](https://github.com/zhen-zen) - YogaSMC
- [OpenIntelWireless](https://github.com/OpenIntelWireless) - Intel WiFi/BT kexts
- [Dortania](https://dortania.github.io) - OpenCore guides
- [ThinkPad Hackintosh Community](https://github.com/topics/thinkpad-hackintosh)

## License

MIT License. This EFI configuration is provided as-is for educational purposes. Use at your own risk.

---

**Last Updated**: December 4, 2024  
**macOS**: Sonoma 14.8.2  
**OpenCore**: 1.0.6  
**BIOS**: N30ET61W (1.97)
