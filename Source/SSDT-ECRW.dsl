/*
 * SSDT-ECRW.dsl - EC Read/Write Methods for YogaSMC
 * 
 * Purpose:
 *   Provides methods for reading and writing to the Embedded Controller's
 *   memory region. Required by YogaSMC.kext for ThinkPad-specific features
 *   like fan control, battery thresholds, keyboard backlight, etc.
 * 
 * Requirements:
 *   - SSDT-EC.aml must be loaded first
 *   - YogaSMC.kext uses these methods for EC access
 * 
 * Methods provided:
 *   RE1B - Read 1 Byte from EC
 *   RECB - Read EC Buffer (multiple bytes)
 *   WE1B - Write 1 Byte to EC
 *   WECB - Write EC Buffer (multiple bytes)
 * 
 * Why needed:
 *   macOS cannot directly access EC fields larger than 8 bits.
 *   These methods provide byte-by-byte access to work around this limitation.
 * 
 * For: ThinkPad P15 Gen1 | macOS Sonoma 14.x
 */

DefinitionBlock ("", "SSDT", 2, "ZPSS", "ECRW", 0x00001000)
{
    // Reference to the Embedded Controller device
    External (_SB_.PCI0.LPCB.EC__, DeviceObj)

    Scope (\_SB.PCI0.LPCB.EC)
    {
        /*
         * RE1B - Read 1 Byte from EC
         * Arg0: Integer - EC register offset to read from
         * Returns: Integer - Byte value read from EC
         * 
         * Creates a temporary OperationRegion at the specified offset
         * and reads a single byte from it.
         */
        Method (RE1B, 1, NotSerialized)
        {
            // Create 1-byte region at specified offset
            OperationRegion (ERAM, EmbeddedControl, Arg0, One)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8  // 8-bit (1 byte) field
            }

            Return (BYTE)
        }

        /*
         * RECB - Read EC Buffer (multiple bytes)
         * Arg0: Integer - Starting EC register offset
         * Arg1: Integer - Size in BITS to read
         * Returns: Buffer - Data read from EC
         * 
         * Reads multiple bytes by calling RE1B repeatedly.
         * Serialized to prevent concurrent access issues.
         */
        Method (RECB, 2, Serialized)
        {
            // Convert bits to bytes: (bits + 7) / 8
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            
            // Create buffer to hold result
            Name (TEMP, Buffer (Arg1){})
            
            // Calculate end offset
            Arg1 += Arg0
            Local0 = Zero  // Buffer index
            
            // Read byte by byte
            While ((Arg0 < Arg1))
            {
                TEMP [Local0] = RE1B (Arg0)  // Read byte at offset Arg0
                Arg0++                        // Next EC offset
                Local0++                      // Next buffer position
            }

            Return (TEMP)
        }

        /*
         * WE1B - Write 1 Byte to EC
         * Arg0: Integer - EC register offset to write to
         * Arg1: Integer - Byte value to write
         * 
         * Creates a temporary OperationRegion and writes a single byte.
         */
        Method (WE1B, 2, NotSerialized)
        {
            // Create 1-byte region at specified offset
            OperationRegion (ERAM, EmbeddedControl, Arg0, One)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                BYTE,   8  // 8-bit (1 byte) field
            }

            BYTE = Arg1  // Write the value
        }

        /*
         * WECB - Write EC Buffer (multiple bytes)
         * Arg0: Integer - Starting EC register offset
         * Arg1: Integer - Size in BITS to write
         * Arg2: Buffer  - Data to write to EC
         * 
         * Writes multiple bytes by calling WE1B repeatedly.
         * Serialized to prevent concurrent access issues.
         */
        Method (WECB, 3, Serialized)
        {
            // Convert bits to bytes: (bits + 7) / 8
            Arg1 = ((Arg1 + 0x07) >> 0x03)
            
            // Copy input buffer
            Name (TEMP, Buffer (Arg1){})
            TEMP = Arg2
            
            // Calculate end offset
            Arg1 += Arg0
            Local0 = Zero  // Buffer index
            
            // Write byte by byte
            While ((Arg0 < Arg1))
            {
                WE1B (Arg0, DerefOf (TEMP [Local0]))  // Write byte
                Arg0++                                 // Next EC offset
                Local0++                               // Next buffer position
            }
        }
    }
}
