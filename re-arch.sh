#!/bin/bash

# The Re-Arch Procedure
# Professional automation script for transforming minimal Arch Linux installations
# into optimized, resilient desktop systems with KDE Plasma and snapshot management

set -euo pipefail

#===============================================================================
# CONFIGURATION SECTION - EDIT THESE VALUES BEFORE RUNNING
#===============================================================================

# USERNAME will be prompted during execution
USERNAME=""

# OPTIONAL: Customize these settings as needed
HOSTNAME="arch-desktop"
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"

#===============================================================================
# CONSTANTS AND GLOBALS
#===============================================================================

readonly SCRIPT_VERSION="1.0.0"
readonly LOG_FILE="/var/log/re-arch.log"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

#===============================================================================
# LOGGING AND OUTPUT FUNCTIONS
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
# SAFETY AND VALIDATION FUNCTIONS
#===============================================================================

prompt_for_username() {
    echo
    echo "============================================================================="
    echo -e "${BLUE}                      USER ACCOUNT CONFIGURATION${NC}"
    echo "============================================================================="
    echo
    info "Please enter your existing non-root username."
    info "This should be the user account you created during Arch installation."
    echo
    
    while true; do
        echo -n "Username: " >/dev/tty
        read -r input_username </dev/tty
        
        # Validate input is not empty
        if [[ -z "$input_username" ]]; then
            warning "Username cannot be empty. Please try again."
            continue
        fi
        
        # Validate user exists
        if ! id "$input_username" &>/dev/null; then
            warning "User '$input_username' does not exist on this system."
            echo "Available users:"
            getent passwd | awk -F: '$3 >= 1000 { print "  • " $1 }'
            echo
            continue
        fi
        
        # Validate user has sudo privileges (check wheel group first)
        if groups "$input_username" | grep -q wheel 2>/dev/null; then
            success "User '$input_username' is in wheel group."
        elif sudo -u "$input_username" sudo -n true 2>/dev/null; then
            success "User '$input_username' has sudo privileges."
        else
            warning "User '$input_username' does not appear to have sudo privileges."
            warning "User is not in 'wheel' group and sudo test failed."
            echo -n "Continue anyway? (y/N): " >/dev/tty
            read -r continue_response </dev/tty
            case "$continue_response" in
                [Yy]|[Yy][Ee][Ss])
                    warning "Continuing without full sudo verification..."
                    ;;
                *)
                    echo "Please ensure user has sudo access or choose a different user."
                    continue
                    ;;
            esac
        fi
        
        # Success
        USERNAME="$input_username"
        success "User '$USERNAME' validated successfully."
        break
    done
    
    echo "============================================================================="
    echo
}

display_warning() {
    echo
    echo "============================================================================="
    echo -e "${RED}                            CRITICAL WARNING${NC}"
    echo "============================================================================="
    echo
    echo "This script will make EXTENSIVE changes to your system including:"
    echo "  • Installing and configuring KDE Plasma desktop environment"
    echo "  • Modifying bootloader configuration (GRUB)"
    echo "  • Installing performance optimization tools"
    echo "  • Setting up automatic snapshot management"
    echo "  • Configuring system services and firewall"
    echo
    echo "This script is designed for FRESH, MINIMAL Arch Linux installations ONLY."
    echo
    echo -e "${YELLOW}DO NOT RUN THIS ON PRODUCTION SYSTEMS OR SYSTEMS WITH EXISTING DATA.${NC}"
    echo
    echo "Prerequisites verified:"
    echo "  ✓ Running as root"
    echo "  ✓ Btrfs root filesystem detected"
    echo "  ✓ User account '$USERNAME' exists"
    echo
    echo "============================================================================="
    echo
    
    local confirmation
    while true; do
        echo -n "Type 'YES' in capital letters to proceed, or 'NO' to abort: " >/dev/tty
        read -r confirmation </dev/tty
        
        case "$confirmation" in
            "YES")
                info "User confirmed. Proceeding with system transformation..."
                break
                ;;
            "NO"|"no"|"No")
                info "User aborted. Exiting safely."
                exit 0
                ;;
            *)
                warning "Invalid input. Please type exactly 'YES' or 'NO'."
                ;;
        esac
    done
}

