/*
 * SSDT-TBOLT.dsl - Thunderbolt 3 Support (Basic)
 * 
 * Purpose:
 *   Enables basic Thunderbolt 3 support on macOS for Intel Titan Ridge
 *   controller (JHL7540). Provides cold-plug functionality.
 * 
 * Requirements:
 *   - Intel Titan Ridge Thunderbolt controller
 *   - Thunderbolt device at \_SB.PCI0.RP01 in DSDT
 * 
 * Features:
 *   - Cold-plug: Devices connected before boot work
 *   - Hot-plug: Not fully supported (use SSDT-TBOLT-HOTPLUG.dsl for experimental hot-plug)
 * 
 * How it works:
 *   Creates UPSB (Upstream Bridge) and DSB (Downstream Bridge) devices
 *   that macOS expects for Thunderbolt topology. The NHI0 device is the
 *   Native Host Interface that handles Thunderbolt protocol.
 * 
 * Device Structure:
 *   RP01 (Root Port)
 *   └── UPSB (Upstream Bridge)
 *       ├── DSB0 (Downstream Bridge 0)
 *       │   └── NHI0 (Native Host Interface - Thunderbolt controller)
 *       ├── DSB1 (Downstream Bridge 1 - USB-C port 1)
 *       ├── DSB2 (Downstream Bridge 2 - PCIe)
 *       └── DSB4 (Downstream Bridge 4 - USB-C port 2)
 * 
 * Properties:
 *   pci-thunderbolt-native = 1 : Enable native Thunderbolt support
 *   built-in = 0 : Not a built-in device (removable)
 * 
 * For: ThinkPad P15 Gen1 (Intel Titan Ridge JHL7540) | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "TBOLT", 0x00001000)
{
    External (_SB_.PCI0.RP01, DeviceObj)

    Scope (\_SB.PCI0.RP01)
    {
        // Upstream Bridge - Parent of all Thunderbolt devices
        Device (UPSB)
        {
            Name (_ADR, Zero)  // Address 0,0

            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Return (Zero)
            }

            // Downstream Bridge 0 - Contains Thunderbolt controller
            Device (DSB0)
            {
                Name (_ADR, Zero)

                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Return (Zero)
                }

                // Native Host Interface - Thunderbolt controller
                Device (NHI0)
                {
                    Name (_ADR, Zero)
                    Name (_STR, Unicode ("Thunderbolt"))

                    Method (_STA, 0, NotSerialized)
                    {
                        If (_OSI ("Darwin"))
                        {
                            Return (0x0F)
                        }
                        Return (Zero)
                    }

                    // Device-Specific Method for Thunderbolt properties
                    Method (_DSM, 4, NotSerialized)
                    {
                        // Thunderbolt UUID
                        If ((Arg0 == ToUUID ("33f1364e-5e99-4d4b-8bb8-6ed7a1a84e5f")))
                        {
                            If ((Arg2 == Zero))
                            {
                                Return (Buffer (One) { 0x03 })
                            }
                            Return (Package ()
                            {
                                "pci-thunderbolt-native", One,           // Enable native TB
                                "built-in", Buffer (One) { 0x00 },       // Not built-in
                                "AAPL,slot-name", Buffer () { "Thunderbolt" }
                            })
                        }
                        Return (Buffer (One) { 0x00 })
                    }
                }
            }

            // Downstream Bridge 1 - USB-C port 1 (removable)
            Device (DSB1)
            {
                Name (_ADR, 0x00010000)  // Device 1, Function 0

                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Return (Zero)
                }

                Method (_RMV, 0, NotSerialized)
                {
                    Return (One)  // Removable device
                }
            }

            // Downstream Bridge 2 - PCIe devices
            Device (DSB2)
            {
                Name (_ADR, 0x00020000)  // Device 2, Function 0

                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Return (Zero)
                }
            }

            // Downstream Bridge 4 - USB-C port 2 (removable)
            Device (DSB4)
            {
                Name (_ADR, 0x00040000)  // Device 4, Function 0

                Method (_STA, 0, NotSerialized)
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Return (Zero)
                }

                Method (_RMV, 0, NotSerialized)
                {
                    Return (One)  // Removable device
                }
            }
        }
    }
}
