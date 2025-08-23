# Branch Testing Guide

## Testing with Relative Paths

This project now supports flexible URLs for testing across branches:

### Local Testing
```bash
# Test locally with files in current directory
RE_ARCH_BASE_URL="$(pwd)" ./install

# Or use the test script
./test-install
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

### Website Testing
The website now uses relative paths for:
- ✅ Favicons (favicon.svg, favicon.ico, etc.)
- ✅ Documentation link (README.md)
- ✅ Local testing hints in install command

### Install Script Features
- Automatically detects environment
- Supports custom base URLs via environment variables
- Falls back to production URLs when needed
- Works with both local files and remote URLs