run_checks() {
    info "Running pre-execution safety checks..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: ./re-arch.sh"
    fi
    
    # Check if we're on Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        error "This script is designed for Arch Linux only."
    fi
    
    # Check if root filesystem is Btrfs
    local root_fs
    root_fs=$(findmnt -n -o FSTYPE /)
    if [[ "$root_fs" != "btrfs" ]]; then
        error "Root filesystem must be Btrfs. Current: $root_fs"
    fi
    
    # Prompt for username if not configured
    if [[ -z "$USERNAME" ]]; then
        prompt_for_username
    fi
    
    # Check if the specified user exists
    if ! id "$USERNAME" &>/dev/null; then
        error "User '$USERNAME' does not exist. Please create the user first or correct the USERNAME variable."
    fi
    
    # Check if user has sudo privileges
    if ! sudo -u "$USERNAME" sudo -l &>/dev/null; then
        error "User '$USERNAME' does not have sudo privileges. Configure sudo access first."
    fi
    
    # Check internet connectivity
    if ! ping -c 1 archlinux.org &>/dev/null; then
        error "No internet connectivity. Please establish network connection first."
    fi
    
    success "All safety checks passed."
}

#===============================================================================
# SYSTEM CONFIGURATION FUNCTIONS
#===============================================================================

configure_pacman() {
    info "Optimizing pacman configuration..."
    
    # Backup original configuration
    cp /etc/pacman.conf /etc/pacman.conf.backup
    
    # Enable parallel downloads and color output
    sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
    sed -i 's/#Color/Color/' /etc/pacman.conf
    sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
    
    # Enable multilib repository
    sed -i '/^#\[multilib\]/,/^#Include/ { s/^#//; }' /etc/pacman.conf
    
    # Update package databases
    pacman -Sy
    
    success "Pacman configuration optimized."
}

install_packages() {
    info "Installing system packages..."
    
    # Update keyring first
    pacman -S --noconfirm archlinux-keyring
    
    # Core system packages
    local core_packages=(
        "linux-zen"
        "linux-zen-headers" 
        "base-devel"
        "git"
    )
    
    # Desktop environment packages
    local desktop_packages=(
        "plasma-desktop"
        "konsole"
        "dolphin"
        "sddm"
        "plasma-wayland-protocols"
        "xdg-desktop-portal-kde"
        "networkmanager"
    )
    
    # Performance and system packages
    local performance_packages=(
        "ananicy-cpp"
        "zram-generator"
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse" 
        "pipewire-jack"
        "wireplumber"
        "firewalld"
    )
    
    # Snapshot and boot packages  
    local snapshot_packages=(
        "snapper"
        "snap-pac"
        "grub-btrfs"
    )
    
    # Combine all package arrays
    local all_packages=()
    all_packages+=("${core_packages[@]}")
    all_packages+=("${desktop_packages[@]}")
    all_packages+=("${performance_packages[@]}")
    all_packages+=("${snapshot_packages[@]}")
    
    # Install all packages
    info "Installing ${#all_packages[@]} packages..."
    pacman -S --needed --noconfirm "${all_packages[@]}"
    
    success "Package installation completed."
}

configure_system() {
    info "Configuring basic system settings..."
    
    # Set hostname
    echo "$HOSTNAME" > /etc/hostname
    
    # Configure hosts file
    cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF
    
    # Set timezone
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    hwclock --systohc
    
    # Configure locale
    echo "$LOCALE UTF-8" > /etc/locale.gen
    locale-gen
    echo "LANG=$LOCALE" > /etc/locale.conf
    
    # Configure vconsole
    echo "KEYMAP=us" > /etc/vconsole.conf
    
    success "Basic system configuration completed."
}

