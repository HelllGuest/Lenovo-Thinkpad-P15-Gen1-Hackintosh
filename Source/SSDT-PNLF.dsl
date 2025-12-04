/*
 * SSDT-PNLF.dsl - Panel Backlight Device
 * 
 * Purpose:
 *   Creates the PNLF (Panel Backlight) device required by macOS for
 *   display brightness control on laptops. Works with WhateverGreen.kext.
 * 
 * Requirements:
 *   - WhateverGreen.kext must be loaded
 *   - Requires PNLF to XNLF rename in config.plist (if PNLF exists in DSDT)
 *   - BrightnessKeys.kext for Fn key brightness control
 * 
 * How it works:
 *   1. Creates PNLF device under iGPU (GFX0)
 *   2. Sets _HID to APP0002 (Apple backlight identifier)
 *   3. WhateverGreen intercepts this and enables brightness control
 * 
 * _UID Values (for different iGPU generations):
 *   0x10 = Sandy/Ivy Bridge
 *   0x11 = Haswell/Broadwell
 *   0x12 = Skylake/Kaby Lake
 *   0x13 = Coffee Lake and later (including Comet Lake)
 * 
 * Your system: Intel UHD 630 (Comet Lake) uses _UID 0x13
 * 
 * For: ThinkPad P15 Gen1 (Intel UHD 630) | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "PNLF", 0x00001000)
{
    // Reference to integrated GPU device in DSDT
    External (_SB_.PCI0.GFX0, DeviceObj)

    // Create PNLF device under the iGPU
    Device (\_SB.PCI0.GFX0.PNLF)
    {
        // Apple backlight device identifier
        Name (_HID, EisaId ("APP0002"))
        
        // Compatible ID - generic backlight identifier
        Name (_CID, "backlight")
        
        // Unique ID for Coffee Lake+ (0x13 = 19 decimal)
        // This tells WhateverGreen which backlight register set to use
        Name (_UID, 0x13)
        
        /*
         * _STA - Device Status
         * Returns: Status flags
         * 
         * 0x0B = Present (1) + Enabled (2) + Functioning (8)
         * Note: UI visibility (4) is NOT set to hide from IORegistry spam
         */
        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0B)  // Enabled on macOS
            }
            Else
            {
                Return (Zero)  // Hidden on other OSes
            }
        }
    }
}
