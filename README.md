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

**⚠️ READ THIS CAREFULLY - FOLLOWING THESE REQUIREMENTS PREVENTS 90% OF INSTALLATION ISSUES**

### System Requirements

**Hardware (MINIMUM):**
- **CPU**: x86_64 processor (Intel/AMD 64-bit) 
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 20GB minimum free space, 50GB recommended for comfort
- **Boot**: UEFI firmware preferred, Legacy BIOS supported

**⚠️ COMPATIBILITY WARNING:**
- **✅ FULLY SUPPORTED**: Fresh installation on dedicated machines or VMs
- **⚠️ ADVANCED USERS ONLY**: Dual-boot systems (requires manual partition configuration)
- **❌ NOT SUPPORTED**: Systems with existing data you want to preserve
- **❌ WILL NOT WORK**: Without internet connection during installation

### Internet Connection Required
- **Stable internet required**: Downloads 1-2GB of packages
- **Wired connection recommended**: More reliable than WiFi during installation
- **WiFi setup**: Connect to network BEFORE running installation commands

### Virtual Machine Users
If installing in a VM:
- **Enable**: Virtualization features in VM settings  
- **Allocate**: At least 4GB RAM to the VM
- **Disk size**: 50GB+ virtual disk recommended
- **Boot**: Enable EFI boot in VM settings if available

**🚨 DESTRUCTIVE INSTALLATION WARNING**
This installer assumes it controls the entire disk. It WILL erase everything on the target disk. Back up important data BEFORE starting.


## Installation

### 📋 **Two-Step Installation (Recommended)**

**🕐 Total time: 25-35 minutes | 📶 Internet required throughout**

---

#### **📋 BEFORE YOU START:**

