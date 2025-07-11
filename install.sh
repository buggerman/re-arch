#!/bin/bash
set -euo pipefail

VERSION="latest"
REPO="buggerman/re-arch"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="re-arch"

echo "Installing Re-Arch..."

# Download and install
if [ "$VERSION" = "latest" ]; then
    echo "Downloading latest version..."
    curl -fsSL "https://raw.githubusercontent.com/$REPO/main/re-arch.sh" -o "/tmp/$SCRIPT_NAME"
else
    echo "Downloading version $VERSION..."
    curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/re-arch-$VERSION.tar.gz" | tar -xz
    cp "re-arch/re-arch.sh" "/tmp/$SCRIPT_NAME"
    rm -rf re-arch/
fi

# Install script
sudo cp "/tmp/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Cleanup
rm "/tmp/$SCRIPT_NAME"

echo "Installation complete!"
echo "Run 'sudo re-arch --help' to get started"