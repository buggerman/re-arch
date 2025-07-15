#!/bin/bash

# Config validation script for Re-Arch configurations
# Validates JSON structure, package consistency, and required components

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Counters
errors=0
warnings=0

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    ((errors++))
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
    ((warnings++))
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

validate_json_syntax() {
    local file="$1"
    
    if ! jq . "$file" >/dev/null 2>&1; then
        error "Invalid JSON syntax in $file"
        return 1
    fi
    
    success "Valid JSON syntax: $file"
    return 0
}

validate_required_fields() {
    local file="$1"
    
    local required_fields=(
        ".bootloader"
        ".kernels"
        ".packages"
        ".disk_config"
        ".locale_config"
        ".network_config"
    )
    
    for field in "${required_fields[@]}"; do
        if ! jq -e "$field" "$file" >/dev/null 2>&1; then
            error "Missing required field '$field' in $file"
        fi
    done
}

validate_desktop_packages() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    
    case "$basename" in
        "config-kde.json")
            # Check for KDE packages
            if ! jq -e '.packages[] | select(. == "plasma-desktop")' "$file" >/dev/null; then
                error "KDE config missing 'plasma-desktop' package"
            fi
            if ! jq -e '.packages[] | select(. == "sddm")' "$file" >/dev/null; then
                error "KDE config missing 'sddm' display manager"
            fi
            if ! jq -e '.packages[] | select(. == "discover")' "$file" >/dev/null; then
                warning "KDE config missing 'discover' package manager"
            fi
            ;;
        "config-gnome.json")
            # Check for GNOME packages
            if ! jq -e '.packages[] | select(. == "gnome-shell")' "$file" >/dev/null; then
                error "GNOME config missing 'gnome-shell' package"
            fi
            if ! jq -e '.packages[] | select(. == "gdm")' "$file" >/dev/null; then
                error "GNOME config missing 'gdm' display manager"
            fi
            if ! jq -e '.packages[] | select(. == "gnome-software")' "$file" >/dev/null; then
                warning "GNOME config missing 'gnome-software' package manager"
            fi
            ;;
        "config-xfce.json")
            # Check for XFCE packages
            if ! jq -e '.packages[] | select(. == "xfce4")' "$file" >/dev/null; then
                error "XFCE config missing 'xfce4' package"
            fi
            if ! jq -e '.packages[] | select(. == "lightdm")' "$file" >/dev/null; then
                error "XFCE config missing 'lightdm' display manager"
            fi
            if ! jq -e '.packages[] | select(. == "gnome-software")' "$file" >/dev/null; then
                warning "XFCE config missing 'gnome-software' package manager"
            fi
            ;;
        "config-hyprland.json")
            # Check for Hyprland packages
            if ! jq -e '.packages[] | select(. == "hyprland")' "$file" >/dev/null; then
                error "Hyprland config missing 'hyprland' package"
            fi
            if ! jq -e '.packages[] | select(. == "lightdm")' "$file" >/dev/null; then
                error "Hyprland config missing 'lightdm' display manager"
            fi
            if ! jq -e '.packages[] | select(. == "gnome-software")' "$file" >/dev/null; then
                warning "Hyprland config missing 'gnome-software' package manager"
            fi
            ;;
    esac
}

validate_essential_packages() {
    local file="$1"
    
    local essential_packages=(
        "git"
        "curl"
        "wget"
        "base-devel"
        "sudo"
        "linux-zen-headers"
        "firewalld"
        "snapper"
        "snap-pac"
        "grub-btrfs"
        "ananicy-cpp"
        "pipewire"
        "flatpak"
    )
    
    for package in "${essential_packages[@]}"; do
        if ! jq -e ".packages[] | select(. == \"$package\")" "$file" >/dev/null; then
            error "Missing essential package '$package' in $file"
        fi
    done
}

validate_disk_config() {
    local file="$1"
    
    # Check if disk config exists and has device
    if ! jq -e '.disk_config.device_modifications[0].device' "$file" >/dev/null; then
        error "Missing disk device specification in $file"
        return 1
    fi
    
    local device
    device=$(jq -r '.disk_config.device_modifications[0].device' "$file")
    
    if [[ "$device" == "/dev/sda" ]]; then
        info "Using default disk device: $device"
    else
        warning "Non-default disk device: $device (ensure this matches your target system)"
    fi
    
    # Check for Btrfs filesystem
    if ! jq -e '.disk_config.device_modifications[0].partitions[] | select(.fs_type == "btrfs")' "$file" >/dev/null; then
        error "No Btrfs partition found in $file (required for snapshots)"
    fi
    
    # Check for required Btrfs subvolumes
    local required_subvolumes=("@" "@home" "@log" "@pkg")
    for subvol in "${required_subvolumes[@]}"; do
        if ! jq -e ".disk_config.device_modifications[0].partitions[] | select(.fs_type == \"btrfs\") | .btrfs[] | select(.name == \"$subvol\")" "$file" >/dev/null; then
            error "Missing required Btrfs subvolume '$subvol' in $file"
        fi
    done
}

validate_config_file() {
    local file="$1"
    
    echo
    echo "=== Validating $file ==="
    
    if [[ ! -f "$file" ]]; then
        error "Config file not found: $file"
        return 1
    fi
    
    # Validate JSON syntax
    if ! validate_json_syntax "$file"; then
        return 1
    fi
    
    # Validate required fields
    validate_required_fields "$file"
    
    # Validate desktop-specific packages
    validate_desktop_packages "$file"
    
    # Validate essential packages
    validate_essential_packages "$file"
    
    # Validate disk configuration
    validate_disk_config "$file"
    
    echo
}

main() {
    echo "Re-Arch Configuration Validator"
    echo "==============================="
    
    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        error "jq is required but not installed. Please install jq first."
        exit 1
    fi
    
    # If specific file provided, validate it
    if [[ $# -gt 0 ]]; then
        for file in "$@"; do
            validate_config_file "$file"
        done
    else
        # Validate all config files
        for file in config*.json; do
            if [[ -f "$file" ]]; then
                validate_config_file "$file"
            fi
        done
    fi
    
    echo
    echo "=== VALIDATION SUMMARY ==="
    echo "Errors: $errors"
    echo "Warnings: $warnings"
    
    if [[ $errors -eq 0 ]]; then
        success "All configurations passed validation!"
        exit 0
    else
        error "Validation failed with $errors errors"
        exit 1
    fi
}

main "$@"