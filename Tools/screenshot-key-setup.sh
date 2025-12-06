#!/bin/bash
#
# ThinkPad P15 Gen1 - Screenshot Key Setup Guide
# Configures PrtSc key for screenshots on macOS
#

echo "=== ThinkPad Screenshot Key Setup ==="
echo ""

# Helper function to check if a kext is loaded
is_kext_loaded() {
    local kext_name="$1"
    if command -v kmutil &>/dev/null; then
        kmutil showloaded --list-only 2>/dev/null | grep -qi "$kext_name"
    else
        kextstat 2>/dev/null | grep -qi "$kext_name"
    fi
}

# Check if YogaSMC is loaded (required for PrtSc key to work)
if is_kext_loaded "yogasmc"; then
    echo "✓ YogaSMC.kext is loaded"
    echo ""
else
    echo "✗ YogaSMC.kext is NOT loaded"
    echo ""
    echo "ERROR: YogaSMC.kext is required for PrtSc key to work!"
    echo "  - YogaSMC.kext maps PrtSc to F13 which macOS can recognize"
    echo "  - Install YogaSMC.kext and YogaSMCNC.app from:"
    echo "    https://github.com/zhen-zen/YogaSMC/releases/latest"
    echo "  - Set YogaSMCNC.app to launch at login"
    echo ""
    exit 1
fi

# Check if YogaSMC notification center app is installed
if [ -d "/Applications/YogaSMCNC.app" ] || [ -d "$HOME/Applications/YogaSMCNC.app" ]; then
    echo "✓ YogaSMCNC.app is installed"
    echo ""
else
    echo "⚠ YogaSMCNC.app not found in /Applications"
    echo "  Install YogaSMCNC.app for full ThinkPad feature support"
    echo "  Download: https://github.com/zhen-zen/YogaSMC/releases/latest"
    echo ""
fi

echo "=== Setup Instructions ==="
echo ""
echo "STEP 1: Ensure YogaSMCNC is Running"
echo "  - Launch YogaSMCNC.app (should appear in menu bar)"
echo "  - Set it to launch at login in app preferences"
echo "  - YogaSMC.kext maps PrtSc key to F13 for macOS"
echo ""
echo "STEP 2: Map PrtSc in System Settings"
echo "  1. Open System Settings (or System Preferences)"
echo "  2. Go to Keyboard"
echo "  3. Click 'Keyboard Shortcuts...' button"
echo "  4. Select 'Screenshots' from the sidebar"
echo "  5. Click on 'Save picture of screen as a file'"
echo "  6. Press Fn+PrtSc or PrtSc on your keyboard"
echo "     (macOS will register it as F13)"
echo "  7. The shortcut should now show as F13"
echo ""
echo "STEP 3: Test the Key"
echo "  - Press Fn+PrtSc or PrtSc"
echo "  - You should hear the camera shutter sound"
echo "  - Screenshot will be saved to Desktop"
echo ""
echo "=== Alternative Screenshot Options ==="
echo ""
echo "You can also map PrtSc to other screenshot actions:"
echo "  - 'Save picture of selected area as a file' (selection tool)"
echo "  - 'Copy picture of screen to clipboard' (no file saved)"
echo "  - 'Copy picture of selected area to clipboard'"
echo ""
echo "=== macOS Built-in Screenshot Shortcuts ==="
echo "  ⌘+⇧+3  : Capture entire screen"
echo "  ⌘+⇧+4  : Capture selection"
echo "  ⌘+⇧+5  : Screenshot toolbar (recommended)"
echo ""
echo "=== Troubleshooting ==="
echo ""
echo "If PrtSc doesn't work:"
echo "  1. Verify YogaSMC.kext is loaded: kextstat | grep -i yoga"
echo "  2. Check YogaSMCNC.app is running (menu bar icon)"
echo "  3. Restart YogaSMCNC.app"
echo "  4. Try remapping the shortcut in System Settings"
echo "  5. Check YogaSMCNC preferences → Events tab for PrtSc event"
echo ""
echo "=== Setup Complete ==="
