/*
 * SSDT-TBOLT-HOTPLUG.dsl - Thunderbolt 3 with Hot-Plug Support (Experimental)
 * 
 * Purpose:
 *   Enables Thunderbolt 3 hot-plug support on macOS for Intel Titan Ridge
 *   controller. This is an experimental version that adds _UPC and _PLD
 *   methods for better hot-plug detection.
 * 
 * Requirements:
 *   - Intel Titan Ridge Thunderbolt controller
 *   - Thunderbolt device at \_SB.PCI0.RP01 in DSDT
 * 
 * Features:
 *   - Cold-plug: Devices connected before boot work
 *   - Hot-plug: Experimental support for connecting devices while running
 * 
 * Differences from SSDT-TBOLT.dsl:
 *   - Adds _UPC (USB Port Capabilities) methods
 *   - Adds _PLD (Physical Location of Device) methods
 *   - Adds DEV0 child devices for better enumeration
 *   - More complete device topology for hot-plug events
 * 
 * Note: Hot-plug support is experimental and may not work perfectly.
 *       Use SSDT-TBOLT.dsl if you only need cold-plug (more stable).
 * 
 * Device Structure:
 *   RP01 (Root Port)
 *   └── UPSB (Upstream Bridge)
 *       ├── DSB0 (Downstream Bridge 0)
 *       │   └── NHI0 (Native Host Interface)
 *       ├── DSB1 (Downstream Bridge 1 - USB-C port 1)
 *       │   └── DEV0 (Hot-plug device)
 *       ├── DSB2 (Downstream Bridge 2 - PCIe)
 *       └── DSB4 (Downstream Bridge 4 - USB-C port 2)
 *           └── DEV0 (Hot-plug device)
 * 
 * For: ThinkPad P15 Gen1 (Intel Titan Ridge JHL7540) | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "TB3HP", 0x00001000)
{
    External (_SB_.PCI0.RP01, DeviceObj)

    Scope (\_SB.PCI0.RP01)
    {
        // Upstream Bridge - Parent of all Thunderbolt devices
        Device (UPSB)
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

            // Device properties for upstream bridge
            Method (_DSM, 4, NotSerialized)
            {
                If ((Arg2 == Zero))
                {
                    Return (Buffer (One) { 0x03 })
                }
                Return (Package ()
                {
                    "built-in", Buffer (One) { 0x00 }  // Not built-in
                })
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

            // Downstream Bridge 1 - USB-C port 1 (hot-plug capable)
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
                    Return (One)  // Removable/hot-pluggable
                }

                // USB Port Capabilities - Type-C connector
                Method (_UPC, 0, NotSerialized)
                {
                    Return (Package ()
                    {
                        0xFF,   // Port is connectable
                        0x09,   // Type-C connector (USB 3.0 and DisplayPort)
                        Zero,   // Reserved
                        Zero    // Reserved
                    })
                }

                // Physical Location of Device
                Method (_PLD, 0, NotSerialized)
                {
                    Return (Package ()
                    {
                        Buffer (0x14)
                        {
                            // Revision 2, Ignore Color, Shape: Vertical Rectangle
                            0x82, 0x00, 0x00, 0x00,
                            // Panel: Left, Vertical Position: Center, Horizontal Position: Left
                            0x00, 0x00, 0x00, 0x00,
                            // Ejectable, Needs OPSM, Group Position: 1, Group Token: 1
                            0x31, 0x1C, 0x00, 0x00,
                            // Reserved
                            0x00, 0x00, 0x00, 0x00,
                            // Vertical/Horizontal Offsets
                            0xFF, 0xFF, 0xFF, 0xFF
                        }
                    })
                }

                // Hot-plug device placeholder
                Device (DEV0)
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

                    Method (_RMV, 0, NotSerialized)
                    {
                        Return (One)  // Removable
                    }
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

            // Downstream Bridge 4 - USB-C port 2 (hot-plug capable)
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
                    Return (One)  // Removable/hot-pluggable
                }

                // USB Port Capabilities - Type-C connector
                Method (_UPC, 0, NotSerialized)
                {
                    Return (Package ()
                    {
                        0xFF,   // Port is connectable
                        0x09,   // Type-C connector (USB 3.0 and DisplayPort)
                        Zero,   // Reserved
                        Zero    // Reserved
                    })
                }

                // Physical Location of Device
                Method (_PLD, 0, NotSerialized)
                {
                    Return (Package ()
                    {
                        Buffer (0x14)
                        {
                            // Revision 2, Ignore Color, Shape: Vertical Rectangle
                            0x82, 0x00, 0x00, 0x00,
                            // Panel: Left, Vertical Position: Center, Horizontal Position: Left
                            0x00, 0x00, 0x00, 0x00,
                            // Ejectable, Needs OPSM, Group Position: 2, Group Token: 1
                            0x32, 0x1C, 0x00, 0x00,
                            // Reserved
                            0x00, 0x00, 0x00, 0x00,
                            // Vertical/Horizontal Offsets
                            0xFF, 0xFF, 0xFF, 0xFF
                        }
                    })
                }

                // Hot-plug device placeholder
                Device (DEV0)
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

                    Method (_RMV, 0, NotSerialized)
                    {
                        Return (One)  // Removable
                    }
                }
            }
        }
    }
}
