#!/bin/bash

# macOS Agent Install Script
# Installs Action1 + ScreenConnect and opens required permission settings

set -e

ACTION1_PKG_URL="INSERTACTION1URL"
SCREENCONNECT_PKG_URL="INSERTSCREENCONNECTURL"

WORKDIR="/tmp/kig-agent-install"
ACTION1_PKG="$WORKDIR/action1.pkg"
SCREENCONNECT_PKG="$WORKDIR/screenconnect.pkg"

echo "Creating working directory..."
mkdir -p "$WORKDIR"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root/admin."
    echo "Run with: sudo ./install-mac-agents.sh"
    exit 1
fi

echo "Downloading Action1 installer..."
curl -L "$ACTION1_PKG_URL" -o "$ACTION1_PKG"

echo "Installing Action1..."
installer -pkg "$ACTION1_PKG" -target /

echo "Downloading ScreenConnect installer..."
curl -L "$SCREENCONNECT_PKG_URL" -o "$SCREENCONNECT_PKG"

echo "Installing ScreenConnect..."
installer -pkg "$SCREENCONNECT_PKG" -target /

echo "Checking installed apps..."
if [ -d "/usr/local/action1" ]; then
    echo "Action1 appears installed."
else
    echo "WARNING: Action1 folder not found."
fi

if pgrep -i "connectwise\|screenconnect" >/dev/null; then
    echo "ScreenConnect appears to be running."
else
    echo "WARNING: ScreenConnect process not detected yet."
fi

echo ""
echo "IMPORTANT: macOS requires manual approval for remote control permissions."
echo "Enable the following for ScreenConnect / ConnectWise Control Client:"
echo "- Accessibility"
echo "- Screen Recording / Screen & System Audio Recording"
echo "- Full Disk Access"
echo ""

echo "Opening Privacy & Security settings..."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
sleep 2
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
sleep 2
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"

echo ""
echo "Install script complete."
echo "Have the user approve ScreenConnect permissions in System Settings."
