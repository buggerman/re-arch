# Re-Arch: Atomic Arch Linux Converter

[![CI](https://github.com/username/re-arch/workflows/CI/badge.svg)](https://github.com/username/re-arch/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Check](https://github.com/username/re-arch/workflows/shellcheck/badge.svg)](https://github.com/username/re-arch/actions)

A production-grade automation script that converts a minimal Arch Linux installation into an atomic system with Btrfs subvolumes and snapshot-based updates.

## 🚀 Features

- **Atomic Updates**: Snapshot-based system updates with automatic rollback capability
- **Safe Operations**: Multiple confirmation prompts before destructive operations
- **Flexible Configuration**: Support for environment variables, config files, and command-line arguments
- **Desktop Environment Support**: KDE Plasma, GNOME, and XFCE
- **Test Mode**: Comprehensive dry-run capability for safe testing
- **Comprehensive Logging**: Detailed operation logging with timestamps
- **Production Ready**: Extensive error handling and validation

## 📋 Prerequisites

- Existing minimal Arch Linux installation
- Root access
- Target disk for installation (will be completely wiped)
- Internet connection for package downloads

## 🛠 Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/username/re-arch/main/install.sh | sudo bash
```

### Manual Install

```bash
git clone https://github.com/username/re-arch.git
cd re-arch
sudo chmod +x re-arch.sh
```

## 🔧 Usage

### Basic Usage

```bash
# Interactive mode with prompts
sudo ./re-arch.sh

# Specify target disk and desktop environment
sudo ./re-arch.sh --target-disk /dev/sdb --de gnome

# Test mode (dry-run) - safe to test without making changes
sudo ./re-arch.sh --test --verbose
```

### Configuration Options

#### Command Line Arguments

```bash
sudo ./re-arch.sh [OPTIONS]

Options:
  -h, --help              Show help message
  -v, --version           Show version information
  -c, --config FILE       Use custom configuration file
  -t, --test              Run in test mode (dry-run)
  -V, --verbose           Enable verbose output
  --target-disk DISK      Target disk (default: /dev/sda)
  --de DESKTOP            Desktop environment (kde|gnome|xfce)
  --hostname NAME         System hostname
  --username NAME         User name
  --timezone TZ           Timezone (default: UTC)
```

#### Environment Variables

```bash
export TARGET_DISK="/dev/nvme0n1"
export DE_CHOICE="kde"
export HOSTNAME="atomic-workstation"
export USERNAME="myuser"
export TIMEZONE="America/New_York"
export TEST_MODE="true"
export VERBOSE="true"

sudo -E ./re-arch.sh
```

#### Configuration File

Create a configuration file:

```bash
# config.conf
TARGET_DISK="/dev/sdb"
NEW_PART_SIZE="50G"
DE_CHOICE="gnome"
HOSTNAME="atomic-arch"
USERNAME="user"
LOCALE="en_US.UTF-8"
TIMEZONE="America/New_York"
KEYMAP="us"
```

Use the configuration file:

```bash
sudo ./re-arch.sh --config config.conf
```

## 🏗 System Architecture

### Btrfs Subvolume Layout

```
/dev/sdX1 - EFI System Partition (512MB)
/dev/sdX2 - Btrfs Partition
  ├── @ (root, mounted read-only)
  ├── @home (user data)
  ├── @log (system logs)
  └── @snapshots (system snapshots)
```

### Atomic Updates

The system includes two main update utilities:

#### `atomic-update`
Performs snapshot-based system updates:

```bash
# Update system with automatic snapshot
sudo atomic-update

# Dry-run mode
sudo atomic-update --dry-run

# Verbose output
sudo atomic-update --verbose
```

#### `atomic-rollback`
Rolls back to previous snapshots:

```bash
# List available snapshots
sudo atomic-rollback --list

# Interactive rollback
sudo atomic-rollback

# Rollback to specific snapshot
sudo atomic-rollback @_update_20231201_120000

# Dry-run mode
sudo atomic-rollback --dry-run @_update_20231201_120000
```

## 🧪 Testing

### Running Tests

```bash
# Run basic test suite
./tests/test_re_arch.sh

# Run all tests including integration and performance
./tests/test_re_arch.sh --all

# Run only integration tests
./tests/test_re_arch.sh --integration

# Run only performance tests
./tests/test_re_arch.sh --performance
```

### Test Coverage

The test suite includes:

- **Syntax validation**: Script syntax and shellcheck compliance
- **Argument parsing**: Command-line arguments and environment variables
- **Configuration validation**: Invalid inputs and edge cases
- **Function testing**: Individual function behavior
- **Integration testing**: Full dry-run execution
- **Performance testing**: Script execution time benchmarks

## 🔄 CI/CD Pipeline

The project includes comprehensive CI/CD automation:

- **Continuous Integration**: Automated testing on every commit
- **Shell Check**: Static analysis for shell scripts
- **Security Scanning**: Vulnerability detection
- **Release Automation**: Automated versioning and releases
- **Documentation**: Auto-generated documentation updates

## 📁 Project Structure

```
re-arch/
├── re-arch.sh              # Main script
├── tests/
│   ├── test_re_arch.sh      # Test suite
│   └── fixtures/            # Test fixtures
├── .github/
│   └── workflows/           # CI/CD workflows
├── docs/                    # Documentation
├── scripts/                 # Helper scripts
├── configs/                 # Example configurations
├── Makefile                 # Build automation
├── Dockerfile               # Container image
└── README.md               # This file
```

## 🛡 Security Features

- **Input validation**: Comprehensive validation of all user inputs
- **Privilege escalation**: Explicit root requirement checks
- **Safe defaults**: Conservative default configurations
- **Confirmation prompts**: Multiple safety confirmations
- **Test mode**: Safe dry-run capability
- **Logging**: Comprehensive audit trail

## 🐛 Troubleshooting

### Common Issues

#### "Permission denied" errors
```bash
# Ensure script has execute permissions
chmod +x re-arch.sh

# Run with sudo
sudo ./re-arch.sh
```

#### "Invalid disk" errors
```bash
# Check available disks
lsblk

# Verify disk path
ls -la /dev/sd*
```

#### Test failures
```bash
# Run with verbose output
./tests/test_re_arch.sh --verbose

# Check test logs
cat tests/test.log
```

### Getting Help

1. Check the [FAQ](docs/FAQ.md)
2. Review [troubleshooting guide](docs/TROUBLESHOOTING.md)
3. Search existing [issues](https://github.com/username/re-arch/issues)
4. Create a [new issue](https://github.com/username/re-arch/issues/new)

## 📝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/username/re-arch.git
cd re-arch

# Install development dependencies
make dev-setup

# Run tests
make test

# Run linting
make lint

# Build release
make build
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Arch Linux community for the excellent documentation
- Btrfs developers for the snapshot functionality
- Contributors and testers who helped improve this project

## 📚 Related Projects

- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [Btrfs Wiki](https://btrfs.wiki.kernel.org/)
- [systemd-boot](https://www.freedesktop.org/wiki/Software/systemd/systemd-boot/)

---

**Warning**: This script will completely wipe the target disk. Always test in a virtual machine first and ensure you have backups of important data.