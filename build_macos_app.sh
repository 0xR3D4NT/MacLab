#!/bin/bash

# Generic macOS App Builder
# Usage: ./build_macos_app.sh your_program.c [AppName] [BundleID] [Version]
# This script automatically creates Info.plist and builds a complete macOS app

set -e  # Exit on any error

# Function to show usage
show_usage() {
    echo "Usage: $0 <source.c> [AppName] [BundleID] [Version]"
    echo ""
    echo "Parameters:"
    echo "  source.c    - Your C source file (required)"
    echo "  AppName     - Display name for the app (optional, defaults to filename)"
    echo "  BundleID    - Bundle identifier (optional, defaults to com.example.appname)"
    echo "  Version     - App version (optional, defaults to 1.0)"
    echo ""
    echo "Examples:"
    echo "  $0 hello.c"
    echo "  $0 calculator.c \"My Calculator\" \"com.mycompany.calculator\" \"2.1\""
    echo "  $0 game.c \"Awesome Game\""
    exit 1
}

# Check if we have at least one argument
if [ $# -lt 1 ]; then
    show_usage
fi

# Parse arguments
SOURCE_FILE="$1"
APP_NAME="${2:-}"
BUNDLE_ID="${3:-}"
VERSION="${4:-1.0}"

# Validate source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "❌ Error: Source file '$SOURCE_FILE' not found!"
    exit 1
fi

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Extract filename without extension for defaults
BASENAME=$(basename "$SOURCE_FILE" .c)

# Set defaults if not provided
if [ -z "$APP_NAME" ]; then
    # Convert filename to Title Case (hello_world -> Hello World)
    APP_NAME=$(echo "$BASENAME" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
fi

if [ -z "$BUNDLE_ID" ]; then
    # Convert to lowercase and replace spaces/underscores with dots
    CLEAN_NAME=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
    BUNDLE_ID="com.example.$CLEAN_NAME"
fi

# Create safe filename for app bundle (remove special characters)
SAFE_APP_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9 ]//g')
APP_BUNDLE="$SAFE_APP_NAME.app"
EXECUTABLE_NAME=$(echo "$BASENAME" | sed 's/[^a-zA-Z0-9]//g')

echo "🚀 Building macOS Application..."
echo "   Source: $SOURCE_FILE"
echo "   App Name: $APP_NAME"
echo "   Bundle ID: $BUNDLE_ID"
echo "   Version: $VERSION"
echo "   Output: $APP_BUNDLE"
echo ""

# Step 1: Analyze the source code to determine app type
echo "🔍 Analyzing source code..."
HAS_PRINTF=$(grep -q "printf\|cout\|puts" "$SOURCE_FILE" && echo "true" || echo "false")
HAS_SCANF=$(grep -q "scanf\|cin\|getchar\|gets" "$SOURCE_FILE" && echo "true" || echo "false")
HAS_OSASCRIPT=$(grep -q "osascript\|system.*osascript\|system.*display.*dialog" "$SOURCE_FILE" && echo "true" || echo "false")
HAS_APPLESCRIPT=$(grep -q "display dialog\|display alert\|display notification" "$SOURCE_FILE" && echo "true" || echo "false")

# Determine app type based on analysis
if [ "$HAS_OSASCRIPT" = "true" ] || [ "$HAS_APPLESCRIPT" = "true" ]; then
    echo "🎭 Detected AppleScript/osascript - creating GUI dialog app"
    NEEDS_TERMINAL="false"
    IS_GUI_APP="true"
    USES_APPLESCRIPT="true"
elif [ "$HAS_PRINTF" = "true" ] || [ "$HAS_SCANF" = "true" ]; then
    echo "📺 Detected console I/O - will create terminal-launching app"
    NEEDS_TERMINAL="true"
    IS_GUI_APP="false"
    USES_APPLESCRIPT="false"
else
    echo "🖥️  No specific I/O detected - creating standard app"
    NEEDS_TERMINAL="false"
    IS_GUI_APP="false"
    USES_APPLESCRIPT="false"
fi

# Step 2: Create appropriate compilation based on app type
if [ "$USES_APPLESCRIPT" = "true" ]; then
    echo "🎭 Compiling AppleScript-enabled app..."
    # Direct compilation - no wrapper needed for osascript apps
    gcc -arch x86_64 -arch arm64 -o "$EXECUTABLE_NAME" "$SOURCE_FILE"
    
elif [ "$NEEDS_TERMINAL" = "true" ]; then
    echo "🔧 Creating terminal wrapper..."
    
    # Compile the original program
    gcc -arch x86_64 -arch arm64 -o "${EXECUTABLE_NAME}_main" "$SOURCE_FILE"
    
    # Create a wrapper script that opens Terminal
    cat > "${EXECUTABLE_NAME}_wrapper.c" << EOF
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main() {
    char command[1024];
    char *bundle_path = getenv("BUNDLE_PATH");
    
    if (bundle_path == NULL) {
        // Fallback: try to find the bundle path
        char *app_path = strdup(__FILE__);
        char *contents_pos = strstr(app_path, "Contents/MacOS");
        if (contents_pos != NULL) {
            *contents_pos = '\0';
            bundle_path = app_path;
        } else {
            bundle_path = ".";
        }
    }
    
    // Create command to open Terminal and run our program
    snprintf(command, sizeof(command), 
        "osascript -e 'tell application \"Terminal\" to do script \"%s/Contents/MacOS/${EXECUTABLE_NAME}_main; echo \"\\nPress any key to close...\"; read -n 1; exit\"'",
        bundle_path);
    
    system(command);
    return 0;
}
EOF
    
    # Compile the wrapper
    gcc -arch x86_64 -arch arm64 -o "$EXECUTABLE_NAME" "${EXECUTABLE_NAME}_wrapper.c"
    rm "${EXECUTABLE_NAME}_wrapper.c"
    
else
    # Direct compilation for standard apps
    echo "📦 Compiling application..."
    gcc -arch x86_64 -arch arm64 -o "$EXECUTABLE_NAME" "$SOURCE_FILE"
fi

# Step 3: Create Info.plist dynamically
echo "📄 Generating Info.plist..."
cat > "Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
EOF

# Add app-type specific properties
if [ "$USES_APPLESCRIPT" = "true" ]; then
    cat >> "Info.plist" << EOF
    <key>LSUIElement</key>
    <false/>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app uses AppleScript to display dialogs and interact with the system.</string>
    <key>NSAppleScriptEnabled</key>
    <true/>
    <key>OSAScriptingDefinition</key>
    <string>Standard Scripting</string>
EOF
elif [ "$NEEDS_TERMINAL" = "true" ]; then
    cat >> "Info.plist" << EOF
    <key>LSUIElement</key>
    <false/>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app needs to launch Terminal to display output.</string>
EOF
fi

cat >> "Info.plist" << EOF
</dict>
</plist>
EOF

# Step 4: Create the .app bundle structure
echo "🏗️  Creating app bundle structure..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Step 5: Copy files to the bundle
cp "$EXECUTABLE_NAME" "$APP_BUNDLE/Contents/MacOS/"
if [ "$NEEDS_TERMINAL" = "true" ]; then
    cp "${EXECUTABLE_NAME}_main" "$APP_BUNDLE/Contents/MacOS/"
fi
cp "Info.plist" "$APP_BUNDLE/Contents/"

# Step 6: Set proper permissions
chmod +x "$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"
if [ "$NEEDS_TERMINAL" = "true" ]; then
    chmod +x "$APP_BUNDLE/Contents/MacOS/${EXECUTABLE_NAME}_main"
fi

# Step 7: Check for code signing certificate
echo "🔐 Checking for code signing certificate..."
CERT_NAME=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)".*/\1/' 2>/dev/null || echo "")

