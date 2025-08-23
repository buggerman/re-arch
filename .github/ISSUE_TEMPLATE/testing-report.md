---
name: Testing Report
about: Report testing results or issues with Re-Arch installation
title: '[TEST] '
labels: ['testing', 'feedback']
assignees: ''

---

## Testing Environment

**Desktop Environment Tested:** [KDE/GNOME/XFCE/Hyprland]
**Installation Method:** [Single command / Manual archinstall]
**Hardware:** [Physical/VM - specs]
**Date Tested:** [YYYY-MM-DD]

## Installation Results

### ✅ What Worked
- [ ] Installer downloaded and started successfully
- [ ] Desktop environment selection worked
- [ ] Disk selection and preparation worked
- [ ] Base system installation completed
- [ ] Post-configuration script ran successfully
- [ ] System booted correctly
- [ ] Desktop environment loaded properly
- [ ] Snapshots configured correctly
- [ ] Package managers available (pacman, Flatpak, Homebrew)

### ❌ What Failed
<!-- Describe any failures or issues encountered -->

### ⚠️ Warnings or Minor Issues
<!-- Any non-critical issues or warnings -->

## Performance

**Total Installation Time:** [XX minutes]
**System Resources Used:** [RAM/CPU during install]
**Post-Install Performance:** [Desktop responsiveness, boot time]

## Testing Results

### Core Functionality
- [ ] Btrfs snapshots work (`sudo snapper list`)
- [ ] Rollback functionality (`sudo snapper rollback X`)
- [ ] Flatpak works (`flatpak --version`)
- [ ] Homebrew works (`brew --version` after shell restart)
- [ ] Firewall enabled (`sudo firewall-cmd --state`)
- [ ] Audio works (PipeWire)
- [ ] Bluetooth works (if hardware available)
- [ ] Network connectivity stable

### Package Management
- [ ] System packages: `sudo pacman -Syu`
- [ ] Flatpak apps: `flatpak install flathub org.mozilla.firefox`
- [ ] AUR packages: `paru -S` (if paru installed)
- [ ] Homebrew tools: `brew install htop`

### Desktop Environment Specific
- [ ] Display manager loads correctly
- [ ] Desktop environment starts properly
- [ ] Basic applications work
- [ ] System settings accessible
- [ ] File manager functional
- [ ] Terminal emulator works

## Suggestions

<!-- Any suggestions for improvement -->

## Additional Notes

<!-- Any other observations, logs, or relevant information -->

## Command Outputs

```bash
# Include relevant command outputs if there were issues
# For example:
# sudo snapper list
# flatpak --version
# systemctl status firewalld
```

---

**Testing Template Version:** 1.0
**Re-Arch Version:** [branch/commit tested]