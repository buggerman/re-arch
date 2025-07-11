#!/bin/bash

# Re-Arch Procedure: Convert Arch Linux to Atomic System
# This script transforms a minimal Arch Linux installation into an atomic system
# with Btrfs subvolumes and snapshot-based updates

set -euo pipefail

# Version information
VERSION="1.0.0"
SCRIPT_NAME="re-arch"

#=============================================================================
# CONFIGURATION SECTION - Modify these variables as needed
#=============================================================================

# Target disk (WARNING: This disk will be completely wiped!)
TARGET_DISK="${TARGET_DISK:-/dev/sda}"

# Size for the new OS partition
NEW_PART_SIZE="${NEW_PART_SIZE:-30G}"

# Desktop Environment Choice
DE_CHOICE="${DE_CHOICE:-kde}"  # Options: kde, gnome, xfce

# System Configuration
TARGET_HOSTNAME="${TARGET_HOSTNAME:-atomic-arch}"
USERNAME="${USERNAME:-user}"
LOCALE="${LOCALE:-en_US.UTF-8}"
TIMEZONE="${TIMEZONE:-UTC}"
KEYMAP="${KEYMAP:-us}"

# EFI partition size
EFI_SIZE="${EFI_SIZE:-512M}"

# Testing mode (set to true to enable dry-run mode)
TEST_MODE="${TEST_MODE:-false}"

# Verbose mode
VERBOSE="${VERBOSE:-false}"

#=============================================================================
# UTILITY FUNCTIONS
#=============================================================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

debug() {
    [[ "$VERBOSE" == "true" ]] && log "DEBUG: $*"
}

error() {
    log "ERROR: $*"
    exit 1
}

warn() {
    log "WARNING: $*"
}

info() {
    log "INFO: $*"
}

# Enhanced confirm function with test mode support
confirm() {
    local prompt="$1"
    local response
    
    if [[ "$TEST_MODE" == "true" ]]; then
        log "TEST MODE: Would prompt: $prompt"
        return 0
    fi
    
    echo
    read -r -p "$prompt [y/N]: " response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Command execution wrapper for testing
execute_command() {
    local cmd="$1"
    local description="${2:-}"
    
    debug "Executing: $cmd"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        log "TEST MODE: Would execute: $cmd"
        [[ -n "$description" ]] && log "TEST MODE: Description: $description"
        return 0
    fi
    
    eval "$cmd"
}

# Validation functions
validate_disk() {
    local disk="$1"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        # In test mode, just check if file exists
        if [[ ! -f "$disk" ]]; then
            error "Test disk file $disk does not exist"
        fi
    else
        # In real mode, check for block device
        if [[ ! -b "$disk" ]]; then
            error "Disk $disk does not exist or is not a block device"
        fi
        
        if [[ ! -w "$disk" ]]; then
            error "No write permission for disk $disk"
        fi
        
        # Check if disk is mounted
        if mount | grep -q "^$disk"; then
            warn "Disk $disk has mounted partitions"
        fi
    fi
}

validate_config() {
    info "Validating configuration..."
    
    # Validate DE choice
    case "$DE_CHOICE" in
        kde|gnome|xfce) ;;
        *) error "Invalid desktop environment: $DE_CHOICE" ;;
    esac
    
    # Validate hostname
    if [[ ! "$TARGET_HOSTNAME" =~ ^[a-zA-Z0-9-]+$ ]]; then
        error "Invalid hostname: $TARGET_HOSTNAME"
    fi
    
    # Validate username
    if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        error "Invalid username: $USERNAME"
    fi
    
    # Validate timezone
    if [[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
        error "Invalid timezone: $TIMEZONE"
    fi
    
    validate_disk "$TARGET_DISK"
    
    info "Configuration validation passed"
}

get_de_packages() {
    case "$DE_CHOICE" in
        kde)
            echo "plasma-meta sddm"
            ;;
        gnome)
            echo "gnome gdm"
            ;;
        xfce)
            echo "xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
            ;;
        *)
            error "Unknown desktop environment: $DE_CHOICE"
            ;;
    esac
}

#=============================================================================
# MAIN FUNCTIONS
#=============================================================================

