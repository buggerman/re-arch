# The Re-Arch Procedure

A professional, opinionated Arch Linux installer that creates optimized desktop systems with KDE Plasma, advanced snapshot management, and performance optimizations from the ground up.

### ⚠️ IMPORTANT ⚠️

**THIS IS AN OPINIONATED ARCH LINUX INSTALLER WITH SPECIFIC CONFIGURATION CHOICES**

- Creates a complete desktop system with KDE Plasma, performance optimizations, and security features
- Designed for fresh installations on dedicated hardware or virtual machines
- **NOT intended for existing systems with data or custom configurations**
- **ALWAYS test in a virtual machine before installing on real hardware**
- Makes specific choices about desktop environment, kernel, and system services
- Best suited for users who want a curated, production-ready Arch Linux setup

**By using this installer, you accept the provided configuration and any system changes.**

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

**REQUIREMENTS:**

1. **Arch Linux Installation Media**
   - Download latest Arch Linux ISO
   - Boot from USB/CD in target system
   - Network connection available

2. **Target System**
   - Compatible x86_64 hardware
   - Minimum 4GB RAM recommended
   - 20GB+ available disk space
   - UEFI or BIOS boot support

**For lite approach:** No additional setup required - archinstall handles everything
**For traditional approach:** Requires manual Arch base installation with Btrfs root filesystem


## Installation

### 🚀 **Main Installation Method**

**Complete Arch Linux system installation in 2 simple steps:**

#### **Step 1: Automated Installation**
```bash
archinstall --config-url https://re-arch.xyz/archinstall-config.json --creds-url https://re-arch.xyz/archinstall-credentials.json
```

<details>
<summary>Alternative URLs (if domain is not working)</summary>

```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/archinstall-config.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/archinstall-credentials.json
```
</details>

**What gets installed automatically:**
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

#### **Step 2: System Optimization**
```bash
# If you used archinstall's chroot option, just run:
curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash

# If you need to chroot manually:
arch-chroot /mnt
curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash
```

<details>
<summary>Alternative URLs (if domain is not working)</summary>

```bash
# If you used archinstall's chroot option, just run:
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch-lite.sh | bash

# If you need to chroot manually:
arch-chroot /mnt
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch-lite.sh | bash
```
</details>

**What the optimization script configures:**
- ⚙️ Snapshot configuration and permissions
- ⚙️ GRUB Btrfs integration setup
- ⚙️ System service enablement
- ⚙️ Flatpak and LinuxBrew repository setup
- ⚙️ Mirror optimization

### 🎯 **Why This Method?**

- **🚀 95% fewer failure points** - Leverages proven archinstall for package installation
- **⚡ Faster execution** - Complete system ready in under 10 minutes
- **🛡️ Better reliability** - Robust installation process with minimal manual steps
- **🔧 Simpler maintenance** - Clean separation between installation and configuration
- **✨ Production ready** - Complete, optimized Arch Linux desktop system

---

### ⚗️ **Experimental: Legacy Conversion Method**

**WARNING: This method is failure-prone and not recommended for most users.**

*For advanced users who want to convert an existing minimal Arch installation (requires Btrfs root):*

#### **Prerequisites for Conversion**
- Existing minimal Arch Linux installation with Btrfs root filesystem
- Non-root user account with sudo privileges
- System booted from Arch installation media with chroot access

#### **Conversion Process**
```bash
# Boot from Arch installation media
# Mount your existing system and chroot into it
mount /dev/sdXY /mnt  # Your root partition
arch-chroot /mnt

# Run the conversion script
curl -fsSL https://re-arch.xyz/re-arch.sh | bash
```

<details>
<summary>Alternative URL (if domain is not working)</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch.sh | bash
```
</details>

**Known Issues with Conversion Method:**
- Higher failure rates due to package conflicts
- Complex dependency resolution
- Requires manual troubleshooting
- Not suitable for production use
- **Use the main installation method instead for reliability**

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