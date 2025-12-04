/*
 * SSDT-ALS0.dsl - Ambient Light Sensor Device
 * 
 * Purpose:
 *   Creates a fake Ambient Light Sensor (ALS) device for macOS.
 *   Required by some macOS features even if the laptop doesn't have
 *   a physical ALS, or if the real ALS isn't compatible.
 * 
 * Requirements:
 *   - SMCLightSensor.kext (optional, for better integration)
 *   - Works with or without real hardware ALS
 * 
 * How it works:
 *   1. Creates ALS0 device with ACPI0008 HID (standard ALS)
 *   2. Provides fixed illuminance value (_ALI)
 *   3. Provides ambient light response curve (_ALR)
 * 
 * Values explained:
 *   _ALI = 0x012C (300 lux) - Fixed ambient light reading
 *   _ALR = Response curve mapping light levels to brightness
 *         Package {brightness_adjustment_percent, lux_level}
 *         {0x64, 0x012C} = {100%, 300 lux}
 * 
 * Note: This is a static sensor (always reports same value).
 *       For dynamic readings, SMCLightSensor.kext can provide
 *       real values if your laptop has a compatible ALS.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "ALS0", 0x00001000)
{
    // Place device under System Bus
    Scope (_SB)
    {
        Device (ALS0)
        {
            // Standard ACPI Ambient Light Sensor HID
            Name (_HID, "ACPI0008")
            
            // Compatible ID for macOS SMC light sensor
            Name (_CID, "smc-als")
            
            /*
             * _ALI - Ambient Light Illuminance
             * Returns: Current light level in lux
             * 
             * 0x012C = 300 lux (typical indoor lighting)
             * This is a fixed value since we're faking the sensor
             */
            Name (_ALI, 0x012C)
            
            /*
             * _ALR - Ambient Light Response
             * Returns: Package of brightness adjustment mappings
             * 
             * Format: Package { Package {adjustment_percent, lux_level}, ... }
             * 
             * This tells macOS how to adjust brightness based on light levels.
             * Single entry: 100% brightness at 300 lux
             */
            Name (_ALR, Package (0x01)
            {
                Package (0x02)
                {
                    0x64,    // 100 = 100% brightness adjustment
                    0x012C   // 300 = 300 lux light level
                }
            })
            
            /*
             * _STA - Device Status
             * Only enable on macOS
             */
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)  // Present and enabled
                }
                Else
                {
                    Return (Zero)  // Hidden on other OSes
                }
            }
        }
    }
}
