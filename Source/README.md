# SSDT Source Files

Decompiled and documented ACPI SSDT patches for ThinkPad P15 Gen1 Hackintosh.

## Files

| File | Purpose | Required |
|------|---------|----------|
| SSDT-XOSI.dsl | OS interface spoofing (Windows emulation) | Yes |
| SSDT-EC.dsl | Embedded Controller status override | Yes |
| SSDT-ECRW.dsl | EC Read/Write methods for YogaSMC | Yes |
| SSDT-PLUG.dsl | CPU power management (XCPM) | Yes |
| SSDT-DGPU.dsl | Disable NVIDIA discrete GPU | Yes |
| SSDT-HKEY.dsl | ThinkPad hotkey methods for YogaSMC | Yes |
| SSDT-INIT.dsl | System initialization variables | Yes |
| SSDT-PNLF.dsl | Backlight control | Yes |
| SSDT-ALS0.dsl | Fake ambient light sensor | Optional |
| SSDT-MCHC.dsl | Memory Controller Hub device | Yes |
| SSDT-USBX.dsl | USB power properties | Yes |
| SSDT-SBUS.dsl | SMBus device support | Yes |
| SSDT-RHUB.dsl | USB Root Hub reset for USBMap | Yes |
| SSDT-TBOLT.dsl | Thunderbolt 3 (Intel Titan Ridge) | Optional |
| SSDT-TBOLT-HOTPLUG.dsl | Thunderbolt 3 with hot-plug (alternate, not currently used) | Optional |

## Compiling

To compile DSL source files to AML binaries, you need the ACPI compiler (iasl):

### Install iasl (macOS)
```bash
# Using Homebrew
brew install acpica

# Or download from Acidanthera
# https://github.com/acidanthera/MaciASL/releases
```

### Compile Commands
```bash
# Single file
iasl -tc SSDT-XOSI.dsl

# All files at once
for f in *.dsl; do iasl -tc "$f"; done

# Output: Creates .aml files in the same directory
# Copy compiled .aml files to EFI/OC/ACPI/
```

### Compilation Flags
- `-tc` : Create AML table (compiled output)
- `-l` : Generate mixed listing file (.lst) for debugging
- `-sa` : Compile to ASL source (decompile)

### After Compilation
1. Copy the generated `.aml` files to `EFI/OC/ACPI/`
2. Ensure they're listed in `config.plist` under `ACPI -> Add`
3. Verify loading order matches `Docs/SSDT-LOADING-ORDER.md`

## Loading Order

SSDTs should be loaded in this sequence (see `Docs/SSDT-LOADING-ORDER.md`):

1. SSDT-XOSI.aml
2. SSDT-EC.aml
3. SSDT-ECRW.aml
4. SSDT-PLUG.aml
5. SSDT-DGPU.aml
6. SSDT-HKEY.aml
7. SSDT-INIT.aml
8. SSDT-PNLF.aml
9. SSDT-ALS0.aml
10. SSDT-MCHC.aml
11. SSDT-USBX.aml
12. SSDT-SBUS.aml
13. SSDT-RHUB.aml
14. SSDT-TBOLT.aml (optional)

## Required config.plist Patches

These SSDTs require corresponding ACPI renames in config.plist:

| Patch | Find | Replace | For | Required |
|-------|------|---------|-----|----------|
| EC _STA to XSTA | `_STA` (in EC scope) | `XSTA` | SSDT-EC | Yes |
| NBCF Zero to One | `NBCF, 0` | `NBCF, 1` | EC initialization | Yes |
| PNLF to XNLF | `PNLF` | `XNLF` | SSDT-PNLF | Yes |
| _OSI to XOSI | `_OSI` | `XOSI` | SSDT-XOSI | Yes |

**Note**: All four patches are currently enabled in config.plist. The PNLF rename disables the existing PNLF device in DSDT so SSDT-PNLF can create a new one. NBCF patch sets EC initialization flag.

## Verification

After compiling and installing SSDTs, verify they loaded correctly:

```bash
# Check loaded ACPI tables
log show --predicate 'process == "kernel"' --last boot | grep "ACPI: SSDT"

# Should show 14 SSDTs loaded in order (TBOLT-HOTPLUG is an alternate, not used)
```


