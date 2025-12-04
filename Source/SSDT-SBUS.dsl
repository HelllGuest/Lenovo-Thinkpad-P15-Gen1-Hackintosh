/*
 * SSDT-SBUS.dsl - SMBus Device Support
 * 
 * Purpose:
 *   Creates BUS0 device under the SMBus controller for macOS.
 *   SMBus (System Management Bus) is used for communication with
 *   various system components like battery, sensors, and memory SPD.
 * 
 * Requirements:
 *   - SBUS device must exist in DSDT at \_SB.PCI0.SBUS
 *   - VirtualSMC.kext for full SMBus functionality
 * 
 * How it works:
 *   macOS expects a BUS0 child device under the SMBus controller.
 *   This device represents the main SMBus channel used for
 *   system management communication.
 * 
 * SMBus uses:
 *   - Battery communication (reading charge level, health, etc.)
 *   - Temperature sensor polling
 *   - Fan speed monitoring
 *   - RAM SPD (Serial Presence Detect) reading
 * 
 * Note: While battery primarily uses SMBus directly, having proper
 *       SBUS/BUS0 setup helps with system stability and sensor reading.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "SBUS", 0x00001000)
{
    // Reference to SMBus controller in DSDT
    // Located at PCI device 0x1F, function 4 on most Intel systems
    External (_SB_.PCI0.SBUS, DeviceObj)

    Scope (\_SB.PCI0.SBUS)
    {
        // Primary SMBus device
        Device (BUS0)
        {
            // Compatible ID for SMBus
            Name (_CID, "smbus")
            
            // Device address (child of SBUS)
            Name (_ADR, Zero)
            
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
