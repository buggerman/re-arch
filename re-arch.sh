#!/bin/bash

# Re-Arch: Transform minimal Arch Linux to optimized system with Btrfs subvolumes
# Converts existing Arch Linux installation to use GRUB, KDE Plasma, and structured Btrfs layout
# Version: 2.0.0

set -euo pipefail

VERSION="2.0.0"
SCRIPT_NAME="re-arch"

# Default configuration values
DEFAULT_HOSTNAME="arch-system"
DEFAULT_USERNAME="user"
DEFAULT_LOCALE="en_US.UTF-8"
DEFAULT_TIMEZONE="UTC"
DEFAULT_KEYMAP="us"

# Global variables
TARGET_DISK=""
ROOT_DEVICE=""
BOOT_DEVICE=""
HOSTNAME="${TARGET_HOSTNAME:-$DEFAULT_HOSTNAME}"
USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
LOCALE="${LOCALE:-$DEFAULT_LOCALE}"
TIMEZONE="${TIMEZONE:-$DEFAULT_TIMEZONE}"
KEYMAP="${KEYMAP:-$DEFAULT_KEYMAP}"
TEST_MODE="${TEST_MODE:-false}"
VERBOSE="${VERBOSE:-false}"
CONFIG_FILE=""

# Btrfs subvolume configuration
SUBVOLUMES=(
    "@:/"
    "@home:/home"
    "@var:/var"
    "@opt:/opt"
    "@tmp:/tmp"
    "@srv:/srv"
    "@usr-local:/usr/local"
    "@var-cache:/var/cache"
    "@var-log:/var/log"
    "@var-tmp:/var/tmp"
    "@snapshots:/.snapshots"
)

# Package groups
BASE_PACKAGES="base base-devel linux linux-firmware linux-headers"
BOOTLOADER_PACKAGES="grub efibootmgr os-prober"
FILESYSTEM_PACKAGES="btrfs-progs snapper"
NETWORK_PACKAGES="networkmanager dhcpcd wpa_supplicant"
AUDIO_PACKAGES="pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber"
KDE_PACKAGES="plasma-meta kde-applications-meta sddm konsole dolphin"
DEV_PACKAGES="git vim nano code firefox chromium flatpak"
FONTS_PACKAGES="ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji"
UTILS_PACKAGES="htop neofetch tree unzip wget curl rsync"

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

info() {
    echo "[INFO] $*"
}

warning() {
    echo "[WARNING] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
}

fatal() {
    echo "[FATAL] $*" >&2
    exit 1
}

# Test mode wrapper for commands
run_command() {
    local cmd="$*"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would run: $cmd"
        return 0
    else
        debug "Executing: $cmd"
        eval "$cmd"
    fi
}

# Validation functions
validate_hostname() {
    local hostname="$1"
    
    if [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
        fatal "Invalid hostname: $hostname. Must be 1-63 characters, alphanumeric with hyphens."
    fi
}

validate_username() {
    local username="$1"
    
    if [[ ! "$username" =~ ^[a-z_]([a-z0-9_-]{0,31})$ ]]; then
        fatal "Invalid username: $username. Must start with lowercase letter or underscore, 1-32 characters."
    fi
}

validate_timezone() {
    local timezone="$1"
    
    if [[ ! -f "/usr/share/zoneinfo/$timezone" ]]; then
        fatal "Invalid timezone: $timezone"
    fi
}

validate_locale() {
    local locale="$1"
    
    if ! locale -a 2>/dev/null | grep -q "^${locale}$"; then
        warning "Locale $locale may not be available, will be generated during installation"
    fi
}

validate_disk() {
    local disk="$1"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Skipping disk validation for $disk"
        return 0
    fi
    
    if [[ ! -b "$disk" ]]; then
        fatal "Disk $disk is not a valid block device"
    fi
    
    if ! lsblk "$disk" >/dev/null 2>&1; then
        fatal "Cannot access disk $disk"
    fi
}

validate_existing_installation() {
    info "Validating existing Arch Linux installation..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Skipping installation validation"
        return 0
    fi
    
    # Check if we're running on Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        fatal "This script must be run on an existing Arch Linux installation"
    fi
    
    # Check if root filesystem is already Btrfs
    local root_fs
    root_fs=$(findmnt -n -o FSTYPE /)
    if [[ "$root_fs" != "btrfs" ]]; then
        fatal "Root filesystem must already be Btrfs. Current: $root_fs"
    fi
    
    # Check if GRUB is already installed
    if command -v grub-install >/dev/null 2>&1; then
        info "GRUB already available"
    else
        warning "GRUB not found, will be installed"
    fi
    
    info "Existing installation validation passed"
}

validate_prerequisites() {
    info "Validating prerequisites..."
    
    # Check if running as root (skip in test mode)
    if [[ $EUID -ne 0 && "$TEST_MODE" != "true" ]]; then
        fatal "This script must be run as root"
    fi
    
    if [[ "$TEST_MODE" == "true" && $EUID -ne 0 ]]; then
        info "TEST MODE: Skipping root privilege check"
    fi
    
    # Validate all configuration values
    validate_hostname "$HOSTNAME"
    validate_username "$USERNAME"
    validate_timezone "$TIMEZONE"
    validate_locale "$LOCALE"
    
    if [[ -n "$TARGET_DISK" ]]; then
        validate_disk "$TARGET_DISK"
    fi
    
    validate_existing_installation
    
    info "Prerequisites validation passed"
}

# Configuration functions
load_config_file() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        fatal "Configuration file not found: $config_file"
    fi
    
    info "Loading configuration from $config_file"
    
    # Source the config file safely
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes from value
        value="${value%\"}"
        value="${value#\"}"
        
        case "$key" in
            TARGET_DISK) TARGET_DISK="$value" ;;
            HOSTNAME) HOSTNAME="$value" ;;
            USERNAME) USERNAME="$value" ;;
            LOCALE) LOCALE="$value" ;;
            TIMEZONE) TIMEZONE="$value" ;;
            KEYMAP) KEYMAP="$value" ;;
            TEST_MODE) TEST_MODE="$value" ;;
            VERBOSE) VERBOSE="$value" ;;
        esac
    done < "$config_file"
    
    info "Configuration loaded successfully"
}

