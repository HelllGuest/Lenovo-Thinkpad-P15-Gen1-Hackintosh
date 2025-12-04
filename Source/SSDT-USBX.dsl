/*
 * SSDT-USBX.dsl - USB Power Properties
 * 
 * Purpose:
 *   Provides USB power properties required by macOS for proper
 *   USB device charging and power management. Without this,
 *   some devices may not charge or may charge slowly.
 * 
 * Requirements:
 *   - Should be used alongside USBMap.kext or USBToolBox.kext
 *   - No conflicts with existing USBX device in DSDT
 * 
 * Properties set:
 *   kUSBSleepPortCurrentLimit = 3000mA (sleep charging current)
 *   kUSBWakePortCurrentLimit  = 3000mA (wake charging current)
 * 
 * Current values (0x0BB8 = 3000):
 *   3000mA allows fast charging of phones and tablets
 *   This is the maximum USB 3.0 spec allows for dedicated charging ports
 * 
 * How it works:
 *   The _DSM method returns USB power properties that macOS
 *   uses to configure USB port power delivery capabilities.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "USBX", 0x00001000)
{
    // Place device under System Bus
    Scope (_SB)
    {
        // USB Power Properties device
        Device (USBX)
        {
            // Device address (not a real PCI device)
            Name (_ADR, Zero)
            
            /*
             * _DSM - Device Specific Method
             * Returns USB power configuration properties
             * 
             * Arg0: UUID (unused)
             * Arg1: Revision (unused)
             * Arg2: Function index - 0 returns supported functions
             * Arg3: Arguments (unused)
             */
            Method (_DSM, 4, NotSerialized)
            {
                // Function 0: Return supported function bitmap
                If (!Arg2)
                {
                    Return (Buffer (One)
                    {
                         0x03  // Functions 0 and 1 supported
                    })
                }

                // Function 1+: Return USB power properties
                Return (Package (0x04)
                {
                    // Maximum current during sleep (in mA)
                    // 0x0BB8 = 3000mA = 3A charging current
                    "kUSBSleepPortCurrentLimit", 
                    0x0BB8,
                    
                    // Maximum current while awake (in mA)
                    // 0x0BB8 = 3000mA = 3A charging current
                    "kUSBWakePortCurrentLimit", 
                    0x0BB8
                })
            }

            /*
             * _STA - Device Status
             * Only enable on macOS
             */
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)  // Present and functional
                }
                Else
                {
                    Return (Zero)  // Hidden on other OSes
                }
            }
        }
    }
}