if [ -n "$CERT_NAME" ]; then
    echo "✅ Found certificate: $CERT_NAME"
    echo "🔏 Code signing the application..."
    
    # Sign all executables
    codesign --force --deep --sign "$CERT_NAME" "$APP_BUNDLE/Contents/MacOS/"*
    
    # Then sign the app bundle
    codesign --force --deep --sign "$CERT_NAME" --options runtime "$APP_BUNDLE"
    
    # Verify the signature
    echo "✅ Verifying code signature..."
    codesign --verify --deep --strict "$APP_BUNDLE"
    spctl --assess --type exec "$APP_BUNDLE"
    
    echo "✅ Application successfully signed!"
    SIGNED=true
else
    echo "ℹ️  No Developer ID certificate found. Proceeding without code signing..."
    echo "✅ App bundle created successfully (unsigned)"
    SIGNED=false
fi

# Step 8: Create DMG contents directory
echo "💿 Preparing DMG contents..."
DMG_NAME="$SAFE_APP_NAME"
rm -rf dmg_contents
mkdir -p dmg_contents
cp -R "$APP_BUNDLE" dmg_contents/

# Add Applications symlink for easy installation
ln -s /Applications dmg_contents/Applications

# Step 9: Create a professional DMG
echo "📀 Creating DMG installer..."
rm -f "$DMG_NAME.dmg" "${DMG_NAME}_temp.dmg"

