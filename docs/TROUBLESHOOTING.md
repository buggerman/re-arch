# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with Re-Arch.

## Pre-installation Issues

### "Script not found" or "Permission denied"

**Problem**: Cannot execute the re-arch script.

**Solution**:
```bash
# Make sure the script is executable
chmod +x re-arch.sh

# Run with full path
sudo ./re-arch.sh

# Or install system-wide
sudo make install
```

### "Not running as root"

**Problem**: Script requires root privileges.

**Solution**:
```bash
# Always run with sudo
sudo re-arch

# Check if you have sudo access
sudo -v
```

## Configuration Issues

### "Invalid hostname" error

**Problem**: Hostname contains invalid characters.

**Valid hostnames**:
- Only alphanumeric characters and hyphens
- Cannot start with a hyphen
- Examples: `my-arch`, `workstation1`, `arch-desktop`

**Solution**:
```bash
sudo re-arch --hostname valid-hostname
```

### "Invalid desktop environment" error

**Problem**: Unsupported desktop environment specified.

**Supported options**: `kde`, `gnome`, `xfce`

**Solution**:
```bash
sudo re-arch --de kde
# or
sudo re-arch --de gnome
# or
sudo re-arch --de xfce
```

### "Configuration file not found"

**Problem**: Specified config file doesn't exist.

**Solution**:
```bash
# Check if file exists
ls -la /path/to/config.conf

# Use absolute path
sudo re-arch --config /full/path/to/config.conf

# Create config file first
cat > myconfig.conf << EOF
TARGET_DISK="/dev/sdb"
DE_CHOICE="kde"
TARGET_HOSTNAME="my-system"
USERNAME="myuser"
EOF
```

## Disk and Partition Issues

### "Disk does not exist or is not a block device"

**Problem**: Target disk not found or inaccessible.

**Diagnosis**:
```bash
# List all disks
lsblk

# Check specific disk
ls -la /dev/sda

# Check disk permissions
sudo fdisk -l
```

**Solution**:
- Verify the correct disk path
- Ensure the disk is connected
- Use the correct device name (e.g., `/dev/nvme0n1` for NVMe)

### "No write permission for disk"

**Problem**: Cannot write to the target disk.

**Solution**:
```bash
# Check disk ownership and permissions
ls -la /dev/sda

# Run with sudo
sudo re-arch

# Check if disk is in use
sudo fuser /dev/sda
```

### "Disk has mounted partitions"

**Problem**: Target disk has mounted filesystems.

**Solution**:
```bash
# Check mounted partitions
mount | grep /dev/sda

# Unmount all partitions on the disk
sudo umount /dev/sda*

# Force unmount if necessary
sudo umount -f /dev/sda*

# Check for swap
sudo swapoff -a
```

## Installation Issues

### "Failed to download packages"

**Problem**: Network connectivity or mirror issues.

**Diagnosis**:
```bash
# Test internet connection
ping -c 3 google.com

# Check pacman mirrors
sudo pacman -Sy

# Test mirror speed
sudo pacman-mirrors --fasttrack
```

**Solution**:
```bash
# Update mirror list
sudo pacman -Sy

# Use specific mirror
sudo pacman -S --needed pacman-mirrorlist

# Run re-arch again
sudo re-arch
```

### "Insufficient disk space"

**Problem**: Not enough space for installation.

**Solution**:
- Use a larger target partition size: `--target-disk /dev/sdb`
- Set custom partition size: `NEW_PART_SIZE="50G" sudo re-arch`
- Free up space on the system

### "Package conflicts"

**Problem**: Conflicting packages during installation.

**Solution**:
```bash
# Update package database
sudo pacman -Sy

# Force refresh
sudo pacman -Syy

# Clean package cache
sudo pacman -Sc

# Try installation again
sudo re-arch
```

## Boot Issues

### System doesn't boot after conversion

**Problem**: Bootloader or kernel issues.

**Diagnosis**:
1. Boot from Arch Linux live USB
2. Mount the Btrfs partition:
   ```bash
   sudo mount -o subvol=@ /dev/sdX2 /mnt
   sudo arch-chroot /mnt
   ```

**Solution**:
```bash
# Reinstall bootloader
bootctl install

# Regenerate initramfs
mkinitcpio -P

# Check boot entry
bootctl list
```

### "Emergency mode" or "Failed to mount"

**Problem**: fstab issues or corrupt filesystem.

**Solution**:
```bash
# Boot from live USB and check filesystem
sudo btrfs check /dev/sdX2

# Mount and fix fstab
sudo mount -o subvol=@ /dev/sdX2 /mnt
sudo nano /mnt/etc/fstab

# Regenerate fstab
sudo genfstab -U /mnt > /mnt/etc/fstab
```

## Update Issues

### "atomic-update command not found"

**Problem**: Update scripts not installed.

**Solution**:
```bash
# Check if scripts exist
ls -la /usr/local/bin/atomic-*

# Re-run re-arch to install scripts
sudo re-arch --config existing-config.conf
```

### Update fails with Btrfs errors

**Problem**: Filesystem corruption or space issues.

**Diagnosis**:
```bash
# Check Btrfs filesystem
sudo btrfs filesystem show
sudo btrfs filesystem usage /

# Check for errors
sudo dmesg | grep btrfs
```

**Solution**:
```bash
# Clean up old snapshots
sudo atomic-rollback --list
sudo btrfs subvolume delete /.snapshots/old_snapshot

# Check and repair filesystem
sudo btrfs scrub start /
sudo btrfs scrub status /
```

## Test Issues

### Tests failing locally

**Problem**: Test environment issues.

**Solution**:
```bash
# Install test dependencies
sudo pacman -S shellcheck

# Run with verbose output
./tests/test_re_arch.sh --verbose

# Check test log
cat tests/test.log

# Run specific test
bash -x tests/test_re_arch.sh
```

### CI/CD pipeline failures

**Problem**: GitHub Actions failing.

**Solution**:
1. Check the Actions tab on GitHub
2. Review failed job logs
3. Common fixes:
   ```bash
   # Fix shell issues
   shellcheck re-arch.sh
   
   # Fix formatting
   shfmt -w -i 4 re-arch.sh
   ```

## Recovery Procedures

### Complete system recovery

If your system is completely broken:

1. **Boot from live USB**
2. **Mount the original system**:
   ```bash
   sudo mount -o subvol=@ /dev/sdX2 /mnt
   ```
3. **Restore from backup** or **rollback to previous snapshot**:
   ```bash
   # List snapshots
   sudo btrfs subvolume list /mnt
   
   # Set old snapshot as default
   sudo btrfs subvolume set-default SNAPSHOT_ID /mnt
   ```

### Emergency rollback

If atomic-rollback doesn't work:

```bash
# Boot from live USB
sudo mount /dev/sdX2 /mnt
sudo btrfs subvolume list /mnt

# Find working snapshot
sudo btrfs subvolume set-default OLD_SNAPSHOT_ID /mnt

# Update bootloader
sudo mount /dev/sdX1 /mnt/boot
sudo arch-chroot /mnt bootctl install
```

## Getting Help

If you're still having issues:

1. **Check the logs**: Look for error messages in system logs
2. **Search existing issues**: Check GitHub issues for similar problems
3. **Create a detailed bug report** including:
   - Your system information (`uname -a`)
   - Re-arch version (`re-arch --version`)
   - Full error messages
   - Steps to reproduce
   - Any custom configuration

## Emergency Contacts

For critical system failures:
- Create an urgent GitHub issue
- Include "URGENT" in the title
- Provide complete system details and error logs