prepare_disk() {
    info "Preparing disk $TARGET_DISK"
    
    # Safety check
    if ! confirm "WARNING: This will completely wipe $TARGET_DISK and all its data. Continue?"; then
        error "Operation cancelled by user"
    fi
    
    # Unmount any mounted partitions
    execute_command "umount ${TARGET_DISK}* 2>/dev/null || true" "Unmount existing partitions"
    
    # Wipe partition table
    execute_command "wipefs -af $TARGET_DISK" "Wipe partition table"
    
    # Create new partition table
    execute_command "parted -s $TARGET_DISK mklabel gpt" "Create GPT partition table"
    
    # Create EFI partition
    execute_command "parted -s $TARGET_DISK mkpart ESP fat32 1MiB $EFI_SIZE" "Create EFI partition"
    execute_command "parted -s $TARGET_DISK set 1 esp on" "Set EFI partition flag"
    
    # Create Btrfs partition
    execute_command "parted -s $TARGET_DISK mkpart primary btrfs $EFI_SIZE $NEW_PART_SIZE" "Create Btrfs partition"
    
    # Wait for kernel to recognize new partitions
    execute_command "sleep 2 && partprobe $TARGET_DISK && sleep 2" "Refresh partition table"
    
    info "Disk preparation completed"
}

setup_btrfs() {
    local efi_part="${TARGET_DISK}1"
    local btrfs_part="${TARGET_DISK}2"
    
    info "Setting up Btrfs filesystem"
    
    # Safety confirmation for formatting
    if ! confirm "This will format $btrfs_part with Btrfs. Continue?"; then
        error "Operation cancelled by user"
    fi
    
    # Format EFI partition
    execute_command "mkfs.fat -F32 -n EFI $efi_part" "Format EFI partition"
    
    # Format Btrfs partition
    execute_command "mkfs.btrfs -f -L ATOMIC_ROOT $btrfs_part" "Format Btrfs partition"
    
    # Mount Btrfs partition
    execute_command "mount $btrfs_part /mnt" "Mount Btrfs partition"
    
    # Create subvolumes
    local subvolumes=("@" "@home" "@log" "@snapshots")
    for subvol in "${subvolumes[@]}"; do
        execute_command "btrfs subvolume create /mnt/$subvol" "Create subvolume $subvol"
    done
    
    # Unmount and remount with proper subvolume layout
    execute_command "umount /mnt" "Unmount for remounting"
    
    # Mount root subvolume
    execute_command "mount -o subvol=@,compress=zstd,noatime $btrfs_part /mnt" "Mount root subvolume"
    
    # Create mount points
    execute_command "mkdir -p /mnt/{boot,home,var/log,.snapshots}" "Create mount points"
    
    # Mount other subvolumes
    execute_command "mount -o subvol=@home,compress=zstd,noatime $btrfs_part /mnt/home" "Mount home subvolume"
    execute_command "mount -o subvol=@log,compress=zstd,noatime $btrfs_part /mnt/var/log" "Mount log subvolume"
    execute_command "mount -o subvol=@snapshots,compress=zstd,noatime $btrfs_part /mnt/.snapshots" "Mount snapshots subvolume"
    
    # Mount EFI partition
    execute_command "mount $efi_part /mnt/boot" "Mount EFI partition"
    
    info "Btrfs setup completed"
}

install_base() {
    info "Installing base system"
    
    # Base packages
    local base_packages="base linux linux-firmware btrfs-progs networkmanager sudo nano"
    
    # Desktop environment packages
    local de_packages
    de_packages=$(get_de_packages)
    
    # Install packages
    execute_command "pacstrap /mnt $base_packages $de_packages" "Install base system and DE packages"
    
    # Generate fstab
    execute_command "genfstab -U /mnt >> /mnt/etc/fstab" "Generate fstab"
    
    # Modify fstab to mount root as read-only
    execute_command "sed -i 's/subvol=@[[:space:]]*btrfs[[:space:]]*rw/subvol=@ btrfs ro/' /mnt/etc/fstab" "Set root as read-only in fstab"
    
    info "Base system installation completed"
}

