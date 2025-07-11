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
            # Check for direct root mountpoint or Btrfs subvolumes
            if partition.get("mountpoint") == "/" or (
                partition.get("fs_type") == "btrfs" and 
                any(sub.get("mountpoint") == "/" for sub in partition.get("btrfs", []))
            ):
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
    
    # Validate user configuration (may be in separate credentials file)
    user_config = config.get("user_config", {})
    if "user" in user_config:
        user = user_config["user"]
        if user.get("sudo") is True:
            print("✅ User: Sudo privileges configured")
        else:
            errors.append("❌ User must have sudo privileges")
        
        username = user.get("username", "")
        if username == "user":
            print("✅ Username: Default 'user' configured (matches credentials file)")
        else:
            print(f"✅ Username: {username}")
    else:
        # Check for separate credentials file setup
        creds_path = Path(__file__).parent / "archinstall-credentials.json"
        if creds_path.exists():
            print("✅ User: Configuration in separate credentials file")
        else:
            warnings.append("⚠️  No user configuration found - ensure credentials file exists")
    
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
    sys_lang = locale_config.get("sys_lang", "")
    if sys_lang in ["en_US", "en_US.UTF-8"]:
        print(f"✅ Locale: {sys_lang} configured")
    else:
        warnings.append(f"⚠️  Locale differs from re-arch.sh default: {sys_lang}")
    
    # Validate timezone  
    timezone = config.get("timezone", "")
    if timezone == "UTC":
        print("✅ Timezone: UTC configured")
    else:
        warnings.append(f"⚠️  Timezone differs from re-arch.sh default: {timezone}")
    
    # Validate desktop environment configuration
    profile_config = config.get("profile_config")
    if profile_config is None:
        print("✅ Profile: No desktop environment (lite script will configure)")
    elif (profile_config.get("profile", {}).get("main") == "Minimal" or 
          profile_config.get("profile", {}).get("main") is None):
        print("✅ Profile: Minimal profile configured (lite script will add KDE)")
    else:
        warnings.append("⚠️  Desktop environment configured - may conflict with lite script KDE setup")
    
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
        print(f"📁 Config: {config_path}")
        print("\n📋 Usage (Lite Approach - Recommended):")
        print("   1. Boot Arch installation media")
        print("   2. Run: archinstall --config-url https://raw.githubusercontent.com/buggerman/re-arch/main/archinstall-config.json --creds-url https://raw.githubusercontent.com/buggerman/re-arch/main/archinstall-credentials.json")
        print("   3. After installation: arch-chroot /mnt")
        print("   4. Run: curl -fsSL https://raw.githubusercontent.com/buggerman/re-arch/main/re-arch-lite.sh | bash")
        return 0
    else:
        print(f"\n❌ Configuration validation failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())