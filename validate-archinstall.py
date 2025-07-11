#!/usr/bin/env python3
"""
Archinstall Configuration Validator
Validates the archinstall JSON configuration for re-arch project compatibility
"""

import json
import sys
from pathlib import Path

def validate_config(config_path):
    """Validate archinstall configuration"""
    
    print("🔍 Validating archinstall configuration...")
    
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ Configuration file not found: {config_path}")
        return False
    
    errors = []
    warnings = []
    
    # Check required fields for re-arch compatibility
    required_checks = [
        ("bootloader", "Grub", "GRUB bootloader required for snapshot integration"),
        ("hostname", "arch-desktop", "Should match re-arch.sh default hostname"),
        ("network_config.type", "nm", "NetworkManager required for desktop environment"),
    ]
    
    # Validate bootloader
    if config.get("bootloader") != "Grub":
        errors.append("❌ Bootloader must be 'Grub' for grub-btrfs snapshot integration")
    else:
        print("✅ Bootloader: GRUB configured")
    
    # Validate filesystem
    disk_config = config.get("disk_config", {})
    device_mods = disk_config.get("device_modifications", [])
    
    btrfs_root_found = False
    boot_partition_found = False
    
    for device in device_mods:
        for partition in device.get("partitions", []):
            if partition.get("mountpoint") == "/":
                if partition.get("fs_type") == "btrfs":
                    btrfs_root_found = True
                    print("✅ Root filesystem: Btrfs configured")
                else:
                    errors.append(f"❌ Root filesystem must be Btrfs, found: {partition.get('fs_type')}")
            
            if partition.get("mountpoint") == "/boot":
                boot_partition_found = True
                if partition.get("fs_type") == "fat32":
                    print("✅ Boot partition: FAT32 configured")
                else:
                    warnings.append(f"⚠️  Boot partition should be FAT32, found: {partition.get('fs_type')}")
    
    if not btrfs_root_found:
        errors.append("❌ No Btrfs root partition found")
    
    if not boot_partition_found:
        warnings.append("⚠️  No explicit boot partition found")
    
    # Validate network configuration
    network_type = config.get("network_config", {}).get("type")
    if network_type == "nm":
        print("✅ Network: NetworkManager configured")
    else:
        errors.append(f"❌ Network must use NetworkManager (nm), found: {network_type}")
    
    # Validate user configuration
    user_config = config.get("user_config", {})
    if "user" in user_config:
        user = user_config["user"]
        if user.get("sudo") is True:
            print("✅ User: Sudo privileges configured")
        else:
            errors.append("❌ User must have sudo privileges")
        
        username = user.get("username", "")
        if username == "user":
            warnings.append("⚠️  Username is default 'user' - update re-arch.sh USERNAME variable accordingly")
        else:
            print(f"✅ Username: {username}")
    else:
        errors.append("❌ No user configuration found")
    
    # Validate essential packages
    packages = config.get("packages", [])
    essential_packages = ["git", "base-devel", "sudo"]
    missing_packages = [pkg for pkg in essential_packages if pkg not in packages]
    
    if missing_packages:
        warnings.append(f"⚠️  Consider adding essential packages: {', '.join(missing_packages)}")
    else:
        print("✅ Essential packages: All included")
    
    # Validate locale
    locale_config = config.get("locale_config", {})
    if locale_config.get("sys_lang") == "en_US":
        print("✅ Locale: en_US configured")
    else:
        warnings.append(f"⚠️  Locale differs from re-arch.sh default: {locale_config.get('sys_lang')}")
    
    # Validate timezone  
    timezone = config.get("timezone", "")
    if timezone == "UTC":
        print("✅ Timezone: UTC configured")
    else:
        warnings.append(f"⚠️  Timezone differs from re-arch.sh default: {timezone}")
    
    # Validate no desktop environment (re-arch.sh will install KDE)
    if config.get("profile_config") is None:
        print("✅ Profile: No desktop environment (re-arch.sh will install KDE)")
    else:
        warnings.append("⚠️  Desktop environment configured - re-arch.sh will install KDE Plasma")
    
    # Summary
    print("\n" + "="*60)
    print("VALIDATION SUMMARY")
    print("="*60)
    
    if errors:
        print(f"\n❌ ERRORS ({len(errors)}):")
        for error in errors:
            print(f"   {error}")
    
    if warnings:
        print(f"\n⚠️  WARNINGS ({len(warnings)}):")
        for warning in warnings:
            print(f"   {warning}")
    
    if not errors and not warnings:
        print("\n🎉 Perfect! Configuration is fully compatible with re-arch.sh")
    elif not errors:
        print("\n✅ Configuration is compatible with re-arch.sh (warnings noted)")
    else:
        print("\n❌ Configuration requires fixes before use with re-arch.sh")
    
    return len(errors) == 0

def main():
    """Main validation function"""
    config_path = Path(__file__).parent / "archinstall-config.json"
    
    print("Re-Arch Archinstall Configuration Validator")
    print("="*50)
    
    is_valid = validate_config(config_path)
    
    if is_valid:
        print(f"\n✅ Configuration validated successfully!")
        print(f"📁 File: {config_path}")
        print("\n📋 Usage:")
        print("   1. Boot Arch installation media")
        print("   2. Run: archinstall --config archinstall-config.json")
        print("   3. After installation, run re-arch.sh in chroot")
        return 0
    else:
        print(f"\n❌ Configuration validation failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())