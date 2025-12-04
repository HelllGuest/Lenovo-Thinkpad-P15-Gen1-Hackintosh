#!/bin/bash
#
# ThinkPad P15 Gen1 - Screenshot Key Setup Script
# Configures Fn+PrtSc or other keys for screenshots on macOS
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

# Check if YogaSMC is loaded (injected by OpenCore)
if is_kext_loaded "yogasmc"; then
    echo "✓ YogaSMC is loaded"
    echo ""
    echo "OPTION 1: Configure in YogaSMC (RECOMMENDED)"
    echo "  1. Click YogaSMC icon in menu bar"
    echo "  2. Open Preferences"
    echo "  3. Go to 'Events' tab"
    echo "  4. Find event 0x1312 (PrtSc key)"
    echo "  5. Add action: Screenshot"
    echo ""
else
    echo "✗ YogaSMC not loaded"
    echo "  Install YogaSMC.kext for ThinkPad hotkey support"
    echo ""
fi

# Check if Karabiner-Elements is installed
if [ -d "/Applications/Karabiner-Elements.app" ]; then
    echo "✓ Karabiner-Elements installed"
    echo ""
    echo "OPTION 2: Use Karabiner-Elements"
    echo "  1. Open Karabiner-Elements"
    echo "  2. Go to 'Simple Modifications'"
    echo "  3. Add mapping: print_screen → command+shift+4"
    echo "  Or for selection screenshot:"
    echo "  3. Add mapping: print_screen → command+shift+5"
    echo ""
else
    echo "○ Karabiner-Elements not installed"
    echo "  Optional: https://karabiner-elements.pqrs.org/"
    echo ""
fi

echo "OPTION 3: Create Quick Action (No extra software)"
echo ""
echo -n "Create a Quick Action for screenshots? [y/N] "
read -r REPLY
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    WORKFLOW_DIR="$HOME/Library/Services"
    WORKFLOW_PATH="$WORKFLOW_DIR/ThinkPad Screenshot.workflow"
    
    # Create directory if needed
    mkdir -p "$WORKFLOW_PATH/Contents"
    
    # Create Info.plist
    cat > "$WORKFLOW_PATH/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>ThinkPad Screenshot</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
        </dict>
    </array>
</dict>
</plist>
PLIST

    # Create workflow document
    cat > "$WORKFLOW_PATH/Contents/document.wflow" << 'WORKFLOW'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                </dict>
                <key>ActionClass</key>
                <string>RunShellScriptAction</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>screencapture -i -U ~/Desktop/Screenshot-$(date +%Y%m%d-%H%M%S).png</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>0</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                </dict>
            </dict>
        </dict>
    </array>
</dict>
</plist>
WORKFLOW

    echo "✓ Quick Action created: $WORKFLOW_PATH"
    echo ""
    echo "To assign a keyboard shortcut:"
    echo "  1. System Settings → Keyboard → Keyboard Shortcuts"
    echo "  2. Select 'Services' in sidebar"
    echo "  3. Expand 'General' section"
    echo "  4. Find 'ThinkPad Screenshot'"
    echo "  5. Click 'none' and press your desired shortcut"
    echo ""
else
    echo "Skipped Quick Action creation."
    echo ""
fi

echo "=== macOS Built-in Screenshot Shortcuts ==="
echo "  ⌘+⇧+3  : Capture entire screen"
echo "  ⌘+⇧+4  : Capture selection"
echo "  ⌘+⇧+5  : Screenshot toolbar"
echo "  ⌘+⇧+6  : Capture Touch Bar (if applicable)"
echo ""
echo "=== Setup Complete ==="
