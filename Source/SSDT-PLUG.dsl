/*
 * SSDT-PLUG.dsl - CPU Power Management Plugin Type
 * 
 * Purpose:
 *   Enables Intel CPU power management (SpeedStep/Turbo Boost) on macOS.
 *   Sets plugin-type=1 on the first CPU core (PR00) to enable native
 *   power management via Apple's X86PlatformPlugin.kext.
 * 
 * Requirements:
 *   - Only needs to be applied to first CPU core (PR00)
 *   - Other cores inherit the setting automatically
 * 
 * How it works:
 *   plugin-type=1 tells macOS to use XCPM (Xnu CPU Power Management)
 *   which provides:
 *   - Frequency scaling (SpeedStep)
 *   - Turbo Boost support
 *   - C-states for power saving
 *   - Hardware P-states (HWP) on supported CPUs
 * 
 * Note: Your DSDT uses PR00 for the first processor.
 *       Some systems use CPU0 or P000 instead.
 * 
 * For: ThinkPad P15 Gen1 (Intel i7-10850H) | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "PLUG", 0x00001000)
{
    // Reference to first CPU core (Processor Object)
    // Path varies by system: PR00, CPU0, P000, etc.
    External (_SB_.PR00, ProcessorObj)

    Scope (\_SB.PR00)
    {
        // Only apply on macOS
        If (_OSI ("Darwin"))
        {
            /*
             * _DSM - Device Specific Method
             * Used to inject device properties into macOS
             * 
             * Arg0: UUID (unused here)
             * Arg1: Revision (unused here)
             * Arg2: Function index - 0 returns supported functions
             * Arg3: Package (unused here)
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

                // Function 1+: Return properties
                Return (Package (0x02)
                {
                    "plugin-type",  // Property name
                    One             // Value: 1 = Enable XCPM
                })
            }
        }
    }
}
