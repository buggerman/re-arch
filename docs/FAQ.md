# Frequently Asked Questions

## General Questions

### What is Re-Arch?
Re-Arch is a production-grade automation script that converts a minimal Arch Linux installation into an atomic system with Btrfs subvolumes and snapshot-based updates.

### Is Re-Arch safe to use?
Yes! Re-Arch includes multiple safety features:
- Multiple confirmation prompts before destructive operations
- Comprehensive test mode for safe dry-run execution
- Input validation and error handling
- Atomic updates with automatic rollback capability

### What desktop environments are supported?
Re-Arch currently supports:
- KDE Plasma
- GNOME
- XFCE

## Installation Questions

### What are the system requirements?
- Existing minimal Arch Linux installation
- Root access
- Target disk for installation (will be completely wiped)
- Internet connection for package downloads

### Can I test Re-Arch before running it on my system?
Absolutely! Use the test mode: `sudo re-arch --test`

This will perform a complete dry-run without making any actual changes to your system.

## Usage Questions

### How do I specify a different target disk?
Use the `--target-disk` option:
```bash
sudo re-arch --target-disk /dev/nvme0n1
```

### Can I use a configuration file?
Yes! Create a configuration file and use it with:
```bash
sudo re-arch --config myconfig.conf
```

### How do I update the system after conversion?
Use the atomic update script:
```bash
sudo atomic-update
```

### How do I rollback if something goes wrong?
Use the atomic rollback script:
```bash
sudo atomic-rollback
```

## Technical Questions

### What is the Btrfs subvolume layout?
```
/dev/sdX1 - EFI System Partition (512MB)
/dev/sdX2 - Btrfs Partition
  ├── @ (root, mounted read-only)
  ├── @home (user data)
  ├── @log (system logs)
  └── @snapshots (system snapshots)
```

### How do atomic updates work?
1. Create a snapshot of the current system
2. Mount the snapshot as read-write
3. Update packages in the snapshot
4. Set the updated snapshot as the default for next boot
5. Reboot to use the updated system

### Can I customize the partition sizes?
Yes! Use environment variables or configuration files:
```bash
export NEW_PART_SIZE="50G"
export EFI_SIZE="1G"
sudo re-arch
```

## Troubleshooting

### The script fails with "permission denied"
Make sure you're running with root privileges:
```bash
sudo re-arch
```

### I get "invalid disk" errors
Check that the target disk exists and is a block device:
```bash
lsblk
ls -la /dev/sd*
```

### Tests are failing
Run tests with verbose output:
```bash
./tests/test_re_arch.sh --verbose
```

Check the test log for details:
```bash
cat tests/test.log
```

## Contributing

### How can I contribute to Re-Arch?
See our [Contributing Guide](../CONTRIBUTING.md) for detailed information about:
- Development setup
- Coding standards
- Testing procedures
- Pull request process

### I found a bug, how do I report it?
Please create an issue on GitHub with:
- Clear description of the problem
- Steps to reproduce
- Your system information
- Any relevant log output

### Can I request new features?
Yes! Feature requests are welcome. Please create an issue describing:
- The feature you'd like to see
- Why it would be useful
- How you envision it working