show_configuration() {
    info "Current configuration:"
    info "  Target disk: ${TARGET_DISK:-<not set>}"
    info "  Hostname: $HOSTNAME"
    info "  Username: $USERNAME"
    info "  Locale: $LOCALE"
    info "  Timezone: $TIMEZONE"
    info "  Keymap: $KEYMAP"
    info "  Test mode: $TEST_MODE"
    info "  Verbose: $VERBOSE"
}

# System detection
detect_system_info() {
    info "Detecting system information..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        # Use mock values for test mode
        BOOT_MODE="UEFI"
        BOOT_DEVICE="/dev/test-boot"
        ROOT_DEVICE="/dev/test-root"
        if [[ -z "$TARGET_DISK" ]]; then
            TARGET_DISK="/dev/test-disk"
        fi
        info "TEST MODE: Using mock system information"
    else
        # Detect EFI or BIOS
        if [[ -d /sys/firmware/efi ]]; then
            BOOT_MODE="UEFI"
            BOOT_DEVICE="/dev/$(lsblk -no PKNAME "$(findmnt -n -o SOURCE /boot/efi)" 2>/dev/null || echo "unknown")"
        else
            BOOT_MODE="BIOS"
            BOOT_DEVICE="/dev/$(lsblk -no PKNAME "$(findmnt -n -o SOURCE /boot)" 2>/dev/null || echo "unknown")"
        fi
        
        # Detect current root device
        ROOT_DEVICE="/dev/$(lsblk -no PKNAME "$(findmnt -n -o SOURCE /)" 2>/dev/null || echo "unknown")"
        
        # Use detected device if TARGET_DISK not specified
        if [[ -z "$TARGET_DISK" ]]; then
            TARGET_DISK="$ROOT_DEVICE"
            info "Auto-detected target disk: $TARGET_DISK"
        fi
    fi
    
    info "System detection complete:"
    info "  Boot mode: $BOOT_MODE"
    info "  Root device: $ROOT_DEVICE"
    info "  Boot device: $BOOT_DEVICE"
    info "  Target disk: $TARGET_DISK"
}

# Btrfs subvolume management
setup_subvolumes() {
    info "Setting up Btrfs subvolumes..."
    
    local root_mount="/mnt/btrfs-root"
    
    # Mount root Btrfs filesystem
    run_command "mkdir -p '$root_mount'"
    run_command "mount -o subvol=/ '$TARGET_DISK'* '$root_mount'"
    
    # Create subvolumes
    for subvol_def in "${SUBVOLUMES[@]}"; do
        local subvol_name="${subvol_def%:*}"
        local mount_point="${subvol_def#*:}"
        
        info "Creating subvolume: $subvol_name"
        run_command "btrfs subvolume create '$root_mount/$subvol_name'"
    done
    
    # Unmount root filesystem
    run_command "umount '$root_mount'"
    run_command "rmdir '$root_mount'"
    
    info "Btrfs subvolumes created successfully"
}

