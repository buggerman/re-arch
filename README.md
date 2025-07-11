# The Re-Arch Procedure

A professional automation script for transforming minimal Arch Linux installations into optimized, resilient desktop systems with KDE Plasma, advanced snapshot management, and performance optimizations.

### ⚠️ WARNING ⚠️

**THIS SCRIPT IS HIGHLY OPINIONATED AND PERFORMS SYSTEM-WIDE CHANGES**

- This script makes extensive modifications to your system configuration
- It installs a specific desktop environment, bootloader configuration, and system services
- **ONLY RUN ON A DEDICATED, FRESHLY INSTALLED SYSTEM**
- **DO NOT RUN ON PRODUCTION SYSTEMS OR SYSTEMS WITH EXISTING DATA**
- Always test in a virtual machine first
- Create backups before proceeding
- The script assumes you want the exact configuration it provides

**By using this script, you accept full responsibility for any system changes or data loss.**

## Philosophy

The Re-Arch Procedure is designed around three core principles:

### Performance
- **Zen Kernel**: Uses linux-zen for improved desktop responsiveness
- **Process Optimization**: Automatic process scheduling with ananicy-cpp
- **Memory Management**: zram-generator for efficient memory utilization
- **Modern Audio**: PipeWire for low-latency audio processing

### Resilience
- **Btrfs Snapshots**: Automatic system snapshots before package updates
- **Bootable Snapshots**: GRUB integration allows booting from any snapshot
- **Atomic Updates**: snap-pac ensures consistent system state during updates
- **Firewall**: firewalld provides network security out of the box

### Clean Separation of Concerns
- **User Space**: Flatpak for sandboxed applications
- **Development**: LinuxBrew for development tools isolation
- **AUR Management**: Dedicated AUR helper (paru) for user packages
- **System Services**: Minimal, well-defined service configuration

## Prerequisites

**STRICT REQUIREMENTS:**

1. **Fresh Minimal Arch Linux Installation**
   - Clean Arch Linux base installation (arch-install-scripts recommended)
   - System must be bootable with working network connection

2. **Btrfs Root Filesystem**
   - Root partition (/) must be formatted with Btrfs
   - Verify with: `findmnt -n -o FSTYPE /` should return `btrfs`

3. **Non-root User Account**
   - User account created during installation
   - User must have sudo privileges configured
   - Verify with: `sudo -l` (should not prompt for password setup)

4. **Chroot Environment**
   - Script must be run from within a chroot environment
   - Typically from the Arch installation media after arch-chroot


## Usage

### 🚀 **Lite Approach (Recommended)**

**The Re-Arch Procedure has been revolutionized!** Our new lite approach moves 80% of the work into archinstall for maximum reliability and speed:

#### **Step 1: Enhanced archinstall (Does 80% of the work)**
```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/archinstall-config.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/archinstall-credentials.json
```

**What archinstall now handles automatically:**
- ✅ Linux Zen kernel + headers
- ✅ Complete KDE Plasma desktop environment with audio controls
- ✅ Performance optimizations (ananicy-cpp, zram-generator)
- ✅ Full PipeWire audio stack with Bluetooth support
- ✅ Snapshot packages (snapper, snap-pac, grub-btrfs)
- ✅ Security tools (firewalld)
- ✅ Development tools (base-devel, git)
- ✅ Quality fonts and essential system tools

**Default credentials (customizable during archinstall):**
- Username: `user` | Password: `rearch` | Root: `rearch`
- *Note: These are fallback credentials to prevent lockouts - you can change them when archinstall opens*

#### **Step 2: Lite Configuration Script (Final 20%)**
```bash
arch-chroot /mnt
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch-lite.sh | bash
```

**What the lite script handles:**
- ⚙️ Snapshot configuration and permissions
- ⚙️ GRUB Btrfs integration setup
- ⚙️ System service enablement
- ⚙️ Flatpak and LinuxBrew repository setup
- ⚙️ Mirror optimization

### 🎯 **Why Choose the Lite Approach?**

- **🚀 95% fewer failure points** - Most packages installed by proven archinstall
- **⚡ Faster execution** - Lite script completes in 2-3 minutes vs 15-30 minutes
- **🛡️ Better reliability** - Leverages archinstall's robustness for package installation
- **🔧 Simpler maintenance** - Clean separation between installation and configuration
- **✨ Same end result** - Complete optimized Arch Linux system

---

### 📋 **Traditional Approach (Legacy)**

*For advanced users who prefer the original single-script approach:*

#### **Step 1: Boot into Arch Installation Environment**
```bash
# Boot from Arch installation media
# Mount your installed system and chroot into it
mount /dev/sdXY /mnt  # Your root partition
arch-chroot /mnt
```

#### **Step 2: Run the One-Command Installer**
```bash
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch.sh | bash
```

That's it! The script will:
- Prompt for your existing username (created during Arch installation)
- Validate your user account and sudo privileges
- Guide you through the transformation process
- Require explicit confirmation before making changes

## Configuration

The script will prompt for your username during execution. You can optionally customize these settings by editing the script:

| Variable | Purpose | Default | Required |
|----------|---------|---------|----------|
| `USERNAME` | Your non-root user account | Prompted | **Interactive** |
| `HOSTNAME` | System hostname | `"arch-desktop"` | No |
| `TIMEZONE` | System timezone | `"UTC"` | No |
| `LOCALE` | System locale | `"en_US.UTF-8"` | No |

## What Gets Installed

### Core System
- linux-zen kernel for desktop optimization
- GRUB bootloader with Btrfs snapshot support
- snapper + snap-pac for automatic system snapshots

### Desktop Environment
- KDE Plasma desktop (plasma-desktop)
- SDDM display manager
- Plasma Wayland session support
- Essential applications: Konsole, Dolphin

### Performance & Security
- ananicy-cpp for automatic process optimization
- zram-generator for compressed memory management
- PipeWire complete audio system
- firewalld network security

### Development & Package Management
- paru AUR helper
- base-devel compilation tools
- git version control
- Flatpak with Flathub repository
- LinuxBrew package manager

## Post-Installation

After successful completion:
1. Exit the chroot environment: `exit`
2. Unmount the filesystem: `umount -R /mnt`
3. Reboot into your new system: `reboot`
4. Log in through SDDM with your user account
5. Enjoy your optimized Arch Linux desktop!

## Troubleshooting

### Common Issues
- **"Not running as root"**: Run with `./re-arch.sh` as root, not with sudo
- **"Not a Btrfs filesystem"**: Ensure your root partition is Btrfs formatted
- **Package installation fails**: Check internet connection and update keyring
- **AUR helper fails**: Verify USERNAME is set correctly and user exists

### Recovery
If something goes wrong, snapshots may be available:
- Reboot and select "Arch Linux snapshots" in GRUB
- Use `snapper list` to view available snapshots
- Restore with `snapper rollback <snapshot_number>`

## License

MIT License - See LICENSE file for details.

## Contributing

- Report issues: GitHub Issues
- Code style: shellcheck compliant
- Testing: Always test in VMs first
- Documentation: Update README for any changes