#!/bin/bash
#
# Re-Arch Single Command Installer
# Professional, opinionated Arch Linux installer
# https://re-arch.xyz
#

set -euo pipefail

# Debug mode - uncomment for troubleshooting
# set -x

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    echo "Script failed at line $BASH_LINENO. Check the error above." >&2
    exit 1
}

# Validation functions
check_environment() {
    info "Validating installation environment..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo bash"
    fi
    
    # Check if archinstall is available
    if ! command -v archinstall &> /dev/null; then
        error "archinstall not found. Are you running from Arch installation media?"
    fi
    
    # Check internet connectivity
    if ! ping -c 1 archlinux.org &>/dev/null; then
        error "No internet connection. Please connect to the internet first."
    fi
    
    # Check if we're in a live environment (basic check)
    if [[ ! -f /etc/arch-release ]]; then
        error "This doesn't appear to be an Arch Linux environment."
    fi
    
    success "Environment validation passed"
}

# Main installation function
run_installation() {
    echo ""
    echo "🚀 Re-Arch Single Command Installer"
    echo "===================================="
    echo ""
    info "Professional Arch Linux desktop system installation"
    echo ""
    
    warning "This will install a complete desktop system with:"
    echo "  • KDE Plasma desktop environment"
    echo "  • Linux Zen kernel for performance" 
    echo "  • Automatic Btrfs snapshots"
    echo "  • Security and optimization packages"
    echo ""
    warning "Default credentials: user/rearch (change after first login)"
    echo ""
    
    read -p "Continue with installation? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    echo ""
    info "Step 1/2: Installing base system with archinstall..."
    echo "This may take 10-20 minutes depending on your internet connection."
    echo ""
    
    # Run archinstall with our configs
    if archinstall --config-url https://re-arch.xyz/archinstall-config.json --creds-url https://re-arch.xyz/archinstall-credentials.json; then
        success "Base system installation completed"
    else
        error "archinstall failed. Check the output above for details."
    fi
    
    echo ""
    info "Step 2/2: Optimizing system configuration..."
    echo "Configuring snapshots, services, and final optimizations..."
    echo ""
    
    # Check if /mnt exists and is mounted
    if ! mountpoint -q /mnt; then
        error "Installation target /mnt is not mounted. archinstall may have failed."
    fi
    
    # Run optimization script in chroot
    if arch-chroot /mnt bash -c "curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash"; then
        success "System optimization completed"
    else
        warning "Optimization script failed, but base system is installed"
        warning "You can manually run the optimization after reboot:"
        warning "curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash"
    fi
    
    echo ""
    echo "🎉 Installation Complete!"
    echo "========================"
    echo ""
    success "Your optimized Arch Linux desktop is ready!"
    echo ""
    info "Next steps:"
    echo "  1. Remove the installation USB/CD"
    echo "  2. Reboot your system"
    echo "  3. Login with: user / rearch"
    echo "  4. Change your password: passwd"
    echo "  5. Enjoy your new system!"
    echo ""
    
    read -p "Reboot now? [y/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Rebooting in 3 seconds..."
        sleep 3
        reboot
    else
        echo "Remember to reboot when ready!"
    fi
}

# Main execution
main() {
    check_environment
    run_installation
}

# Always run main function when script is executed
main "$@"