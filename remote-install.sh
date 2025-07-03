#!/bin/bash

echo "🌱 Downloading Planto from GitHub..."

curl -L -o planto.zip https://github.com/psychic-coder/planto-terminal/archive/refs/heads/main.zip

echo "📦 Unpacking..."
unzip -q planto.zip

cd planto-terminal-main || { echo "❌ Could not enter folder."; exit 1; }

echo "🚀 Running installer..."
bash install-planto.sh

cd ..
rm -rf planto-terminal-main planto.zip

echo "✅ Done. You can now run Planto from /Applications/Planto"
