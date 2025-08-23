```
██████╗ ███████╗      █████╗ ██████╗  ██████╗██╗  ██╗
██╔══██╗██╔════╝     ██╔══██╗██╔══██╗██╔════╝██║  ██║
██████╔╝█████╗       ███████║██████╔╝██║     ███████║
██╔══██╗██╔══╝       ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║███████╗     ██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝╚══════╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
```

**Professional, one-command Arch Linux desktop installer with snapshots and optimizations.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)

## 🚀 Quick Install

```bash
# 1. Boot from Arch Linux ISO and connect to internet
# 2. Run the installer:
curl -fsSL https://re-arch.xyz/install | bash
```

**Prerequisites:** You must boot from the latest Arch Linux ISO first!

**That's it!** Choose your desktop environment and let it install. 25-35 minutes later you have a complete desktop system.

## ✨ What You Get

- **Desktop Environment**: KDE Plasma, GNOME, XFCE, or Hyprland (your choice)
- **Performance**: Linux Zen kernel, optimized settings, zram compression
- **Snapshots**: Automatic Btrfs snapshots with GRUB boot integration
- **Security**: Firewall enabled, Flatpak sandboxing for apps
- **Package Managers**: pacman (system), Flatpak (apps), paru (AUR), Homebrew (development)
- **Modern Audio**: PipeWire with low-latency configuration

## 📋 Requirements

- **Arch Linux ISO**: Latest stable version (boot from this first!)
- **Hardware**: 4GB+ RAM, 20GB+ storage, x86_64 CPU
- **Internet**: Required throughout installation
- **Target**: Fresh installation (will erase entire disk)

## 🏃‍♂️ Post-Installation

**Default login:** `user` / `rearch` (change immediately)

```bash
# Install web browser (required - none included)
flatpak install flathub org.mozilla.firefox

# Install other apps via Flatpak (recommended)
flatpak install flathub org.libreoffice.LibreOffice
flatpak install flathub org.gimp.GIMP

# Update system
sudo pacman -Syu

# Install AUR helper (optional)
git clone https://aur.archlinux.org/paru.git && cd paru
makepkg -si && cd .. && rm -rf paru

# Install development tools via Homebrew (restart shell first)
brew install nodejs python go
brew install fzf ripgrep
```

## 🛡️ Package Management Philosophy

- **pacman**: System core (kernel, drivers, libraries)
- **Flatpak**: GUI applications (secure, sandboxed)
- **paru/AUR**: Packages not available elsewhere (minimal use)
- **Homebrew**: Development tools (isolated environment)

**Rule:** Never install GUI apps via pacman - always use Flatpak for security.

## 🔧 Advanced Usage

### Manual Configuration

If you want to customize before installation:

```bash
# Option 1: Direct URL method (recommended)
archinstall --config-url https://re-arch.xyz/config-kde.json --creds-url https://re-arch.xyz/creds.json

# Option 2: Download and customize
curl -O https://re-arch.xyz/config-kde.json
curl -O https://re-arch.xyz/creds.json
# Edit as needed, then:
archinstall --config config-kde.json --creds creds.json

# After installation, run post-config:
arch-chroot /mnt
curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash
```

### Snapshot Recovery

If your system breaks:

```bash
# View snapshots
sudo snapper list

# Rollback to snapshot #15
sudo snapper rollback 15
sudo reboot
```

Your system boots from the previous working state in 30 seconds.

## 🎯 Design Philosophy

**Simplicity**: One command installation with sane defaults  
**Performance**: Zen kernel, process optimization, memory compression  
**Reliability**: Automatic snapshots, atomic updates, tested configurations  
**Security**: Firewall, sandboxed apps, minimal attack surface

## ⚠️ Important Notes

- **Destructive**: Erases entire target disk
- **Internet Required**: Downloads ~2GB during installation
- **Fresh Installs Only**: Not for existing systems
- **Test First**: Always test in VM before real hardware

## 🐛 Troubleshooting

**Common Issues:**

- **GPT errors**: Reboot and try again, disk cleaning handles most cases
- **Network issues**: Ensure stable internet connection
- **Disk not found**: Check with `lsblk`, installer shows available disks
- **Installation fails**: Check internet, try again after disk cleanup

**Support:** [GitHub Issues](https://github.com/buggerman/re-arch/issues)

## 📜 License

MIT License - Feel free to use, modify, and distribute.

---

**Made for Arch Linux enthusiasts who want a production-ready system without the setup hassle.**