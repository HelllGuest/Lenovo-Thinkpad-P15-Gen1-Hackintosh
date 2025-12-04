#!/bin/bash
#
# ThinkPad P15 Gen1 - Battery Debug Script
# Collects battery-related diagnostic information for troubleshooting
#

echo "=== Battery Debug Information ==="
echo "Date: $(date)"
echo ""

# Helper function to check loaded kexts (compatible with all macOS versions)
check_kext() {
    local kext_name="$1"
    # Try kmutil first (macOS 12+), fallback to kextstat
    if command -v kmutil &>/dev/null; then
        kmutil showloaded --list-only 2>/dev/null | grep -i "$kext_name"
    else
        kextstat 2>/dev/null | grep -i "$kext_name"
    fi
}

echo "1. Loaded Battery-Related Kexts:"
echo "   VirtualSMC:"
check_kext "virtualsmc" | head -1 || echo "   (not found)"
echo "   SMCBatteryManager:"
check_kext "battery" | head -1 || echo "   (not found)"
echo "   YogaSMC:"
check_kext "yogasmc" | head -1 || echo "   (not found)"
echo "   ECEnabler:"
check_kext "ecenabler" | head -1 || echo "   (not found)"
echo ""

echo "2. Battery Status (pmset):"
pmset -g batt
echo ""

echo "3. AppleSmartBattery Info (IORegistry):"
ioreg -r -c AppleSmartBattery -d 1 2>/dev/null | grep -E "^\s+\"(BatteryInstalled|CurrentCapacity|MaxCapacity|DesignCapacity|CycleCount|Voltage|IsCharging|ExternalConnected|FullyCharged|Temperature|Manufacturer|DeviceName)\"" | sed 's/^[ ]*/   /'
echo ""

echo "4. Battery Health (System Profiler):"
system_profiler SPPowerDataType 2>/dev/null | grep -A 15 "Battery Information:" | grep -E "Cycle Count|Condition|Full Charge|Health" | sed 's/^[ ]*/   /'
echo ""

echo "5. ACPI Battery Device:"
if ioreg -l 2>/dev/null | grep -q "PNP0C0A"; then
    echo "   ✓ ACPI battery device (PNP0C0A) found"
else
    echo "   ✗ ACPI battery device not found"
fi
echo ""

echo "6. Recent Battery Kernel Messages (last 5):"
log show --predicate 'process == "kernel"' --style compact --last 1h 2>/dev/null | grep -i "battery\|batt\|smc\|charge" | tail -5 | sed 's/^/   /'
if [ $? -ne 0 ]; then
    echo "   (no recent messages or unable to query)"
fi
echo ""

echo "=== End Debug Info ==="