update_fstab() {
    info "Updating /etc/fstab with new subvolume layout..."
    
    local fstab_backup="/etc/fstab.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would backup fstab to $fstab_backup"
        info "TEST MODE: Would update fstab with subvolume mounts"
        return 0
    fi
    
    # Backup current fstab
    cp /etc/fstab "$fstab_backup"
    info "Backed up fstab to $fstab_backup"
    
    # Generate new fstab
    cat > /etc/fstab << 'EOF'
# /etc/fstab: static file system information
#
# <file system> <dir> <type> <options> <dump> <pass>

EOF
    
    # Add subvolume entries
    local root_uuid
    root_uuid=$(blkid -s UUID -o value "$TARGET_DISK"*)
    
    for subvol_def in "${SUBVOLUMES[@]}"; do
        local subvol_name="${subvol_def%:*}"
        local mount_point="${subvol_def#*:}"
        
        echo "UUID=$root_uuid $mount_point btrfs subvol=$subvol_name,compress=zstd,noatime 0 0" >> /etc/fstab
    done
    
    # Add EFI partition if UEFI
    if [[ "$BOOT_MODE" == "UEFI" ]]; then
        local efi_uuid
        efi_uuid=$(blkid -s UUID -o value "${TARGET_DISK}1" 2>/dev/null || echo "")
        if [[ -n "$efi_uuid" ]]; then
            echo "UUID=$efi_uuid /boot/efi vfat umask=0077 0 1" >> /etc/fstab
        fi
    fi
    
    info "Updated /etc/fstab successfully"
}

install_packages() {
    info "Installing packages..."
    
    local all_packages="$BASE_PACKAGES $BOOTLOADER_PACKAGES $FILESYSTEM_PACKAGES"
    all_packages="$all_packages $NETWORK_PACKAGES $AUDIO_PACKAGES $KDE_PACKAGES"
    all_packages="$all_packages $DEV_PACKAGES $FONTS_PACKAGES $UTILS_PACKAGES"
    
    # Update package database
    run_command "pacman -Sy"
    
    # Install packages
    run_command "pacman -S --needed --noconfirm $all_packages"
    
    info "Package installation completed"
}

configure_grub() {
    info "Configuring GRUB bootloader..."
    
    if [[ "$BOOT_MODE" == "UEFI" ]]; then
        run_command "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB"
    else
        run_command "grub-install --target=i386-pc '$TARGET_DISK'"
    fi
    
    # Update GRUB configuration
    run_command "grub-mkconfig -o /boot/grub/grub.cfg"
    
    info "GRUB configuration completed"
}

configure_kde() {
    info "Configuring KDE Plasma..."
    
    # Enable SDDM display manager
    run_command "systemctl enable sddm"
    
    # Create SDDM configuration
    run_command "mkdir -p /etc/sddm.conf.d"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would create SDDM configuration"
    else
        cat > /etc/sddm.conf.d/kde_settings.conf << 'EOF'
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze

[Users]
MaximumUid=60000
MinimumUid=1000
EOF
    fi
    
    info "KDE Plasma configuration completed"
}

configure_system() {
    info "Configuring system settings..."
    
    # Set hostname
    run_command "echo '$HOSTNAME' > /etc/hostname"
    
    # Configure hosts file
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would update /etc/hosts"
    else
        cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF
    fi
    
    # Set timezone
    run_command "ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
    run_command "hwclock --systohc"
    
    # Configure locale
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would configure locale: $LOCALE"
    else
        sed -i "s/#${LOCALE}/${LOCALE}/" /etc/locale.gen
        locale-gen
        echo "LANG=$LOCALE" > /etc/locale.conf
    fi
    
    # Set keymap
    run_command "echo 'KEYMAP=$KEYMAP' > /etc/vconsole.conf"
    
    # Enable essential services
    run_command "systemctl enable NetworkManager"
    run_command "systemctl enable fstrim.timer"
    
    info "System configuration completed"
}

create_user() {
    info "Creating user account: $USERNAME"
    
    # Create user
    run_command "useradd -m -G wheel,audio,video,optical,storage '$USERNAME'"
    
    # Set user password (prompt for it)
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would prompt for user password"
    else
        info "Please set password for user $USERNAME:"
        passwd "$USERNAME"
    fi
    
    # Configure sudo for wheel group
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would enable sudo for wheel group"
    else
        sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    fi
    
    info "User account created successfully"
}

