/*
 * SSDT-XOSI.dsl - Operating System Interface Override
 * 
 * Purpose:
 *   Overrides the _OSI (Operating System Interface) method to make ACPI tables
 *   think macOS is Windows. Many laptop features (trackpad, hotkeys) only enable
 *   when the OS identifies as Windows.
 * 
 * Requirements:
 *   - Requires _OSI to XOSI rename in config.plist ACPI patches
 *   - Must load FIRST before other SSDTs that may check _OSI
 * 
 * How it works:
 *   1. When macOS (Darwin) calls _OSI, this method intercepts
 *   2. If asking about Windows versions, returns TRUE (0xFFFFFFFF)
 *   3. For other OS checks, passes through to original _OSI
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "XOSI", 0x00001000)
{
    /*
     * XOSI Method - Replacement for _OSI
     * Arg0: String - OS name being queried (e.g., "Windows 2015")
     * Returns: Integer - TRUE (0xFFFFFFFF) if OS matches, FALSE (0) otherwise
     */
    Method (XOSI, 1, NotSerialized)
    {
        // List of Windows versions to spoof support for
        // These correspond to: XP, XP SP1, XP SP2, Vista, Win7, Win8, Win8.1, Win10
        Local0 = Package (0x08)
            {
                "Windows 2001",      // Windows XP
                "Windows 2001 SP1",  // Windows XP SP1
                "Windows 2001 SP2",  // Windows XP SP2
                "Windows 2006",      // Windows Vista
                "Windows 2009",      // Windows 7
                "Windows 2012",      // Windows 8
                "Windows 2013",      // Windows 8.1
                "Windows 2015"       // Windows 10
            }

        // Only apply Windows spoofing when running on macOS (Darwin)
        If (_OSI ("Darwin"))
        {
            // Check if Arg0 matches any Windows version in our list
            // MEQ = Match Equal, MTR = Match True (always match for second condition)
            Local1 = Match (Local0, MEQ, Arg0, MTR, Zero, Zero)
            
            If ((Local1 != Ones))
            {
                // Match found - return TRUE (Windows version supported)
                Return (0xFFFFFFFF)
            }
            Else
            {
                // No match - return FALSE
                Return (Zero)
            }
        }
        Else
        {
            // Not macOS - pass through to original _OSI method
            Return (_OSI (Arg0))
        }
    }
}