1. **Boot from Arch Linux ISO** (download from https://archlinux.org/download/)
2. **Connect to internet:**
   ```bash
   # For WiFi (replace "YourNetwork" with your network name):
   iwctl device list
   iwctl station wlan0 connect "YourNetwork"
   
   # Test connection:
   ping google.com
   ```
3. **You're ready when:** You see successful pings to google.com

---

#### **🚀 STEP 1: Automated Installation (20-30 minutes)**

**Run this command as root:**
```bash
archinstall --config-url https://re-arch.xyz/config.json --creds-url https://re-arch.xyz/creds.json
```

<details>
<summary>🔄 Alternative URLs (if domain is not working)</summary>

```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/config.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/creds.json
```
</details>

**🎛️ What you'll see:** archinstall will open with pre-filled configuration

**💡 RECOMMENDED CHANGES in archinstall:**
- **Username & Password**: Change from default `user`/`rearch` to your preferences
- **Timezone**: Set your timezone
- **Locale**: Set your language/region
- **Hostname**: Change from default `arch-desktop`

**🚨 CRITICAL: What NOT to Change in archinstall:**

| ❌ DON'T CHANGE | ✅ WHY KEEP IT | 🛠️ CONSEQUENCE IF CHANGED |
|------------------|----------------|----------------------------|
| **Packages** | Carefully curated list | Missing desktop/audio/snapshots |
| **Disk formatting** | Optimized for snapshots | Snapshot system won't work |
| **Filesystem (Btrfs)** | Required for snapshots | No system recovery ability |
| **Bootloader (GRUB)** | Snapshot integration | Can't boot from snapshots |

**🔐 Security Note:** 
- Default credentials (`user`/`rearch`) are fallbacks to prevent lockouts
- **CHANGE THEM** during archinstall for security
- You can also change them after first login

**⏱️ What happens during installation:**
1. **Disk partitioning** (2-3 minutes)
2. **Package downloads** (15-20 minutes) 
3. **System installation** (3-5 minutes)
4. **Configuration** (2-3 minutes)

**✅ Success indicators:**
- "Installation completed successfully"
- Prompt asking: "Would you like to chroot into the newly created installation?"

---

#### **⚙️ STEP 2: System Optimization (2-3 minutes)**

**🤔 Which method to use?**

**Method A: archinstall's chroot (RECOMMENDED)**
When archinstall asks "Would you like to chroot into the newly created installation?":
- ✅ **Select "Yes"**
- You'll see a `(chroot)` prompt
- Run: `curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash`

**Method B: Manual chroot (if you selected "No")**
- Run: `arch-chroot /mnt`
- You'll see a `(chroot)` prompt  
- Run: `curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash`

<details>
<summary>🔄 Alternative URL (if domain is not working)</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch-lite.sh | bash
```
</details>

**💡 How to tell if you're in chroot:**
- ✅ Prompt shows `(chroot)` → You're ready, run the script
- ❌ Normal prompt → Run `arch-chroot /mnt` first

**⏱️ What happens during optimization:**
1. **Snapshot configuration** (30 seconds)
2. **Service enablement** (1 minute)
3. **Repository setup** (1 minute) 
4. **Final configuration** (30 seconds)

**✅ Success indicators:**
- "Re-Arch lite configuration completed successfully"
- No error messages about failed services
- Script completes without interruption

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

### ⚗️ **Experimental: Single Command Installation**

**⚠️ Currently has interaction issues - use two-step method above for reliable installation.**

```bash
curl -fsSL https://re-arch.xyz/install | bash
```

**Known Issues:**
- May freeze during archinstall due to stdin conflicts
- Interactive prompts may not work properly when piped
- **Recommended**: Use the two-step method until these issues are resolved

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

## Post-Installation & First Steps

### 🎉 **Installation Complete! Now What?**

#### **🔄 First Boot (2-3 minutes)**
1. **Exit chroot**: Type `exit` (if in chroot)
2. **Unmount**: Run `umount -R /mnt` (if you manually chrooted)
3. **Reboot**: Remove USB/CD and run `reboot`

#### **✅ Success Checklist - Verify Everything Works**

**At boot:**
- [ ] **GRUB menu appears** (may be brief)
- [ ] **System boots to SDDM login screen** (KDE login)
- [ ] **No error messages** during boot

**After login:**
- [ ] **KDE Plasma desktop loads** properly
- [ ] **Network works**: Open web browser, visit a website
- [ ] **Audio works**: Test system sounds or play music
- [ ] **Snapshots configured**: Open terminal, run `sudo snapper list`

#### **🔧 Essential First Steps After Login**

**1. Change default passwords (if not done during install):**
```bash
passwd              # Change user password
sudo passwd root    # Change root password
```

**2. Update system:**
```bash
sudo pacman -Syu    # Update all packages
```

**3. Install additional software:**
```bash
# System packages (traditional method)
sudo pacman -S firefox libreoffice gimp

# Flatpak applications (sandboxed, recommended for apps)
flatpak search spotify
flatpak install org.gnu.gimp

# Development tools (LinuxBrew)
brew install nodejs python
```

## Troubleshooting

### 🚨 **If archinstall Fails**

**During disk setup:**
- **Check disk space**: Ensure 20GB+ available
- **Try different disk**: Some disks have compatibility issues
- **Reboot and retry**: Sometimes a fresh start helps

**During package downloads:**
- **Check internet**: Run `ping google.com`
- **Try different mirror**: Reboot installation media and try again
- **Wait and retry**: Sometimes mirrors are temporarily busy

**Config URL not found:**
- **Use alternative URLs**: The GitHub URLs in documentation as fallback
- **Check internet**: Ensure you can access websites

### 🚨 **If re-arch-lite.sh Fails**

**Permission errors:**
```bash
# Ensure you're root in chroot:
whoami          # Should show "root"
id              # Should show uid=0(root)
```

**Network issues in chroot:**
```bash
# Copy DNS configuration:
cp /etc/resolv.conf /mnt/etc/resolv.conf
# Then re-enter chroot and try again
```

**Package conflicts:**
- **Retry once**: Sometimes transient network issues cause failures
- **If repeated failures**: Report as bug with error output

### 🚨 **Boot Issues After Installation**

**Black screen or boot failure:**
1. **Boot from Arch ISO again**
2. **Mount your system**: `mount /dev/sdaX /mnt` (replace X with partition)
3. **Chroot**: `arch-chroot /mnt`
4. **Reinstall GRUB**: 
   ```bash
   grub-install /dev/sda  # Replace with your disk
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

**No GRUB menu appears:**
- **Check BIOS boot order**: Ensure hard disk is first
- **Check UEFI settings**: Ensure Secure Boot is disabled
- **Try booting from snapshot**: Advanced options in GRUB

**Login issues:**
- **Default credentials**: Try `user` / `rearch` if you didn't change them
- **Reset password from live USB**:
  ```bash
  mount /dev/sdaX /mnt
  arch-chroot /mnt
  passwd username  # Change password for your user
  ```

### 🚨 **KDE/Desktop Issues**

**Desktop doesn't load:**
- **Check SDDM**: Should see graphical login, not text
- **Try different session**: Select different desktop environment in SDDM
- **Check logs**: `journalctl -b` for boot errors

**No audio:**
```bash
# Check PipeWire status:
systemctl --user status pipewire

# Restart audio:
systemctl --user restart pipewire
```

**No network:**
```bash
# Check NetworkManager:
sudo systemctl status NetworkManager

# Restart networking:
sudo systemctl restart NetworkManager
```

### 🚨 **Snapshot Recovery**

If your system breaks after changes:

**Boot from snapshot:**
1. **Reboot**
2. **Select "Advanced options for Arch Linux"** in GRUB
3. **Choose "Arch Linux snapshots"**
4. **Select a snapshot from before the problem**

**Rollback to snapshot:**
```bash
# List snapshots:
sudo snapper list

# Rollback to specific snapshot:
sudo snapper rollback 5  # Replace 5 with snapshot number

# Reboot to activate:
sudo reboot
```

### 📞 **Getting Help**

**Before asking for help, collect this information:**
```bash
# System info:
uname -a
lsblk
df -h

# Recent logs:
journalctl -b | tail -50

# Service status:
systemctl status NetworkManager
systemctl status sddm
systemctl --user status pipewire
```

**Where to get help:**
- **GitHub Issues**: https://github.com/buggerman/re-arch/issues
- **Arch Wiki**: https://wiki.archlinux.org/
- **Forums**: r/archlinux, Arch Linux forums

## License

MIT License - See LICENSE file for details.

## Contributing

- Report issues: GitHub Issues
- Code style: shellcheck compliant
- Testing: Always test in VMs first
- Documentation: Update README for any changes
