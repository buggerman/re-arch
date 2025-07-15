# 🏗️ The Re-Arch Procedure

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/buggerman/re-arch?style=for-the-badge&logo=github&color=yellow)](https://github.com/buggerman/re-arch/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/buggerman/re-arch?style=for-the-badge&logo=github&color=orange)](https://github.com/buggerman/re-arch/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/buggerman/re-arch?style=for-the-badge&logo=github&color=blue)](https://github.com/buggerman/re-arch/watchers)

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Btrfs](https://img.shields.io/badge/Btrfs-FF6B35?style=for-the-badge&logo=linux&logoColor=white)](https://btrfs.wiki.kernel.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

[![Website](https://img.shields.io/badge/🌐_Website-re--arch.xyz-blue?style=for-the-badge)](https://re-arch.xyz/)
[![GitHub Issues](https://img.shields.io/github/issues/buggerman/re-arch?style=for-the-badge&logo=github)](https://github.com/buggerman/re-arch/issues)
[![Last Commit](https://img.shields.io/github/last-commit/buggerman/re-arch?style=for-the-badge&logo=github)](https://github.com/buggerman/re-arch/commits/main)

</div>

---

<div align="center">
<h3>🚀 Professional, opinionated Arch Linux installer that creates optimized desktop systems with multiple desktop environments, advanced snapshot management, and performance optimizations from the ground up.</h3>
</div>

---

### ⚠️ IMPORTANT ⚠️

**THIS IS AN OPINIONATED ARCH LINUX INSTALLER WITH SPECIFIC CONFIGURATION CHOICES**

- 🖥️ Creates a complete desktop system with choice of KDE Plasma, GNOME, XFCE, or Hyprland, plus performance optimizations and security features
- 💻 Designed for fresh installations on dedicated hardware or virtual machines
- ❌ **NOT intended for existing systems with data or custom configurations**
- 🧪 **ALWAYS test in a virtual machine before installing on real hardware**
- 🎯 Makes specific choices about desktop environment, kernel, and system services
- 👥 Best suited for users who want a curated, production-ready Arch Linux setup

**By using this installer, you accept the provided configuration and any system changes.**

## 🚀 Origin Story

**Re-Arch started as a personal automation project** to solve a common problem among my friend group - we were constantly setting up new Arch Linux installations for testing, development, and fresh installs. Every time someone needed a new Arch system, it meant hours of manual configuration to get a desktop environment, audio, snapshots, and all the essential tools working properly.

What began as a simple script to automate our repetitive setup tasks has evolved into a comprehensive, production-ready installer that embodies years of collective experience with Arch Linux. The configurations and package choices reflect real-world usage patterns from developers and power users who wanted:

- **Immediate productivity** - Boot straight into a fully functional desktop (KDE, GNOME, XFCE, or Hyprland)
- **System resilience** - Never lose work due to system breakage
- **Performance optimization** - Desktop responsiveness that rivals any OS
- **Clean architecture** - Logical separation of system and user applications

The project has grown from "let's automate our weekend Arch installs" to a robust solution that can be used by the broader community. While it remains opinionated (reflecting our collective preferences), every choice has been battle-tested through real daily usage across different hardware configurations and use cases.

### 📦 **Package Management Philosophy**

Re-Arch implements a **security-first package management strategy**:

- 🔒 **Flatpak for GUI apps**: Sandboxed, secure, isolated from system
- ⚙️ **pacman for system core**: Essential utilities, libraries, command-line tools  
- 📦 **AUR sparingly**: Only for packages unavailable elsewhere
- 🍺 **Homebrew for development**: Isolated development tools and environments
- 🛡️ **No mixed installations**: Each package type has its designated manager

**🚨 Key Rule: Never install GUI applications (Firefox, LibreOffice, GIMP, etc.) via pacman - always use Flatpak for better security and system stability.**

## ⚛️ **Atomic System Recovery**

**Re-Arch provides enterprise-grade atomic recovery capabilities that make system breakage virtually impossible:**

### 🛡️ **Automatic Protection**
- **Every update is snapshotted**: `snap-pac` automatically creates Btrfs snapshots before ANY package update
- **Bootable recovery points**: Each snapshot appears in GRUB menu - boot from any previous working state
- **30-second recovery**: System breakage → reboot → select snapshot → working system (vs. hours rebuilding)

### 🔄 **True Atomicity**
- **All-or-nothing updates**: Package updates either complete successfully or can be instantly reverted
- **Copy-on-write protection**: Original system state preserved until changes are confirmed working
- **No partial failure states**: Unlike traditional Linux, you can't end up with a "half-updated" broken system

### 💼 **Production-Ready Reliability**
```bash
# System broke after update? Fix in 30 seconds:
sudo snapper list                    # See all snapshots
sudo snapper rollback 15            # Rollback to snapshot #15  
sudo reboot                          # Boot into previous working state
```

**Real-world impact**: What traditionally requires hours of troubleshooting, package downgrading, or complete reinstallation becomes a 30-second reboot operation.

## ✨ Key Features

<div align="center">

| 🚀 **Performance** | 🛡️ **Security** | 🔧 **Reliability** | 🎨 **Modern** |
|:---:|:---:|:---:|:---:|
| Linux Zen Kernel | Flatpak Sandboxing | Btrfs Snapshots | Multiple Desktop Environments |
| Process Optimization | Firewall Protection | Bootable Recovery | Wayland Support |
| Memory Compression | Package Isolation | Atomic Updates | PipeWire Audio |
| Mirror Optimization | Secure Defaults | Error Recovery | Bluetooth Ready |

</div>

### 🎯 **Quick Stats**
- ⏱️ **Installation Time**: 25-35 minutes total
- 📦 **Package Count**: 50+ optimized packages via archinstall
- 🔧 **Post-Config**: 2-3 minutes automated setup
- 💾 **Disk Space**: 20GB minimum, 50GB recommended
- 🎮 **Gaming Ready**: multilib enabled for 32-bit compatibility

## 🎯 Philosophy

The Re-Arch Procedure is designed around three core principles:

### ⚡ Performance
- 🚀 **Zen Kernel**: Uses linux-zen for improved desktop responsiveness
- 🎛️ **Process Optimization**: Automatic process scheduling with ananicy-cpp
- 🧠 **Memory Management**: zram-generator for efficient memory utilization
- 🎵 **Modern Audio**: PipeWire for low-latency audio processing

### 🛡️ Resilience
- 📸 **Btrfs Snapshots**: Automatic system snapshots before package updates
- ⏪ **Bootable Snapshots**: GRUB integration allows booting from any snapshot
- ⚛️ **Atomic Updates**: snap-pac ensures consistent system state during updates
- 🔥 **Firewall**: firewalld provides network security out of the box

### 🧩 Clean Separation of Concerns
- 📱 **GUI Applications**: Flatpak for sandboxed, secure application isolation
- ⚙️ **System Core**: pacman for essential system utilities and libraries
- 📦 **AUR Packages**: paru for software unavailable elsewhere (minimal usage)
- 🛠️ **Development**: Homebrew for development tools isolation
- 🔒 **Security**: Each package manager serves specific, secure purposes

## 📋 Prerequisites

**⚠️ READ THIS CAREFULLY - FOLLOWING THESE REQUIREMENTS PREVENTS 90% OF INSTALLATION ISSUES**

### 💻 System Requirements

**Hardware (MINIMUM):**
- 🔧 **CPU**: x86_64 processor (Intel/AMD 64-bit) 
- 🧠 **RAM**: 4GB minimum, 8GB recommended
- 💾 **Storage**: 20GB minimum free space, 50GB recommended for comfort
- 🚀 **Boot**: UEFI firmware preferred, Legacy BIOS supported

**⚠️ COMPATIBILITY WARNING:**
- ✅ **FULLY SUPPORTED**: Fresh installation on dedicated machines or VMs
- ⚠️ **ADVANCED USERS ONLY**: Dual-boot systems (requires manual partition configuration)
- ❌ **NOT SUPPORTED**: Systems with existing data you want to preserve
- ❌ **WILL NOT WORK**: Without internet connection during installation

### 🌐 Internet Connection Required
- 🔗 **Stable internet required**: Downloads 1-2GB of packages
- 🔌 **Wired connection recommended**: More reliable than WiFi during installation
- 📶 **WiFi setup**: Connect to network BEFORE running installation commands

### 🖥️ Virtual Machine Users
If installing in a VM:
- ⚙️ **Enable**: Virtualization features in VM settings  
- 🧠 **Allocate**: At least 4GB RAM to the VM
- 💿 **Disk size**: 50GB+ virtual disk recommended
- 🚀 **Boot**: Enable EFI boot in VM settings if available

**🚨 DESTRUCTIVE INSTALLATION WARNING**
This installer assumes it controls the entire disk. It WILL erase everything on the target disk. Back up important data BEFORE starting.


## 🚀 Installation

### 📋 **Two-Step Installation (Recommended)**

**🕐 Total time: 25-35 minutes | 📶 Internet required throughout**

---

#### **📋 BEFORE YOU START:**

1. 💿 **Boot from Arch Linux ISO** (download from https://archlinux.org/download/)
2. 🌐 **Connect to internet:**
   ```bash
   # For WiFi (replace "YourNetwork" with your network name):
   iwctl device list
   iwctl station wlan0 connect "YourNetwork"
   
   # Test connection:
   ping google.com
   ```
3. ✅ **You're ready when:** You see successful pings to google.com

---

#### **🚀 STEP 1: Choose Desktop Environment & Install (20-30 minutes)**

**🎨 Choose Your Desktop Environment:**

| Desktop | Command |
|---------|---------|
| **KDE Plasma** (Default) | `archinstall --config-url https://re-arch.xyz/config.json --creds-url https://re-arch.xyz/creds.json` |
| **GNOME** | `archinstall --config-url https://re-arch.xyz/config-gnome.json --creds-url https://re-arch.xyz/creds.json` |
| **XFCE** | `archinstall --config-url https://re-arch.xyz/config-xfce.json --creds-url https://re-arch.xyz/creds.json` |
| **Hyprland** | `archinstall --config-url https://re-arch.xyz/config-hyprland.json --creds-url https://re-arch.xyz/creds.json` |

<details>
<summary>🔄 Alternative URLs (if domain is not working)</summary>

**KDE Plasma (Default):**
```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/config.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/creds.json
```

**GNOME:**
```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/config-gnome.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/creds.json
```

**XFCE:**
```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/config-xfce.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/creds.json
```

**Hyprland:**
```bash
archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/config-hyprland.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/creds.json
```
</details>

**🎛️ What you'll see:** archinstall will open with pre-filled configuration

**💡 RECOMMENDED CHANGES in archinstall:**
- 👤 **Username & Password**: Change from default `user`/`rearch` to your preferences
- 🌍 **Timezone**: Set your timezone
- 🗣️ **Locale**: Set your language/region
- 🏠 **Hostname**: Change from default `arch-desktop`

**🚨 CRITICAL: What NOT to Change in archinstall:**

| ❌ DON'T CHANGE | ✅ WHY KEEP IT | 🛠️ CONSEQUENCE IF CHANGED |
|------------------|----------------|----------------------------|
| **Packages** | Carefully curated list | Missing desktop/audio/snapshots |
| **Disk formatting** | Optimized for snapshots | Snapshot system won't work |
| **Filesystem (Btrfs)** | Required for snapshots | No system recovery ability |
| **Bootloader (GRUB)** | Snapshot integration | Can't boot from snapshots |

**🔐 Default Credentials:** 
- **Username**: `user`
- **Password**: `rearch`
- These are the actual login credentials if not changed during archinstall
- **STRONGLY RECOMMENDED**: Change them during archinstall for security
- Alternative: Change them after first login with `passwd` command

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
- ⚙️ **System services enabled**:
  - `sddm.service` (display manager)
  - `firewalld.service` (network security)
  - `snapper-timeline.timer` & `snapper-cleanup.timer` (snapshots)
  - `grub-btrfsd.service` (bootable snapshots)
  - `ananicy-cpp.service` (process optimization)
  - `packagekit.service` (package management)
  - Note: NetworkManager already enabled by archinstall
- ⚙️ Flatpak and Homebrew repository setup
- ⚙️ Mirror optimization with reflector

### 🎯 **Why This Method?**

- **🏗️ Architecture separation** - archinstall handles packages (80% of work), lite script handles configuration (20%)
- **⚡ Faster execution** - Complete system ready in 25-35 minutes
- **🛡️ Better reliability** - Proven archinstall for package management reduces dependency conflicts
- **🔧 Simpler maintenance** - Clear separation between installation and configuration phases
- **🧪 Tested approach** - Leverages archinstall's extensive testing and validation
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

## 📦 What Gets Installed

### 🔧 Core System
- 🚀 linux-zen kernel for desktop optimization
- 🥾 GRUB bootloader with Btrfs snapshot support
- 📸 snapper + snap-pac for automatic system snapshots
- 🗂️ **Btrfs Subvolume Layout:**
  - `@` → `/` (root filesystem)
  - `@home` → `/home` (user data)
  - `@log` → `/var/log` (system logs)
  - `@pkg` → `/var/cache/pacman/pkg` (package cache)
  - Compression: zstd for optimal performance

### 🖥️ Desktop Environment
- 🎨 KDE Plasma desktop (plasma-desktop, plasma-nm, plasma-pa, powerdevil)
- 🏠 SDDM display manager with Breeze theme
- 🌊 Plasma Wayland protocols and xdg-desktop-portal-kde
- 📱 Essential applications: Konsole, Dolphin, Discover (package manager)
- 🔍 PackageKit integration for software management
- 🔵 Bluetooth support (bluez, bluez-utils, bluedevil)
- ⚠️ **No web browser included** - install via Flatpak after first boot

### ⚡ Performance & Security
- 🎛️ ananicy-cpp for automatic process optimization
- 🧠 zram-generator for compressed memory management
- 🎵 PipeWire complete audio system (pipewire, pipewire-alsa, pipewire-pulse, pipewire-jack, wireplumber)
- 🔥 firewalld network security
- 🖥️ Mesa graphics drivers
- 📶 NetworkManager for network management

### 🛠️ Package Management Architecture
- 🔨 **pacman**: Core system (base-devel, git, curl, wget, system libraries)
- 📱 **Flatpak**: GUI applications with Flathub repository (browsers, office, media)
- 📦 **AUR**: Manual paru installation required for specialized packages
- 🍺 **Homebrew**: Development tools isolation
- 🎮 **multilib**: 32-bit compatibility enabled for gaming and legacy software

### 📚 System Utilities & Fonts
- 📖 Manual pages (man-db, man-pages)
- 📝 nano text editor
- 📂 File system support (ntfs-3g for Windows drives)
- 🗜️ Archive support (unzip)
- 🔤 Quality fonts (Liberation, DejaVu, Open Sans, Noto)
- 🪞 reflector for mirror optimization

**📦 AUR Access with paru**

AUR helper availability depends on installation method:

- **📋 Two-Step Method (Recommended)**: No AUR helper included for faster, more reliable installation
- **⚗️ Legacy Conversion Method**: Includes automatic paru installation

**Install paru manually (Two-Step Method):**
```bash
# After first boot - install paru AUR helper
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

## 🏁 Post-Installation

After successful completion:
1. 🚪 Exit the chroot environment: `exit`
2. 📤 Unmount the filesystem: `umount -R /mnt`
3. 🔄 Reboot into your new system: `reboot`
4. 🔑 Log in through SDDM with your user account
5. 🎉 Enjoy your optimized Arch Linux desktop!

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

**🚨 IMPORTANT: Use the right package manager for each type of software**

```bash
# ✅ FIRST: Install a web browser (REQUIRED - none included by default)
flatpak install flathub org.mozilla.firefox

# ✅ SYSTEM PACKAGES (pacman) - Only for core system tools
sudo pacman -S htop neofetch tree vim

# ✅ GUI APPLICATIONS (Flatpak) - Sandboxed, secure, recommended for all apps
flatpak install flathub org.libreoffice.LibreOffice  
flatpak install flathub org.gimp.GIMP
flatpak install flathub com.spotify.Client
flatpak install flathub com.discordapp.Discord
flatpak install flathub org.blender.Blender

# ✅ DEVELOPMENT TOOLS (Homebrew) - Isolated development environment
# brew install nodejs python

# ❌ AVOID: Installing GUI apps via pacman
# sudo pacman -S firefox libreoffice gimp  # DON'T DO THIS

# ✅ AUR PACKAGES (optional - requires paru installation first)
# See "AUR Access with paru" section above for installation
# paru -S visual-studio-code-bin  # Only for packages not available in Flatpak
```

**📦 Package Manager Guidelines:**
- **pacman**: Core system utilities, command-line tools, development libraries
- **Flatpak**: All GUI applications (browsers, office suites, media players, games)
- **AUR**: Only for software unavailable in official repos or Flatpak
- **Homebrew**: Development tools isolation

**🌐 Web Browser Required**: The system includes no web browser by default. Install Firefox or your preferred browser via Flatpak as your first step after login.

## 📸 What You Get

<div align="center">

### 🖥️ **Clean KDE Plasma Desktop**
*Modern, professional desktop environment with Wayland support*

### 📂 **Organized Package Management**
*Clear separation: System (pacman) • Apps (Flatpak) • Development (Homebrew) • Specialized (manual AUR)*

### 🔄 **Snapshot Recovery System**  
*Boot from any snapshot via GRUB for instant system recovery*

### ⚡ **Performance Optimized**
*Zen kernel, process scheduling, and memory compression*

</div>

---

## 🤝 Community & Support

<div align="center">

### 💬 **Get Help**
[![GitHub Discussions](https://img.shields.io/badge/GitHub_Discussions-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/buggerman/re-arch/discussions)
[![GitHub Issues](https://img.shields.io/badge/Bug_Reports-red?style=for-the-badge&logo=github&logoColor=white)](https://github.com/buggerman/re-arch/issues)

### 🌟 **Show Support**
[![GitHub Stars](https://img.shields.io/badge/⭐_Star_Project-yellow?style=for-the-badge&logo=github&logoColor=black)](https://github.com/buggerman/re-arch)
[![Arch Wiki](https://img.shields.io/badge/Arch_Wiki-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://wiki.archlinux.org/)

</div>

---

## 🔧 Troubleshooting

### 🚨 **If archinstall Fails**

**💾 During disk setup:**
- 📏 **Check disk space**: Ensure 20GB+ available
- 💿 **Try different disk**: Some disks have compatibility issues
- 🔄 **Reboot and retry**: Sometimes a fresh start helps

**📦 During package downloads:**
- 🌐 **Check internet**: Run `ping google.com`
- 🪞 **Try different mirror**: Reboot installation media and try again
- ⏳ **Wait and retry**: Sometimes mirrors are temporarily busy

**🔗 Config URL not found:**
- 🔄 **Use alternative URLs**: The GitHub URLs in documentation as fallback
- 🌐 **Check internet**: Ensure you can access websites

**💾 GPT header conflicts (UTM/VirtualBox):**
- 🧹 **Disk cleaning**: Script automatically cleans GPT headers with multiple methods
- 🔧 **Manual fix**: If needed, run `gdisk /dev/sda` → `x` → `z` → `y` → `y`
- 🔄 **Reboot VM**: Sometimes requires a fresh start

### 🚨 **If re-arch-lite.sh Fails**

**🔒 Permission errors:**
```bash
# Ensure you're root in chroot:
whoami          # Should show "root"
id              # Should show uid=0(root)
```

**🌐 Network issues in chroot:**
```bash
# Copy DNS configuration:
cp /etc/resolv.conf /mnt/etc/resolv.conf
# Then re-enter chroot and try again
```

**📦 Package conflicts:**
- 🔄 **Retry once**: Sometimes transient network issues cause failures
- 🪞 **Mirror failures**: Script automatically retries with different mirrors
- 🐛 **If repeated failures**: Report as bug with error output

**🔧 Service enablement issues:**
- 🔍 **Check logs**: Script shows which services failed to enable
- ⚠️ **Non-critical**: Most service failures won't prevent system boot
- 🔄 **Manual enable**: After reboot, run `sudo systemctl enable <service-name>`

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

## 📄 License

MIT License - See LICENSE file for details.

## 🤝 Contributing

<div align="center">

[![Contributors](https://img.shields.io/github/contributors/buggerman/re-arch?style=for-the-badge&logo=github)](https://github.com/buggerman/re-arch/graphs/contributors)
[![Pull Requests](https://img.shields.io/github/issues-pr/buggerman/re-arch?style=for-the-badge&logo=github)](https://github.com/buggerman/re-arch/pulls)

</div>

We welcome contributions! Here's how you can help:

- 🐛 **Report bugs**: [GitHub Issues](https://github.com/buggerman/re-arch/issues)
- ✨ **Suggest features**: [GitHub Discussions](https://github.com/buggerman/re-arch/discussions)
- 🔧 **Submit fixes**: Pull requests welcome
- 📚 **Improve docs**: Help make instructions clearer
- 🧪 **Test installations**: Share your experience in different environments

### 📋 **Development Guidelines**
- ✅ All shell scripts must pass `shellcheck`
- 🧪 Test changes in virtual machines first
- 📝 Update documentation for any functional changes
- 🏷️ Follow conventional commit messages

---

<div align="center">

### 🌟 **Made with ❤️ for the Arch Linux Community**

[![Built with](https://img.shields.io/badge/Built_with-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Powered by](https://img.shields.io/badge/Powered_by-archinstall-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://github.com/archlinux/archinstall)

**Re-Arch Procedure** • *Professional Arch Linux Installation*

[🌐 Website](https://re-arch.xyz/) • [📚 Documentation](https://github.com/buggerman/re-arch#readme) • [🐛 Issues](https://github.com/buggerman/re-arch/issues) • [💬 Discussions](https://github.com/buggerman/re-arch/discussions)

</div>
