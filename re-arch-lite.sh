#!/bin/bash

# The Re-Arch Procedure - Lite Version
# Post-installation configuration script for systems installed with enhanced archinstall-config.json
# This script only handles configuration that archinstall cannot do

set -euo pipefail

#===============================================================================
# CONFIGURATION
#===============================================================================

USERNAME=""
readonly SCRIPT_VERSION="2.0.0-lite"
readonly LOG_FILE="/var/log/re-arch-lite.log"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

#===============================================================================
# LOGGING FUNCTIONS
#===============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log "INFO" "$*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    log "SUCCESS" "$*"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
    log "WARNING" "$*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    log "ERROR" "$*"
    exit 1
}

#===============================================================================
# VALIDATION AND SETUP
#===============================================================================

prompt_for_username() {
    echo
    echo "============================================================================="
    echo -e "${BLUE}                      USER ACCOUNT CONFIGURATION${NC}"
    echo "============================================================================="
    echo
    info "Please enter your username (created during archinstall)."
    echo
    
    while true; do
        echo -n "Username: " >/dev/tty
        read -r input_username </dev/tty
        
        if [[ -z "$input_username" ]]; then
            warning "Username cannot be empty. Please try again."
            continue
        fi
        
        if ! id "$input_username" &>/dev/null; then
            warning "User '$input_username' does not exist."
            continue
        fi
        
        USERNAME="$input_username"
        success "User '$USERNAME' validated successfully."
        break
    done
}

run_basic_checks() {
    info "Running basic validation..."
    
    # Check root
    if [[ $EUID -ne 0 ]]; then
        error "Must run as root"
    fi
    
    # Check Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        error "Not running on Arch Linux"
    fi
    
    # Get username
    if [[ -z "$USERNAME" ]]; then
        prompt_for_username
    fi
    
    success "Basic validation completed"
}

#===============================================================================
# CONFIGURATION FUNCTIONS
#===============================================================================

configure_snapshots() {
    info "Configuring snapshot management..."
    
    # Create snapper group if needed
    if ! getent group snapper &>/dev/null; then
        groupadd snapper
    fi
    
    # Add user to snapper group
    usermod -a -G snapper "$USERNAME"
    
    # Configure snapper for root if not already done
    # Suppress D-Bus errors in chroot environment
    if ! snapper -c root list &>/dev/null 2>&1; then
        if [[ -d /.snapshots ]]; then
            umount /.snapshots 2>/dev/null || true
            rm -rf /.snapshots
        fi
        
        # Create snapper configuration with D-Bus error suppression
        if ! snapper -c root create-config / 2>/dev/null; then
            warning "Snapper configuration creation failed (normal in chroot - will work after reboot)"
            # Try creating basic config directory structure manually
            mkdir -p /etc/snapper/configs
            cat > /etc/snapper/configs/root << 'EOF'
# snapper configuration for root filesystem
SUBVOLUME="/"
FSTYPE="btrfs"
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
NUMBER_CLEANUP="yes"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
EOF
            info "Created basic snapper configuration manually"
        fi
    fi
    
    # Configure snapper settings
    if [[ -f /etc/snapper/configs/root ]]; then
        sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="10"/' /etc/snapper/configs/root
        sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root
    fi
    
    # Set permissions
    if [[ -d /.snapshots ]]; then
        chown :snapper /.snapshots 2>/dev/null || true
        chmod 750 /.snapshots 2>/dev/null || true
    fi
    
    success "Snapshot management configured"
}

configure_bootloader() {
    info "Configuring GRUB for snapshots..."
    
    # Add GRUB Btrfs configuration
    echo 'GRUB_BTRFS_LIMIT="10"' >> /etc/default/grub
    echo 'GRUB_BTRFS_SHOW_SNAPSHOTS_FOUND="true"' >> /etc/default/grub
    
    # Regenerate GRUB config
    grub-mkconfig -o /boot/grub/grub.cfg
    
    success "GRUB configured for snapshots"
}

enable_services() {
    info "Enabling system services..."
    
    local services=(
        "sddm.service"
        "firewalld.service"
        "snapper-timeline.timer"
        "snapper-cleanup.timer"
        "grub-btrfsd.service"
        "ananicy-cpp.service"
        "packagekit.service"
    )
    
    for service in "${services[@]}"; do
        if systemctl enable "$service" 2>/dev/null; then
            success "✓ $service enabled"
        else
            warning "✗ Failed to enable $service"
        fi
    done
    
    success "System services configuration completed"
}


setup_user_environment() {
    info "Setting up user environment..."
    
    local user_home
    user_home=$(getent passwd "$USERNAME" | cut -d: -f6)
    
    # Setup Flatpak (suppress D-Bus errors in chroot environment)  
    info "Setting up Flatpak repositories..."
    if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
        success "Flathub repository added system-wide"
    else
        warning "Flathub system setup failed (normal in chroot - will work after reboot)"
    fi
    
    if sudo -u "$USERNAME" flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
        info "Flathub repository added for user"
    else
        info "Flathub user setup failed (normal in chroot - will work after reboot)"
    fi
    
    # Setup LinuxBrew
    sudo -u "$USERNAME" mkdir -p "$user_home/.linuxbrew"
    
    if [[ ! -d "$user_home/.linuxbrew/Homebrew" ]]; then
        sudo -u "$USERNAME" git clone https://github.com/Homebrew/brew "$user_home/.linuxbrew/Homebrew"
    fi
    
    # Add to .bashrc if not present
    if ! grep -q "linuxbrew" "$user_home/.bashrc" 2>/dev/null; then
        sudo -u "$USERNAME" bash -c "cat >> '$user_home/.bashrc'" << EOF

# LinuxBrew
export PATH="$user_home/.linuxbrew/Homebrew/bin:\$PATH"
export MANPATH="$user_home/.linuxbrew/Homebrew/share/man:\$MANPATH"
export INFOPATH="$user_home/.linuxbrew/Homebrew/share/info:\$INFOPATH"
EOF
    fi
    
    success "User environment configured"
}

optimize_mirrors() {
    info "Optimizing package mirrors..."
    
    if command -v reflector >/dev/null 2>&1; then
        reflector --country "United States,Canada,Germany,France,United Kingdom" \
                  --protocol https \
                  --latest 10 \
                  --sort rate \
                  --save /etc/pacman.d/mirrorlist
        success "Mirrors optimized"
    else
        warning "Reflector not available, skipping mirror optimization"
    fi
}

#===============================================================================
# MAIN EXECUTION
#===============================================================================

main() {
    info "Starting Re-Arch Lite v$SCRIPT_VERSION"
    info "Post-installation configuration for enhanced archinstall setup"
    
    # Create log file
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    
    # Run configuration
    run_basic_checks
    optimize_mirrors
    configure_snapshots
    configure_bootloader
    enable_services
    setup_user_environment
    
    # Success message
    echo
    echo "============================================================================="
    success "Re-Arch Lite configuration completed successfully!"
    echo "============================================================================="
    echo
    info "Your optimized Arch Linux system is ready!"
    echo "  • KDE Plasma desktop with Wayland support"
    echo "  • Automatic snapshot management with GRUB integration"  
    echo "  • Performance optimizations (linux-zen, ananicy-cpp)"
    echo "  • Flatpak and LinuxBrew package managers"
    echo "  • Quality fonts (Liberation, DejaVu, Noto)"
    echo
    warning "Reboot to activate all changes: reboot"
    echo "============================================================================="
}

# Execute main function
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    main "$@"
fi