# Create temporary DMG
hdiutil create -srcfolder dmg_contents -volname "$APP_NAME" -fs HFS+ -format UDRW -size 50m "${DMG_NAME}_temp.dmg"

# Mount and customize the DMG
MOUNT_DIR=$(hdiutil attach "${DMG_NAME}_temp.dmg" | grep "/Volumes" | sed 's/.*\/Volumes/\/Volumes/')
DEVICE=$(hdiutil attach "${DMG_NAME}_temp.dmg" | grep "/dev/disk" | sed 's/\/dev\/\([^ ]*\).*/\1/' | head -1)

# Customize DMG appearance
echo "🎨 Customizing DMG appearance..."
osascript <<EOF
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 400}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set position of item "$SAFE_APP_NAME.app" of container window to {150, 150}
        set position of item "Applications" of container window to {350, 150}
        update without registering applications
        delay 2
        close
    end tell
end tell
EOF

# Unmount and convert to read-only
hdiutil detach "$MOUNT_DIR"
hdiutil convert "${DMG_NAME}_temp.dmg" -format UDZO -o "$DMG_NAME.dmg"
rm "${DMG_NAME}_temp.dmg"

# Step 10: Sign the DMG if we have a certificate
if [ "$SIGNED" = true ]; then
    echo "🔏 Code signing the DMG..."
    codesign --force --sign "$CERT_NAME" "$DMG_NAME.dmg"
fi

# Step 11: Clean up temporary files
echo "🧹 Cleaning up..."
rm "$EXECUTABLE_NAME"
if [ "$NEEDS_TERMINAL" = "true" ]; then
    rm "${EXECUTABLE_NAME}_main"
fi
rm "Info.plist"
rm -rf dmg_contents

echo ""
echo "✅ Build completed successfully!"
echo "📁 Created files:"
echo "   - $APP_BUNDLE (Application bundle)"
echo "   - $DMG_NAME.dmg (Installer disk image)"
echo ""
echo "🧪 Testing the app:"
echo "1. Double-click '$APP_BUNDLE' to test"
echo "2. Mount '$DMG_NAME.dmg' and test from there"
echo ""

if [ "$SIGNED" = true ]; then
    echo "🛡️  Security features:"
    echo "✅ Code signed - Gatekeeper will allow execution"
    echo "✅ Hardened runtime enabled"
else
    echo "🛡️  Security notice:"
    echo "⚠️  Not code signed - Gatekeeper will show warning"
    echo "   Users can run by: Right-click → Open → Open"
    echo "   Or temporarily: System Preferences → Security → Allow apps from anywhere"
    echo ""
    echo "💡 The app will still work perfectly, just with an extra security step!"
fi

if [ "$NEEDS_TERMINAL" = "true" ]; then
    echo ""
    echo "📺 Console App Features:"
    echo "✅ Automatically opens Terminal when launched"
    echo "✅ Shows program output in Terminal window"
    echo "✅ Waits for user input before closing"
elif [ "$USES_APPLESCRIPT" = "true" ]; then
    echo ""
    echo "🎭 AppleScript App Features:"
    echo "✅ Native macOS dialog boxes and alerts"
    echo "✅ Full AppleScript/osascript support"
    echo "✅ Proper system integration and permissions"
fi

echo ""
echo "🚀 Ready for distribution!"