configure_system() {
    info "Configuring system"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        # In test mode, just simulate the configuration
        debug "TEST MODE: Would create and run system configuration script"
        debug "TEST MODE: Would set timezone to $TIMEZONE"
        debug "TEST MODE: Would set locale to $LOCALE"
        debug "TEST MODE: Would set hostname to $TARGET_HOSTNAME"
        debug "TEST MODE: Would create user $USERNAME"
        debug "TEST MODE: Would enable NetworkManager and display manager"
        return 0
    fi
    
    # Create configuration script for chroot
    cat > /mnt/configure.sh << EOF
#!/bin/bash
set -euo pipefail

# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Set locale
echo "$LOCALE UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Set keymap
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Set hostname
echo "$TARGET_HOSTNAME" > /etc/hostname

# Configure hosts
cat > /etc/hosts << HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $TARGET_HOSTNAME.localdomain $TARGET_HOSTNAME
HOSTS_EOF

# Enable NetworkManager
systemctl enable NetworkManager

# Enable display manager
case "$DE_CHOICE" in
    kde)
        systemctl enable sddm
        ;;
    gnome)
        systemctl enable gdm
        ;;
    xfce)
        systemctl enable lightdm
        ;;
esac

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Configure mkinitcpio for Btrfs
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

EOF

    # Make script executable and run it
    execute_command "chmod +x /mnt/configure.sh" "Make configuration script executable"
    execute_command "arch-chroot /mnt /configure.sh" "Run system configuration"
    
    # Set passwords (interactive in non-test mode)
    if [[ "$TEST_MODE" != "true" ]]; then
        echo "Set root password:"
        arch-chroot /mnt passwd
        
        echo "Set user password for $USERNAME:"
        arch-chroot /mnt passwd "$USERNAME"
    fi
    
    # Clean up
    execute_command "rm /mnt/configure.sh" "Clean up configuration script"
    
    info "System configuration completed"
}

setup_bootloader() {
    info "Setting up systemd-boot"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        debug "TEST MODE: Would install systemd-boot"
        debug "TEST MODE: Would create bootloader configuration"
        debug "TEST MODE: Would create boot entry for atomic system"
        return 0
    fi
    
    # Install systemd-boot
    execute_command "arch-chroot /mnt bootctl install" "Install systemd-boot"
    
    # Create loader configuration
    cat > /mnt/boot/loader/loader.conf << 'EOF'
default arch.conf
timeout 3
console-mode max
editor no
EOF

    # Get PARTUUID
    local btrfs_part="${TARGET_DISK}2"
    local partuuid
    
    if [[ "$TEST_MODE" == "true" ]]; then
        partuuid="test-partuuid"
    else
        partuuid=$(blkid -s PARTUUID -o value "$btrfs_part")
    fi
    
    # Create boot entry
    cat > /mnt/boot/loader/entries/arch.conf << EOF
title   Atomic Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$partuuid rootflags=subvol=@,ro rw quiet
EOF

    info "Bootloader setup completed"
}

deploy_update_script() {
    info "Deploying atomic update script"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        debug "TEST MODE: Would deploy atomic-update script to /usr/local/bin/"
        debug "TEST MODE: Would deploy atomic-rollback script to /usr/local/bin/"
        debug "TEST MODE: Scripts would enable snapshot-based updates"
        return 0
    fi
    
    cat > /mnt/usr/local/bin/atomic-update << 'EOF'
#!/bin/bash

# Atomic Update Script
# Performs snapshot-based system updates

set -euo pipefail

VERSION="1.0.0"
SCRIPT_NAME="atomic-update"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

info() {
    log "INFO: $*"
}

show_atomic_update_usage() {
    cat << 'USAGE_EOF'
Usage: atomic-update [OPTIONS]

Options:
    -h, --help     Show this help message
    -v, --version  Show version information
    --dry-run      Show what would be done without executing
    --verbose      Enable verbose output

USAGE_EOF
}

# Parse command line arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_atomic_update_usage
            exit 0
            ;;
        -v|--version)
            echo "$SCRIPT_NAME $VERSION"
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root"
fi

# Get current subvolume
CURRENT_SUBVOL=$(btrfs subvolume show / | grep -E "^\s*Name:" | awk '{print $2}')
info "Current subvolume: $CURRENT_SUBVOL"

# Create snapshot name with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NEW_SUBVOL="@_update_$TIMESTAMP"

info "Creating snapshot: $NEW_SUBVOL"

if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY RUN: Would create snapshot $NEW_SUBVOL and update system"
    exit 0
fi

# Mount Btrfs root
mkdir -p /mnt/btrfs-root
mount /dev/disk/by-label/ATOMIC_ROOT /mnt/btrfs-root

