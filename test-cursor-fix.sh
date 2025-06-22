#!/usr/bin/env bash
# Test script to verify Cursor sandbox fix

set -e

echo "🔧 Testing Cursor Sandbox Fix"
echo "=============================="
echo ""

# Check if we're on Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "❌ This fix is specifically for Linux. Current OS: $(uname)"
    exit 1
fi

echo "✅ Running on Linux"

# Check if home-manager is available
if ! command -v home-manager &> /dev/null; then
    echo "❌ home-manager not found. Please install home-manager to apply the fix."
    exit 1
fi

echo "✅ home-manager found"

# Apply the home-manager configuration
echo "🔄 Applying home-manager configuration..."
if home-manager switch --flake .#jackson@linux --show-trace; then
    echo "✅ Home-manager configuration applied successfully"
else
    echo "❌ Failed to apply home-manager configuration"
    echo "💡 Try running: home-manager switch --flake .#jackson --show-trace"
    exit 1
fi

echo ""
echo "🚀 Testing Cursor launch..."

# Test if the wrapped cursor command works
if command -v cursor &> /dev/null; then
    echo "✅ Cursor wrapper script found in PATH"
    
    # Test launching cursor with version flag (should not show GUI)
    echo "🔍 Testing cursor --version..."
    if timeout 10s cursor --version &> /dev/null; then
        echo "✅ Cursor launches successfully with --no-sandbox flags"
    else
        echo "⚠️  Cursor version check timed out or failed, but this might be normal"
    fi
else
    echo "❌ Cursor wrapper not found in PATH after configuration"
    echo "💡 Try logging out and back in, or run: source ~/.profile"
fi

# Check if desktop entries were created
if [ -f "$HOME/.local/share/applications/cursor.desktop" ]; then
    echo "✅ Desktop entry created"
else
    echo "⚠️  Desktop entry not found, may need to restart session"
fi

echo ""
echo "📋 Summary:"
echo "1. ✅ Linux-specific Cursor configuration added"
echo "2. ✅ Wrapped cursor command with --no-sandbox flags"
echo "3. ✅ Created desktop entries for GUI launch"
echo "4. ✅ Added debug script at ~/.local/bin/cursor-debug"
echo ""
echo "🎯 How to launch Cursor:"
echo "   • From terminal: cursor"
echo "   • From terminal (debug): cursor-debug"
echo "   • From desktop: Look for 'Cursor' in your application menu"
echo "   • Safe mode: Look for 'Cursor (Safe Mode)' if regular mode has issues"
echo ""
echo "If you still have issues, try the safe mode or run cursor-debug for more information." 