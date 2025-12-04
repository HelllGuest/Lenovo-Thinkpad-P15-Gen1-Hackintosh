/*
 * SSDT-DGPU.dsl - Discrete GPU Disable (Safe Version)
 * 
 * Purpose:
 *   Disables the NVIDIA Quadro discrete GPU on macOS.
 *   NVIDIA GPUs are not supported in macOS since Mojave (10.14).
 *   This SSDT hides the dGPU from macOS to prevent initialization issues.
 * 
 * Requirements:
 *   - WhateverGreen.kext with -wegnoegpu boot argument (recommended)
 *   - Or this SSDT alone for basic hiding
 * 
 * How it works:
 *   This safe version does NOT call _OFF/_ON methods (which may not exist).
 *   Instead, it:
 *   1. Overrides _STA on the PEGP device to return 0 (hidden) on macOS
 *   2. Lets WhateverGreen handle actual power management via -wegnoegpu
 * 
 * GPU Location in DSDT:
 *   \_SB.PCI0.PEG0.PEGP = PCI Express Graphics slot (dGPU)
 *   The device exists but has no _OFF/_ON methods in this DSDT.
 * 
 * Recommended boot-args (in config.plist):
 *   -wegnoegpu    : WhateverGreen disables all external GPUs
 *   
 * Benefits of this approach:
 *   - No ACPI errors from calling non-existent methods
 *   - Works regardless of DSDT power management methods
 *   - WhateverGreen provides reliable GPU disabling
 *   - Reduced power consumption and heat
 * 
 * For: ThinkPad P15 Gen1 (NVIDIA Quadro) | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "DGPU", 0x00001000)
{
    // Reference to discrete GPU device in DSDT
    // PEG0 = PCI Express Graphics Port 0
    // PEGP = PCI Express Graphics device (the actual GPU)
    External (_SB_.PCI0.PEG0.PEGP, DeviceObj)

    // Override the dGPU's status method
    Scope (\_SB.PCI0.PEG0.PEGP)
    {
        /*
         * _STA - Device Status Override
         * Returns: Status flags
         * 
         * On macOS: Return 0 (device not present/disabled)
         * On other OS: Return 0x0F (device present and functional)
         * 
         * This hides the dGPU from macOS device enumeration,
         * preventing driver loading and initialization attempts.
         */
        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                // macOS: Hide the discrete GPU
                // Returning 0 means "device not present"
                Return (Zero)
            }
            Else
            {
                // Windows/Linux: Keep GPU enabled
                Return (0x0F)
            }
        }
    }
    
    /*
     * Note: For complete dGPU power-off, add to config.plist boot-args:
     * 
     *   -wegnoegpu
     * 
     * This WhateverGreen argument ensures the GPU is fully disabled
     * and powered down, providing maximum battery life improvement.
     * 
     * Alternative: If your BIOS has "Hybrid Graphics" or "Discrete Only"
     * options, setting to "Integrated Only" in BIOS is the cleanest solution.
     */
}
