/*
 * SSDT-RHUB.dsl - USB Root Hub Reset
 * 
 * Purpose:
 *   Disables the built-in RHUB (Root Hub) device on macOS to allow
 *   USBMap.kext or USBToolBox.kext to properly configure USB ports.
 * 
 * Requirements:
 *   - Used with USBToolBox.kext + USBMap.kext
 *   - RHUB device must exist at \_SB.PCI0.XHC.RHUB in DSDT
 * 
 * How it works:
 *   1. On macOS: Returns status 0 (device disabled/not present)
 *   2. This removes the DSDT-defined port configuration
 *   3. Allows USBMap.kext to inject custom port mappings
 * 
 * Why needed:
 *   The DSDT's RHUB device contains port definitions that may:
 *   - Include more than 15 ports (macOS limit without USBInjectAll)
 *   - Have incorrect port types (USB2 vs USB3)
 *   - Include ports that don't physically exist
 * 
 *   By disabling RHUB, we let USBMap.kext provide correct mappings.
 * 
 * Note: Status is REVERSED from other SSDTs:
 *   - macOS: Return Zero (disable RHUB)
 *   - Other: Return 0x0F (keep RHUB enabled)
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "RHUB", 0x00001000)
{
    // Reference to USB Root Hub in DSDT
    // XHC = eXtensible Host Controller (USB 3.0)
    // RHUB = Root Hub (parent of all USB ports)
    External (_SB_.PCI0.XHC_.RHUB, DeviceObj)

    Scope (\_SB.PCI0.XHC.RHUB)
    {
        /*
         * _STA - Device Status
         * 
         * IMPORTANT: Logic is INVERTED from other SSDTs!
         * - macOS: Disable (Zero) - let USBMap handle ports
         * - Other: Enable (0x0F) - use DSDT port definitions
         */
        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                // Disable RHUB on macOS
                // This allows USBMap.kext to inject custom port config
                Return (Zero)
            }
            Else
            {
                // Enable RHUB on Windows/Linux
                // They use the DSDT port definitions normally
                Return (0x0F)
            }
        }
    }
}