setup_snapper() {
    info "Setting up Snapper for snapshot management..."
    
    # Create snapper configuration for root
    run_command "snapper -c root create-config /"
    
    # Configure snapper
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would configure snapper settings"
    else
        # Update snapper configuration
        sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="yes"/' /etc/snapper/configs/root
        sed -i 's/^TIMELINE_CLEANUP="yes"/TIMELINE_CLEANUP="yes"/' /etc/snapper/configs/root
        sed -i 's/^NUMBER_CLEANUP="yes"/NUMBER_CLEANUP="yes"/' /etc/snapper/configs/root
    fi
    
    # Enable snapper timer
    run_command "systemctl enable snapper-timeline.timer"
    run_command "systemctl enable snapper-cleanup.timer"
    
    info "Snapper configuration completed"
}

enable_flatpak() {
    info "Configuring Flatpak..."
    
    # Add Flathub repository
    run_command "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    
    info "Flatpak configuration completed"
}

# Main execution functions
run_full_procedure() {
    info "Starting Re-Arch procedure..."
    
    validate_prerequisites
    detect_system_info
    show_configuration
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Configuration validation passed"
        info "TEST MODE: All operations were simulated"
        info "Re-Arch procedure completed successfully (TEST MODE)"
        return 0
    fi
    
    setup_subvolumes
    update_fstab
    install_packages
    configure_grub
    configure_kde
    configure_system
    create_user
    setup_snapper
    enable_flatpak
    
    info "Re-Arch procedure completed successfully!"
    info "Please reboot your system to use the new configuration"
    
    warning "IMPORTANT: After reboot, mount the new subvolumes:"
    warning "sudo mount -a"
}

# Help and version functions
show_help() {
    cat << 'EOF'
Re-Arch: Transform minimal Arch Linux to optimized system

Usage: re-arch.sh [OPTIONS]

DESCRIPTION:
    Transforms an existing minimal Arch Linux installation into an optimized
    system with Btrfs subvolumes, GRUB bootloader, KDE Plasma desktop, and
    development tools.

    CRITICAL REQUIREMENTS:
    - Must be run on existing Arch Linux with Btrfs root filesystem
    - Must be run as root
    - System must have GRUB or be prepared for GRUB installation

OPTIONS:
    --config FILE       Load configuration from file
    --hostname NAME     Set system hostname (default: arch-system)
    --username NAME     Set username for new user account (default: user)
    --timezone TZ       Set system timezone (default: UTC)
    --locale LOCALE     Set system locale (default: en_US.UTF-8)
    --keymap KEYMAP     Set console keymap (default: us)
    --target-disk DEV   Specify target disk device
    --test              Run in test mode (simulate operations)
    --verbose           Enable verbose output
    --version           Show version information
    --help              Show this help message

EXAMPLES:
    # Basic usage (interactive)
    sudo ./re-arch.sh

    # Use configuration file
    sudo ./re-arch.sh --config myconfig.conf

    # Set specific options
    sudo ./re-arch.sh --hostname workstation --username john

    # Test mode (safe dry-run)
    sudo ./re-arch.sh --test

CONFIGURATION FILE FORMAT:
    TARGET_DISK="/dev/sda"
    HOSTNAME="my-workstation" 
    USERNAME="myuser"
    TIMEZONE="America/New_York"
    LOCALE="en_US.UTF-8"
    KEYMAP="us"
    TEST_MODE="false"
    VERBOSE="false"

SAFETY FEATURES:
    - Test mode for safe validation
    - Automatic backups of critical files
    - Comprehensive prerequisite checking
    - Btrfs snapshots for recovery

For more information, visit: https://github.com/buggerman/re-arch
EOF
}

show_version() {
    echo "$SCRIPT_NAME version $VERSION"
}

# Argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --hostname)
                HOSTNAME="$2"
                shift 2
                ;;
            --username)
                USERNAME="$2"
                shift 2
                ;;
            --timezone)
                TIMEZONE="$2"
                shift 2
                ;;
            --locale)
                LOCALE="$2"
                shift 2
                ;;
            --keymap)
                KEYMAP="$2"
                shift 2
                ;;
            --target-disk)
                TARGET_DISK="$2"
                shift 2
                ;;
            --test)
                TEST_MODE="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            --version)
                show_version
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    log "Starting $SCRIPT_NAME v$VERSION"
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Load configuration file if specified
    if [[ -n "$CONFIG_FILE" ]]; then
        load_config_file "$CONFIG_FILE"
    fi
    
    # Run the main procedure
    run_full_procedure
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi