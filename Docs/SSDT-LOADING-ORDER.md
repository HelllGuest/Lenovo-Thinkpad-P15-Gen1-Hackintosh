# SSDT Loading Order for ThinkPad P15 Gen1

## Current Loading Order

SSDTs are loaded in the following sequence in `config.plist`:

### Phase 1: OS Detection
1. **SSDT-XOSI.aml** - OS interface override (Darwin → Windows emulation)

### Phase 2: EC Initialization
2. **SSDT-EC.aml** - Embedded Controller status override
3. **SSDT-ECRW.aml** - EC Read/Write methods for YogaSMC

### Phase 3: Power & GPU
4. **SSDT-PLUG.aml** - CPU power management (XCPM)
5. **SSDT-DGPU.aml** - Disable NVIDIA discrete GPU

### Phase 4: ThinkPad Features
6. **SSDT-HKEY.aml** - ThinkPad hotkey support
7. **SSDT-INIT.aml** - System initialization flags

### Phase 5: Display & Backlight
8. **SSDT-PNLF.aml** - Backlight control
9. **SSDT-ALS0.aml** - Ambient Light Sensor (optional)

### Phase 6: Other Devices
10. **SSDT-MCHC.aml** - Memory Controller Hub device
11. **SSDT-USBX.aml** - USB power properties
12. **SSDT-SBUS.aml** - SMBus device support
13. **SSDT-RHUB.aml** - USB Root Hub reset
14. **SSDT-TBOLT.aml** - Thunderbolt 3 support (optional)

## Why This Order Matters

1. **XOSI must load first** - Other SSDTs may check `_OSI` for OS detection
2. **EC initialization early** - EC and ECRW provide methods that ThinkPad SSDTs need
3. **Disable dGPU early** - Prevents NVIDIA GPU from initializing
4. **ThinkPad features need EC** - HKEY depends on EC access
5. **Backlight after GPU setup** - PNLF for iGPU backlight control

## Why Separate Files Work Better

- YogaSMC expects EC R/W methods in a specific scope
- Separate SSDTs load in sequence without scope conflicts
- Easier to debug individual components
- Can enable/disable features independently

## Notes

### Battery SSDTs

No battery SSDT is currently used because:
- AppleSmartBatteryManager reads directly from SMBus, bypassing ACPI
- Battery works perfectly with SMCBatteryManager

### Thunderbolt

SSDT-TBOLT is optional and provides basic Thunderbolt 3 support:
- Cold-plug works
- Hot-plug untested
- An alternate hot-plug version is available at `Source/SSDT-TBOLT-HOTPLUG.dsl`

## Verification

### Check SSDTs Loaded
```bash
log show --predicate 'process == "kernel"' --last boot | grep "ACPI: SSDT"
```

### Check EC Access
YogaSMCNC menu bar → About → should show "ECAccess: R/W"

### Check Backlight
- Brightness slider should work
- Fn+F5/F6 should adjust brightness

---

**Last Updated**: December 4, 2024  
**System**: ThinkPad P15 Gen1 | macOS Sonoma 14.8.2 | OpenCore 1.0.6
