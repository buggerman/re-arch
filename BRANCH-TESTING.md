# Branch Testing Guide

## Testing with Relative Paths

This project now supports flexible URLs for testing across branches with proper handling of both local files and remote URLs.

### Local Testing
```bash
# Test locally with files in current directory (recommended)
./test-install

# Or manually set the base URL to current directory
export RE_ARCH_BASE_URL="$(pwd)"
./install

# Direct execution also works
bash install
```

### GitHub Pages Branch Testing
```bash
# Set your branch's GitHub Pages URL
export GITHUB_PAGES_URL="https://username.github.io/re-arch"
./test-install
```

### Environment Variables
- `RE_ARCH_BASE_URL` - Override the base URL for config files
- `GITHUB_PAGES_URL` - Used by test-install for GitHub Pages testing

### Debugging Installation Issues

If the automated script fails but manual installation works:

```bash
# Enable debug mode for verbose output
export RE_ARCH_DEBUG=1
./test-install

# Or run the install script directly with debug
RE_ARCH_DEBUG=1 ./install

# If that fails, try the manual approach the script suggests:
archinstall --config /tmp/config.json --creds /tmp/creds.json
# Then in chroot:
arch-chroot /mnt
curl -fsSL https://re-arch.xyz/re-arch-lite.sh | bash
```

### Troubleshooting Tips
1. **Check downloaded files**: Script validates JSON syntax automatically
2. **Enable debug mode**: Shows detailed execution steps
3. **Manual fallback**: Script provides exact manual commands to try
4. **Mount point validation**: Script checks if /mnt is properly mounted

### Error Prevention
The install script now properly handles:
- ✅ Local file paths (no "Malformed URL" errors)
- ✅ Remote URLs (HTTP/HTTPS)
- ✅ Automatic detection of file vs URL
- ✅ Proper error messages for missing files
- ✅ JSON validation of config files
- ✅ Debug mode for troubleshooting
- ✅ Better archinstall execution (no stdin interference)

### Website Testing
The website now uses relative paths for:
- ✅ Favicons (favicon.svg, favicon.ico, etc.)
- ✅ Documentation link (README.md)
- ✅ Corrected testing hints in install command

### Install Script Features
- Automatically detects environment (local files vs URLs)
- Supports custom base URLs via environment variables  
- Falls back to production URLs when needed
- Handles both local files and remote URLs correctly
- No more "Malformed input to a URL function" errors