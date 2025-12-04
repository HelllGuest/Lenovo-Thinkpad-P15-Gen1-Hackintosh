/*
 * SSDT-EC.dsl - Embedded Controller Status Override
 * 
 * Purpose:
 *   Ensures the Embedded Controller (EC) is properly recognized by macOS.
 *   macOS requires specific EC behavior for battery, power management,
 *   and laptop-specific features to work correctly.
 * 
 * Requirements:
 *   - Requires EC _STA to XSTA rename in config.plist ACPI patches
 *   - Should load early in SSDT sequence (after XOSI)
 * 
 * How it works:
 *   1. Original _STA method is renamed to XSTA by config.plist patch
 *   2. This SSDT provides a new _STA that returns 0x0F on macOS
 *   3. On other OSes, calls original XSTA method
 * 
 * Status return values:
 *   0x0F = Device present, enabled, functioning, and visible in UI
 *   0x00 = Device not present
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "EC", 0x00001000)
{
    // Reference to the Embedded Controller device in DSDT
    // Path: \_SB.PCI0.LPCB.EC (System Bus > PCI > LPC Bridge > EC)
    External (_SB_.PCI0.LPCB.EC__, DeviceObj)
    
    // Reference to the renamed original _STA method
    External (_SB_.PCI0.LPCB.EC__.XSTA, MethodObj)

    // Only apply if XSTA exists (meaning the rename patch was applied)
    If (CondRefOf (\_SB.PCI0.LPCB.EC.XSTA))
    {
        Scope (\_SB.PCI0.LPCB.EC)
        {
            /*
             * _STA Method - Device Status
             * Returns: Integer - Device status flags
             * 
             * Bit 0: Device present
             * Bit 1: Device enabled
             * Bit 2: Device shown in UI
             * Bit 3: Device functioning properly
             */
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    // macOS: Return fully enabled status
                    // 0x0F = Present + Enabled + UI visible + Functioning
                    Return (0x0F)
                }
                Else
                {
                    // Other OS: Use original method behavior
                    Return (\_SB.PCI0.LPCB.EC.XSTA ())
                }
            }
        }
    }
}
