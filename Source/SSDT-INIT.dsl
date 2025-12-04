/*
 * SSDT-INIT.dsl - System Initialization Variables
 * 
 * Purpose:
 *   Sets global ACPI variables on boot to enable features for macOS.
 *   Some DSDT code paths check these variables to determine OS type
 *   and enable/disable specific functionality.
 * 
 * Requirements:
 *   - Should load after EC-related SSDTs
 *   - Variables must exist in DSDT (External declarations)
 * 
 * Variables set:
 *   STAS = 1 : Status flag (enables certain code paths)
 *   LNUX = 1 : Linux flag (some features check this)
 *   WNTF = 1 : Windows NT flag (enables NT-compatible code)
 * 
 * Why needed:
 *   The DSDT may contain conditional code that only runs when
 *   these variables are set. Setting them ensures all features
 *   are enabled regardless of what the DSDT's default detection does.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "INIT", 0x00001000)
{
    // External references to global DSDT variables
    External (LNUX, IntObj)  // Linux detection flag
    External (STAS, IntObj)  // Status flag
    External (WNTF, IntObj)  // Windows NT flag

    // Root scope - applies globally
    Scope (\)
    {
        /*
         * _INI - System Initialize Method
         * Called automatically at boot before devices initialize
         * 
         * Sets compatibility flags when running on macOS (Darwin)
         */
        Method (_INI, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                // Enable all compatibility modes for macOS
                STAS = One  // General status flag
                LNUX = One  // Linux compatibility mode
                WNTF = One  // Windows NT compatibility mode
            }
        }
    }
}
