#!/bin/bash
#
# Re-Arch Lite Configuration
# Minimal post-install configuration for archinstall systems
#

set -euo pipefail

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# Get username
get_user() {
    local users=($(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}'))
    if [[ ${#users[@]} -eq 1 ]]; then
        echo "${users[0]}"
    elif [[ ${#users[@]} -gt 1 ]]; then
        info "Multiple users found: ${users[*]}"
        echo "user"  # Default fallback
    else
        echo "user"  # Default fallback
    fi
}

# Detect desktop environment
detect_de() {
    pacman -Qq plasma-desktop &>/dev/null && echo "kde" && return
    pacman -Qq gnome-shell &>/dev/null && echo "gnome" && return
    pacman -Qq xfce4 &>/dev/null && echo "xfce" && return
    pacman -Qq hyprland &>/dev/null && echo "hyprland" && return
    echo "unknown"
}

# Get display manager service
get_dm() {
    case "$1" in
        kde) echo "sddm.service" ;;
        gnome) echo "gdm.service" ;;
        xfce|hyprland) echo "lightdm.service" ;;
        *) echo "sddm.service" ;;
    esac
}


# Main configuration
main() {
    info "Re-Arch Lite Configuration Starting..."
    
    # Validate environment
    [[ $EUID -eq 0 ]] || error "Must run as root"
    [[ -f /etc/arch-release ]] || error "Not Arch Linux"
    
    USERNAME=$(get_user)
    DESKTOP=$(detect_de)
    DM=$(get_dm "$DESKTOP")
    
    info "User: $USERNAME | Desktop: $DESKTOP | Display Manager: ${DM%.*}"
    
    # Configure snapshots
    info "Configuring snapshots..."
    if ! snapper -c root list &>/dev/null 2>&1; then
        snapper -c root create-config / 2>/dev/null || {
            # Manual config if snapper fails in chroot
            mkdir -p /.snapshots /etc/snapper/configs
            cat > /etc/snapper/configs/root << 'EOF'
SUBVOLUME="/"
FSTYPE="btrfs"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
EOF
        }
    fi
    
    # Add user to snapper group
    getent group snapper >/dev/null || groupadd snapper
    usermod -a -G snapper "$USERNAME" 2>/dev/null || true
    
    # Configure GRUB for snapshots
    info "Configuring GRUB..."
    echo 'GRUB_BTRFS_LIMIT="10"' >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    
    # Configure zram
    info "Configuring zram..."
    cat > /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
    
    # Configure ananicy
    info "Configuring process optimization..."
    mkdir -p /etc/ananicy.d
    cat > /etc/ananicy.d/00-default.rules << 'EOF'
# Re-Arch process optimization
{ "name": "firefox", "type": "BG_CPUSET" }
{ "name": "chromium", "type": "BG_CPUSET" }
{ "name": "code", "type": "Heavy_CPU" }
EOF
    
    # Enable services
    info "Enabling services..."
    systemctl enable NetworkManager firewalld "$DM" \
                     snapper-timeline.timer snapper-cleanup.timer \
                     ananicy-cpp systemd-zram-setup@zram0.service 2>/dev/null || true
    
    # Configure Flatpak
    info "Configuring Flatpak..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    
    success "Configuration complete!"
    echo ""
    info "Next steps after reboot:"
    echo "  • Login: $USERNAME/rearch"
    echo "  • Install browser: flatpak install flathub org.mozilla.firefox"
    echo "  • Update system: sudo pacman -Syu"
}

main "$@"
