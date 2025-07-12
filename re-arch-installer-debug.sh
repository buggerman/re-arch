#!/bin/bash
#
# Re-Arch Single Command Installer - Debug Version
#

echo "🚀 Re-Arch Installer Started"
echo "============================="

# Simple test to see if we get this far
echo "Script is running..."

# Check if we're root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Error: This script must be run as root"
    exit 1
fi

echo "✅ Running as root"

# Check if archinstall exists
if ! command -v archinstall &> /dev/null; then
    echo "❌ Error: archinstall not found"
    exit 1
fi

echo "✅ archinstall found"

# Check internet
if ! ping -c 1 archlinux.org &>/dev/null; then
    echo "❌ Error: No internet connection"
    exit 1
fi

echo "✅ Internet connection OK"

echo ""
echo "Environment checks passed!"
echo "This is where the actual installation would start."
echo ""

read -p "Continue with installation? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo "Would run: archinstall --config-url https://re-arch.xyz/archinstall-config.json --creds-url https://re-arch.xyz/archinstall-credentials.json"
echo "Would run: arch-chroot /mnt curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash"
echo ""
echo "✅ Debug complete!"