setup_aur() {
    info "Setting up AUR helper (paru)..."
    
    # Switch to user context for AUR operations
    sudo -u "$USERNAME" bash << 'EOF'
cd /home/$SUDO_USER

# Clone paru repository
git clone https://aur.archlinux.org/paru.git
cd paru

# Build and install paru
makepkg -si --noconfirm

# Clean up
cd ..
rm -rf paru
EOF
    
    success "AUR helper (paru) installed successfully."
}

configure_snapshots() {
    info "Configuring snapshot management..."
    
    # Check if snapper config already exists
    if snapper -c root list &>/dev/null; then
        warning "Snapper configuration already exists for root, skipping creation."
    else
        # Remove any existing /.snapshots if it exists
        if [[ -d /.snapshots ]]; then
            warning "Removing existing /.snapshots directory..."
            umount /.snapshots 2>/dev/null || true
            rm -rf /.snapshots
        fi
        
        # Create snapper configuration for root
        if ! snapper -c root create-config /; then
            warning "Failed to create snapper config, attempting cleanup and retry..."
            # Clean up and try again
            rm -rf /.snapshots
            snapper -c root create-config /
        fi
    fi
    
    # Configure snapper settings (only if config file exists)
    if [[ -f /etc/snapper/configs/root ]]; then
        sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="yes"/' /etc/snapper/configs/root
        sed -i 's/^TIMELINE_CLEANUP="yes"/TIMELINE_CLEANUP="yes"/' /etc/snapper/configs/root
        sed -i 's/^NUMBER_CLEANUP="yes"/NUMBER_CLEANUP="yes"/' /etc/snapper/configs/root
        sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="10"/' /etc/snapper/configs/root
        sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root
    fi
    
    # Create snapper group if it doesn't exist
    if ! getent group snapper &>/dev/null; then
        groupadd snapper
    fi
    
    # Set proper permissions for user
    usermod -a -G snapper "$USERNAME"
    
    # Set permissions on .snapshots if it exists
    if [[ -d /.snapshots ]]; then
        # Only change ownership of the .snapshots directory itself, not the contents
        chown :snapper /.snapshots 2>/dev/null || true
        chmod 750 /.snapshots 2>/dev/null || true
        
        # Set ownership on individual snapshot directories (but not their contents)
        for snapshot_dir in /.snapshots/*/; do
            if [[ -d "$snapshot_dir" ]]; then
                chown :snapper "$snapshot_dir" 2>/dev/null || true
                chmod 750 "$snapshot_dir" 2>/dev/null || true
            fi
        done
    fi
    
    success "Snapshot management configured."
}

configure_bootloader() {
    info "Configuring GRUB bootloader with snapshot support..."
    
    # Install GRUB to the boot device (assumes single disk setup)
    local boot_device root_source
    root_source=$(findmnt -n -o SOURCE /)
    
    # Extract the actual device from Btrfs subvolume notation (e.g., /dev/sda2[/@] -> /dev/sda2)
    root_source=${root_source%%\[*}
    
    # Get the parent device (e.g., /dev/sda2 -> sda)
    boot_device=$(lsblk -no PKNAME "$root_source" | head -1)
    
    if [[ -n "$boot_device" ]]; then
        info "Installing GRUB to /dev/$boot_device..."
        grub-install "/dev/$boot_device"
    else
        warning "Could not determine boot device, attempting to install to disk..."
        # Fallback: try to get the disk from the root device
        local disk_device
        disk_device=$(echo "$root_source" | sed 's/[0-9]*$//')
        grub-install "$disk_device"
    fi
    
    # Configure GRUB for Btrfs snapshots
    echo 'GRUB_BTRFS_LIMIT="10"' >> /etc/default/grub
    echo 'GRUB_BTRFS_SHOW_SNAPSHOTS_FOUND="true"' >> /etc/default/grub
    
    # Regenerate GRUB configuration
    grub-mkconfig -o /boot/grub/grub.cfg
    
    success "GRUB bootloader configured with snapshot support."
}

enable_services() {
    info "Enabling system services..."
    
    local services=(
        "sddm.service"
        "NetworkManager.service"
        "firewalld.service"
        "snapper-timeline.timer"
        "snapper-cleanup.timer"
        "grub-btrfsd.service"
        "ananicy-cpp.service"
    )
    
    for service in "${services[@]}"; do
        info "Enabling $service..."
        systemctl enable "$service"
    done
    
    success "System services enabled."
}

setup_user_environment() {
    info "Setting up user environment for $USERNAME..."
    
    # Get user home directory
    local user_home
    user_home=$(getent passwd "$USERNAME" | cut -d: -f6)
    
    # Setup Flatpak and Flathub as user
    info "Setting up Flatpak repository..."
    if sudo -u "$USERNAME" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
        success "Flathub repository added."
    else
        warning "Failed to add Flathub repository (might already exist)."
    fi
    
    # Setup LinuxBrew
    info "Installing LinuxBrew..."
    
    # Create LinuxBrew directory
    sudo -u "$USERNAME" mkdir -p "$user_home/.linuxbrew"
    
    # Clone LinuxBrew if not already present
    if [[ ! -d "$user_home/.linuxbrew/Homebrew" ]]; then
        if sudo -u "$USERNAME" git clone https://github.com/Homebrew/brew "$user_home/.linuxbrew/Homebrew"; then
            success "LinuxBrew installed successfully."
        else
            warning "Failed to install LinuxBrew."
            return 1
        fi
    else
        info "LinuxBrew already installed."
    fi
    
    # Add LinuxBrew to .bashrc if not already present
    local bashrc_file="$user_home/.bashrc"
    if ! grep -q "linuxbrew" "$bashrc_file" 2>/dev/null; then
        info "Adding LinuxBrew to .bashrc..."
        sudo -u "$USERNAME" bash -c "cat >> '$bashrc_file'" << EOF

# LinuxBrew
export PATH="$user_home/.linuxbrew/Homebrew/bin:\$PATH"
export MANPATH="$user_home/.linuxbrew/Homebrew/share/man:\$MANPATH"
export INFOPATH="$user_home/.linuxbrew/Homebrew/share/info:\$INFOPATH"
EOF
        success "LinuxBrew added to .bashrc."
    else
        info "LinuxBrew already configured in .bashrc."
    fi
    
    success "User environment configured for $USERNAME."
}

#===============================================================================
# MAIN EXECUTION FUNCTION
#===============================================================================

main() {
    info "Starting The Re-Arch Procedure v$SCRIPT_VERSION"
    info "Target user: $USERNAME"
    info "Hostname: $HOSTNAME"
    info "Timezone: $TIMEZONE"
    info "Locale: $LOCALE"
    
    # Create log file
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    
    # Run safety checks
    run_checks
    
    # Display warning and get user confirmation
    display_warning
    
    # Execute configuration steps
    configure_pacman
    install_packages
    configure_system
    setup_aur
    configure_snapshots  
    configure_bootloader
    enable_services
    setup_user_environment
    
    # Final success message
    echo
    echo "============================================================================="
    success "The Re-Arch Procedure completed successfully!"
    echo "============================================================================="
    echo
    info "System transformation complete. Next steps:"
    echo "  1. Exit the chroot environment: exit"
    echo "  2. Unmount the filesystem: umount -R /mnt"  
    echo "  3. Reboot into your new system: reboot"
    echo "  4. Log in through SDDM with user: $USERNAME"
    echo
    info "Your system now includes:"
    echo "  • KDE Plasma desktop with Wayland support"
    echo "  • Automatic snapshot management (snapper)"
    echo "  • Performance optimizations (linux-zen, ananicy-cpp)"
    echo "  • Modern audio system (PipeWire)"
    echo "  • AUR helper (paru) for additional packages"
    echo "  • Flatpak and LinuxBrew package managers"
    echo
    warning "Remember to reboot to activate all changes!"
    echo "============================================================================="
}

#===============================================================================
# SCRIPT EXECUTION
#===============================================================================

# Execute main function if script is run directly (including piped execution)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    main "$@"
fi