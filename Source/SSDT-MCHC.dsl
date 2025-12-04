/*
 * SSDT-MCHC.dsl - Memory Controller Hub Device
 * 
 * Purpose:
 *   Creates the MCHC (Memory Controller Hub) device at PCI address 0,0.
 *   Some macOS components expect this device to exist for proper
 *   memory controller recognition.
 * 
 * Requirements:
 *   - No additional kexts required
 *   - Device should not already exist in DSDT at address 0
 * 
 * How it works:
 *   The Memory Controller Hub (MCH) is part of the chipset that manages
 *   RAM access. On real Macs, this device exists at PCI 0,0. Creating
 *   it here ensures macOS recognizes the memory subsystem correctly.
 * 
 * PCI Address:
 *   _ADR = 0 corresponds to PCI device 0, function 0
 *   This is the standard location for the host bridge/MCH
 * 
 * Note: This is a simple presence device - it doesn't add functionality,
 *       just ensures the device exists in the ACPI namespace.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "MCHC", 0x00001000)
{
    // Reference to PCI bus root
    External (_SB_.PCI0, DeviceObj)

    Scope (\_SB.PCI0)
    {
        // Memory Controller Hub device
        Device (MCHC)
        {
            /*
             * _ADR - PCI Address
             * Zero = Device 0, Function 0 on PCI bus
             * This is where the memory controller is located
             */
            Name (_ADR, Zero)
            
            /*
             * _STA - Device Status
             * Only create device on macOS
             */
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)  // Present and fully functional
                }
                Else
                {
                    Return (Zero)  // Hidden on other OSes
                }
            }
        }
    }
}
