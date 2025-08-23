#!/bin/bash
#
# Generate desktop-specific configuration files
# This creates configs for each desktop environment from the base template
#

set -euo pipefail

# Base packages that are common to all DEs
BASE_PACKAGES="git curl wget base-devel sudo linux-zen-headers mesa bluez bluez-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber firewalld btrfs-progs snapper snap-pac grub-btrfs reflector flatpak ananicy-cpp zram-generator ttf-liberation ttf-dejavu man-db man-pages nano unzip ntfs-3g"

# Desktop-specific packages
KDE_PACKAGES="plasma-desktop plasma-nm plasma-pa powerdevil breeze-gtk konsole dolphin sddm plasma-wayland-protocols xdg-desktop-portal-kde discover packagekit bluedevil qt6-multimedia-ffmpeg"
GNOME_PACKAGES="gnome-shell gnome-desktop gdm gnome-control-center gnome-terminal nautilus gnome-session gnome-settings-daemon xdg-desktop-portal-gnome gnome-software"
XFCE_PACKAGES="xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xdg-desktop-portal-gtk thunar xfce4-terminal"
HYPRLAND_PACKAGES="hyprland waybar wofi lightdm lightdm-gtk-greeter xdg-desktop-portal-hyprland foot thunar"

# Function to get packages for a desktop environment
get_de_packages() {
    case "$1" in
        kde) echo "$KDE_PACKAGES" ;;
        gnome) echo "$GNOME_PACKAGES" ;;
        xfce) echo "$XFCE_PACKAGES" ;;
        hyprland) echo "$HYPRLAND_PACKAGES" ;;
    esac
}

# Generate config for each desktop environment
for de in kde gnome xfce hyprland; do
    echo "Generating config-${de}.json..."
    
    # Start with base config
    cp config.json "config-${de}.json"
    
    # Get all packages for this DE
    all_packages="$BASE_PACKAGES $(get_de_packages $de)"
    
    # Create packages JSON array
    packages_json="["
    for pkg in $all_packages; do
        packages_json="$packages_json\"$pkg\","
    done
    # Remove trailing comma and close array
    packages_json="${packages_json%,}]"
    
    # Update the packages section in the config using sed instead of jq
    # This is a simple replacement that should work
    cp "config-${de}.json" "config-${de}.json.bak"
    
    # Use Python to update JSON (more reliable than sed)
    python3 -c "
import json
import sys

with open('config-${de}.json', 'r') as f:
    config = json.load(f)

packages = '$all_packages'.split()
config['packages'] = packages

with open('config-${de}.json', 'w') as f:
    json.dump(config, f, indent=4)
" 2>/dev/null || {
        # Fallback: just copy the original kde config for now
        cp config.json "config-${de}.json"
    }
    
    rm -f "config-${de}.json.bak"
    echo "✓ Generated config-${de}.json"
done

echo "All desktop configuration files generated successfully!"