# EC Field Verification Guide for Battery Patching

## Overview
To properly implement battery reporting on your ThinkPad P15 Gen1, you need to verify and use the actual EC (Embedded Controller) field offsets from your DSDT. This ensures accurate battery information.

## Your Actual EC Field Definitions (from DSDT)

Based on your DSDT.dsl, here are the **verified** battery-related EC fields:

### Battery Fields at Offset 0xA0

```asl
Field (ECOR, ByteAcc, NoLock, Preserve)
{
    Offset (0xA0), 
    SBRC,   16,     // Remaining Capacity
    SBFC,   16,     // Full Charge Capacity
    SBAE,   16,     // (Unknown - possibly Average Current)
    SBRS,   16,     // (Unknown - possibly Rate Status)
    SBAC,   16,     // Average Current
    SBVO,   16,     // Voltage
    SBAF,   16,     // (Unknown - possibly Flags)
    SBBS,   16      // Battery Status
}

Field (ECOR, ByteAcc, NoLock, Preserve)
{
    Offset (0xA0), 
    SBBM,   16,     // Battery Mode
    SBMD,   16,     // (Unknown)
    SBCC,   16      // Cycle Count
}

Field (ECOR, ByteAcc, NoLock, Preserve)
{
    Offset (0xA0), 
    SBDC,   16,     // Design Capacity
    SBDV,   16,     // Design Voltage
    SBOM,   16,     // (Unknown)
    SBSI,   16,     // (Unknown)
    SBDT,   16,     // (Unknown - possibly Date)
    SBSN,   16      // Serial Number
}

Field (ECOR, ByteAcc, NoLock, Preserve)
{
    Offset (0xA0), 
    SBCH,   32      // (Unknown - possibly Chemistry)
}

Field (ECOR, ByteAcc, NoLock, Preserve)
{
    Offset (0xA0), 
    SBMN,   128     // Manufacturer Name (16 bytes)
}

Field (ECOR, ByteAcc, NoLock, Preserve)
{
    Offset (0xA0), 
    SBDN,   128     // Device Name (16 bytes)
}
```

## Key Fields for Battery Reporting

### For _BIF (Battery Information):
- **SBFC** (0xA0+2): Full Charge Capacity
- **SBDC** (0xA0): Design Capacity  
- **SBDV** (0xA0+2 in 3rd field): Design Voltage
- **SBBM** (0xA0 in 2nd field): Battery Mode (bit 15 indicates mAh vs 10mWh)
- **SBMN** (0xA0): Manufacturer Name (128-bit string)
- **SBDN** (0xA0): Device Name (128-bit string)
- **SBSN** (0xA0+10): Serial Number

### For _BST (Battery Status):
- **SBBS** (0xA0+14): Battery Status
- **SBAC** (0xA0+8): Average Current (Present Rate)
- **SBRC** (0xA0): Remaining Capacity
- **SBVO** (0xA0+10): Voltage

## How to Use These Fields

### Step 1: Understand the HIID Protocol
Your DSDT uses a special protocol where it sets **HIID** (at offset 0x81) to select which battery to read:
- `HIID = Arg0` - Select battery (0 for BAT0, 1 for BAT1)
- `HIID = (Arg0 | 0x01)` - Read battery mode
- `HIID = (Arg0 | 0x02)` - Read design capacity

### Step 2: Use the Mutex
Always acquire the **BATM** mutex before reading battery fields:
```asl
Acquire (BATM, 0xFFFF)
// ... read EC fields ...
Release (BATM)
```

### Step 3: Handle mAh vs mWh
Check bit 15 of SBBM to determine units:
```asl
HIID = (Arg0 | One)
Local7 = SBBM
Local7 >>= 0x0F
// If Local7 = 1, multiply by 10 for mWh
// If Local7 = 0, use value as-is for mAh
```

## Updated SSDT-BATT.dsl

Your SSDT should use these actual field names instead of the template placeholders. Here's what needs to change:

**Current (Template):**
```asl
External (_SB_.PCI0.LPCB.EC__.BSTS, FieldUnitObj)  // Wrong!
External (_SB_.PCI0.LPCB.EC__.BCAP, FieldUnitObj)  // Wrong!
```

**Correct (Verified):**
```asl
External (_SB_.PCI0.LPCB.EC__.SBBS, FieldUnitObj)  // Battery Status
External (_SB_.PCI0.LPCB.EC__.SBRC, FieldUnitObj)  // Remaining Capacity
External (_SB_.PCI0.LPCB.EC__.SBFC, FieldUnitObj)  // Full Charge Capacity
External (_SB_.PCI0.LPCB.EC__.SBDC, FieldUnitObj)  // Design Capacity
External (_SB_.PCI0.LPCB.EC__.SBVO, FieldUnitObj)  // Voltage
External (_SB_.PCI0.LPCB.EC__.SBAC, FieldUnitObj)  // Average Current
External (_SB_.PCI0.LPCB.EC__.HIID, FieldUnitObj)  // Hardware ID selector
External (_SB_.PCI0.LPCB.EC__.BATM, MutexObj)      // Battery Mutex
```

## Important Note

**Battery SSDT patches are NOT currently used** in this system because:
- AppleSmartBatteryManager reads directly from SMBus, bypassing ACPI
- ACPI patches cannot fix the "Service Recommended" warning
- Battery works perfectly without custom SSDT

See [BATTERY-WARNING-INFO.md](BATTERY-WARNING-INFO.md) for complete explanation.

## Historical Context

This guide documents the EC field verification process that was performed during battery patch development. While battery SSDTs were created and tested, they ultimately could not solve the "Service Recommended" warning because macOS reads battery data directly from the battery's EEPROM chip via SMBus, completely bypassing ACPI methods.

The verified EC fields documented here remain accurate and could be useful for:
- Future battery-related development
- Understanding ThinkPad EC structure
- Reference for other ACPI patches that need EC access
- YogaSMC integration (which does use EC fields)

## Note on Battery Patches

Battery SSDT patches were tested but found to be ineffective because:
- AppleSmartBatteryManager reads directly from SMBus
- ACPI methods are bypassed entirely
- No SSDT can override SMBus reads

The correct implementation would require:
- Verified EC field access
- HIID protocol for battery selection
- Mutex protection (BATM)
- Unit conversion (mAh vs mWh)

However, these cannot override SMBus reads, so they don't fix the warning.

---

**Last Updated**: December 4, 2024  
**System**: ThinkPad P15 Gen1 | macOS Sonoma 14.8.2 | OpenCore 1.0.6