# Create snapshot
btrfs subvolume snapshot /mnt/btrfs-root/@ /mnt/btrfs-root/"$NEW_SUBVOL"

# Mount new snapshot as read-write
mkdir -p /mnt/update-root
mount -o subvol="$NEW_SUBVOL",rw /dev/disk/by-label/ATOMIC_ROOT /mnt/update-root

# Bind mount necessary filesystems
mount --bind /proc /mnt/update-root/proc
mount --bind /sys /mnt/update-root/sys
mount --bind /dev /mnt/update-root/dev
mount --bind /run /mnt/update-root/run

# Update the system
info "Updating system packages"
chroot /mnt/update-root pacman -Syu --noconfirm

# Update bootloader entry
info "Updating bootloader configuration"
BOOT_ENTRY="/mnt/update-root/boot/loader/entries/arch.conf"
if [[ -f "$BOOT_ENTRY" ]]; then
    sed -i "s/rootflags=subvol=[^,]*/rootflags=subvol=$NEW_SUBVOL/" "$BOOT_ENTRY"
fi

# Clean up mounts
umount /mnt/update-root/proc
umount /mnt/update-root/sys
umount /mnt/update-root/dev
umount /mnt/update-root/run
umount /mnt/update-root
rmdir /mnt/update-root

# Set new subvolume as default
SUBVOL_ID=$(btrfs subvolume show /mnt/btrfs-root/"$NEW_SUBVOL" | grep -E "^\s*Subvolume ID:" | awk '{print $3}')
btrfs subvolume set-default "$SUBVOL_ID" /mnt/btrfs-root

info "Update complete. New subvolume: $NEW_SUBVOL"
info "Reboot to use the updated system"

# Clean up
umount /mnt/btrfs-root
rmdir /mnt/btrfs-root

info "Atomic update completed successfully"
EOF

    # Make script executable
    execute_command "chmod +x /mnt/usr/local/bin/atomic-update" "Make atomic-update executable"
    
    # Create rollback script
    cat > /mnt/usr/local/bin/atomic-rollback << 'EOF'
#!/bin/bash

# Atomic Rollback Script
# Rolls back to previous snapshot

set -euo pipefail

VERSION="1.0.0"
SCRIPT_NAME="atomic-rollback"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

info() {
    log "INFO: $*"
}

show_atomic_rollback_usage() {
    cat << 'USAGE_EOF'
Usage: atomic-rollback [OPTIONS] [SNAPSHOT_NAME]

Options:
    -h, --help     Show this help message
    -v, --version  Show version information
    -l, --list     List available snapshots
    --dry-run      Show what would be done without executing

USAGE_EOF
}

# Parse command line arguments
DRY_RUN=false
LIST_ONLY=false
ROLLBACK_SUBVOL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_atomic_rollback_usage
            exit 0
            ;;
        -v|--version)
            echo "$SCRIPT_NAME $VERSION"
            exit 0
            ;;
        -l|--list)
            LIST_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            ROLLBACK_SUBVOL="$1"
            shift
            ;;
    esac
done

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root"
fi

# Mount Btrfs root
mkdir -p /mnt/btrfs-root
mount /dev/disk/by-label/ATOMIC_ROOT /mnt/btrfs-root

# List available snapshots
info "Available snapshots:"
btrfs subvolume list /mnt/btrfs-root | grep -E "@(_update_|$)" | awk '{print $9}'

if [[ "$LIST_ONLY" == "true" ]]; then
    umount /mnt/btrfs-root
    rmdir /mnt/btrfs-root
    exit 0
fi

# Get rollback target if not provided
if [[ -z "$ROLLBACK_SUBVOL" ]]; then
    echo
    read -p "Enter snapshot name to rollback to (or 'cancel'): " ROLLBACK_SUBVOL
fi

if [[ "$ROLLBACK_SUBVOL" == "cancel" ]]; then
    info "Rollback cancelled"
    exit 0
fi

# Verify snapshot exists
if ! btrfs subvolume show /mnt/btrfs-root/"$ROLLBACK_SUBVOL" &>/dev/null; then
    error "Snapshot '$ROLLBACK_SUBVOL' does not exist"
fi

if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY RUN: Would rollback to $ROLLBACK_SUBVOL"
    exit 0
fi

