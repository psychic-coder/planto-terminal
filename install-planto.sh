#!/bin/bash

echo "🚀 Starting Planto installation (macOS-only)..."

# 1. Ensure the OS is macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This installer is only supported on macOS."
  exit 1
fi

INSTALL_DIR="/Applications/Planto"

# 2. Request sudo
echo "🔐 Requesting sudo access to install into /Applications..."
sudo -v || { echo "❌ Sudo access denied. Exiting."; exit 1; }

# 3. Create install directory
echo "📁 Creating $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"

# 4. Copy all files into it
echo "📦 Copying files..."
sudo cp -R . "$INSTALL_DIR"

# 5. Make all .sh files executable again just in case
echo "🔧 Making all .sh files executable..."
sudo find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# 6. Run the setup script
echo "⚙️ Running setup-planto.sh..."
cd "$INSTALL_DIR" || { echo "❌ Failed to cd into install dir."; exit 1; }
sudo ./planto-automate.sh

echo "✅ Planto has been installed to $INSTALL_DIR"
