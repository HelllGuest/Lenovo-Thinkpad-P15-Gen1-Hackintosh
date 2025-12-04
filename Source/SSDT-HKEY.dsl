/*
 * SSDT-HKEY.dsl - ThinkPad Hotkey Methods for YogaSMC
 * 
 * Purpose:
 *   Provides additional methods in the ThinkPad HKEY device for YogaSMC.kext.
 *   Enables fan control, LED control, EC access, and DYTC thermal management.
 * 
 * Requirements:
 *   - SSDT-EC.aml and SSDT-ECRW.aml must be loaded first
 *   - YogaSMC.kext uses these methods for ThinkPad features
 * 
 * Features enabled:
 *   - Fan speed monitoring and control
 *   - ThinkPad LED control (ThinkLight, etc.)
 *   - EC register read/write access
 *   - DYTC (Dynamic Thermal Control) for performance modes
 *   - System status indicator control
 * 
 * HKEY Device:
 *   ThinkPad-specific device that handles hotkeys and special functions.
 *   Located at \_SB.PCI0.LPCB.EC.HKEY in DSDT.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "HKEY", 0x00001000)
{
    // External references to DSDT methods and objects
    External (_SB_.DYTC, MethodObj)                    // Dynamic Thermal Control
    External (_SB_.PCI0.LPCB.EC__, DeviceObj)          // Embedded Controller
    External (_SB_.PCI0.LPCB.EC__.FANE, FieldUnitObj)  // Fan Enable status
    External (_SB_.PCI0.LPCB.EC__.HFNI, FieldUnitObj)  // Fan initialization
    External (_SB_.PCI0.LPCB.EC__.HFSP, FieldUnitObj)  // Fan speed setting
    External (_SB_.PCI0.LPCB.EC__.HKEY, DeviceObj)     // HKEY device
    External (_SB_.PCI0.LPCB.EC__.LED_, MethodObj)     // LED control method
    External (_SB_.PCI0.LPCB.EC__.VRST, FieldUnitObj)  // Reset status
    External (_SB_.RBEC, MethodObj)                    // Read byte from EC
    External (_SB_.WBEC, MethodObj)                    // Write byte to EC
    External (_SI_._SST, MethodObj)                    // System Status indicator

    Scope (\_SB.PCI0.LPCB.EC.HKEY)
    {
        /*
         * DYTC - Dynamic Thermal Control
         * Arg0: Control command
         * Returns: Result from system DYTC method
         * 
         * Used for ThinkPad performance mode switching:
         * - Balanced mode
         * - Performance mode
         * - Cool/quiet mode
         */
        Method (DYTC, 1, Serialized)
        {
            Return (\_SB.DYTC (Arg0))
        }

        /*
         * FANR - Fan Read Status
         * Returns: Package {Error code, Fan enabled status}
         * 
         * Reads current fan enable state from EC.
         * FANE = 1 means fan control is active
         */
        Method (FANR, 0, NotSerialized)
        {
            Local0 = Package (0x02)
                {
                    Zero,                       // Error code (0 = success)
                    \_SB.PCI0.LPCB.EC.FANE      // Current fan enable status
                }
            Return (Local0)
        }

        /*
         * FANS - Fan Set Enable
         * Arg0: Enable flag (1 = enable, 0 = disable)
         * Returns: Zero (success)
         * 
         * Enables or disables fan control through EC.
         */
        Method (FANS, 1, NotSerialized)
        {
            If (Arg0)
            {
                \_SB.PCI0.LPCB.EC.FANE = One   // Enable fan
            }
            Else
            {
                \_SB.PCI0.LPCB.EC.FANE = Zero  // Disable fan
            }

            Return (Zero)
        }

        /*
         * LED - LED Control
         * Arg0: LED identifier
         * Arg1: State (on/off/blink)
         * Returns: Zero (success)
         * 
         * Controls ThinkPad LEDs (ThinkLight, power, etc.)
         */
        Method (LED, 2, NotSerialized)
        {
            \_SB.PCI0.LPCB.EC.LED (Arg0, Arg1)
            Return (Zero)
        }

        /*
         * RBEC - Read Byte from EC
         * Arg0: EC register offset
         * Returns: Byte value from EC
         * 
         * Wrapper for system EC read method.
         */
        Method (RBEC, 1, NotSerialized)
        {
            Return (\_SB.RBEC (Arg0))
        }

        /*
         * WBEC - Write Byte to EC
         * Arg0: EC register offset
         * Arg1: Value to write
         * Returns: Zero (success)
         * 
         * Wrapper for system EC write method.
         */
        Method (WBEC, 2, NotSerialized)
        {
            \_SB.WBEC (Arg0, Arg1)
            Return (Zero)
        }

        /*
         * CSSI - Control System Status Indicator
         * Arg0: Status code
         * 
         * Controls system status indicator (sleep/wake LED behavior).
         */
        Method (CSSI, 1, NotSerialized)
        {
            If (CondRefOf (\_SI._SST))
            {
                \_SI._SST (Arg0)
            }
        }

        /*
         * CFSP - Control Fan Speed
         * Arg0: Fan speed value
         * 
         * Directly sets fan speed through EC register.
         * Used by YogaSMC for manual fan control.
         */
        Method (CFSP, 1, NotSerialized)
        {
            If (CondRefOf (\_SB.PCI0.LPCB.EC.HFSP))
            {
                \_SB.PCI0.LPCB.EC.HFSP = Arg0
            }
        }

        /*
         * CFNI - Control Fan Initialize
         * Arg0: Initialization value
         * 
         * Fan initialization control register.
         */
        Method (CFNI, 1, NotSerialized)
        {
            If (CondRefOf (\_SB.PCI0.LPCB.EC.HFNI))
            {
                \_SB.PCI0.LPCB.EC.HFNI = Arg0
            }
        }

        /*
         * CRST - Control Reset Status
         * Arg0: Reset value
         * 
         * Controls reset status register in EC.
         */
        Method (CRST, 1, NotSerialized)
        {
            If (CondRefOf (\_SB.PCI0.LPCB.EC.VRST))
            {
                \_SB.PCI0.LPCB.EC.VRST = Arg0
            }
        }
    }
}