# Set as default
SUBVOL_ID=$(btrfs subvolume show /mnt/btrfs-root/"$ROLLBACK_SUBVOL" | grep -E "^\s*Subvolume ID:" | awk '{print $3}')
btrfs subvolume set-default "$SUBVOL_ID" /mnt/btrfs-root

info "Rollback to $ROLLBACK_SUBVOL complete"
info "Reboot to use the rolled-back system"

# Clean up
umount /mnt/btrfs-root
rmdir /mnt/btrfs-root
EOF

    execute_command "chmod +x /mnt/usr/local/bin/atomic-rollback" "Make atomic-rollback executable"
    
    info "Atomic update scripts deployed"
}

cleanup() {
    info "Cleaning up"
    execute_command "umount -R /mnt 2>/dev/null || true" "Unmount all mount points"
}

show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
    -h, --help              Show this help message
    -v, --version           Show version information
    -c, --config FILE       Use custom configuration file
    -t, --test              Run in test mode (dry-run)
    -V, --verbose           Enable verbose output
    --target-disk DISK      Target disk (default: /dev/sda)
    --de DESKTOP            Desktop environment (kde|gnome|xfce)
    --hostname NAME         System hostname
    --username NAME         User name
    --timezone TZ           Timezone (default: UTC)

Environment Variables:
    TARGET_DISK            Target disk device
    DE_CHOICE              Desktop environment choice
    TARGET_HOSTNAME        System hostname
    USERNAME               User name
    TIMEZONE               System timezone
    TEST_MODE              Enable test mode (true/false)
    VERBOSE                Enable verbose output (true/false)

Examples:
    $SCRIPT_NAME --target-disk /dev/sdb --de gnome
    $SCRIPT_NAME --test --verbose
    TARGET_DISK=/dev/nvme0n1 $SCRIPT_NAME --de xfce

EOF
}

show_version() {
    echo "$SCRIPT_NAME $VERSION"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -t|--test)
                TEST_MODE="true"
                shift
                ;;
            -V|--verbose)
                VERBOSE="true"
                shift
                ;;
            --target-disk)
                TARGET_DISK="$2"
                shift 2
                ;;
            --de)
                DE_CHOICE="$2"
                shift 2
                ;;
            --hostname)
                TARGET_HOSTNAME="$2"
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
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    info "Starting Re-Arch Procedure v$VERSION"
    info "Target disk: $TARGET_DISK"
    info "Desktop Environment: $DE_CHOICE"
    info "Hostname: $TARGET_HOSTNAME"
    info "Username: $USERNAME"
    info "Test mode: $TEST_MODE"
    
    # Load configuration file if specified
    if [[ -n "${CONFIG_FILE:-}" ]]; then
        if [[ -f "$CONFIG_FILE" ]]; then
            # shellcheck source=/dev/null
            source "$CONFIG_FILE"
            info "Loaded configuration from $CONFIG_FILE"
        else
            error "Configuration file not found: $CONFIG_FILE"
        fi
    fi
    
    # Trap cleanup on exit
    trap cleanup EXIT
    
    # Verify we're running as root (skip in test mode)
    if [[ $EUID -ne 0 && "$TEST_MODE" != "true" ]]; then
        error "This script must be run as root"
    fi
    
    # Validate configuration
    validate_config
    
    # Show configuration summary
    echo
    echo "=== RE-ARCH PROCEDURE CONFIGURATION ==="
    echo "Target disk: $TARGET_DISK"
    echo "Partition size: $NEW_PART_SIZE"
    echo "Desktop Environment: $DE_CHOICE"
    echo "Hostname: $TARGET_HOSTNAME"
    echo "Username: $USERNAME"
    echo "Timezone: $TIMEZONE"
    echo "Locale: $LOCALE"
    echo "Test mode: $TEST_MODE"
    echo
    
    # Final confirmation
    if ! confirm "Are you ready to proceed with the Re-Arch procedure?"; then
        error "Operation cancelled by user"
    fi
    
    # Execute procedure
    prepare_disk
    setup_btrfs
    install_base
    configure_system
    setup_bootloader
    deploy_update_script
    
    info "Re-Arch procedure completed successfully!"
    info "You can now reboot into your new atomic Arch Linux system"
    info "Use 'sudo atomic-update' to update the system"
    info "Use 'sudo atomic-rollback' to rollback if needed"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: All operations were simulated"
    fi
}

#=============================================================================
# MAIN EXECUTION
#=============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi