#!/bin/bash

echo "🌱 Downloading Planto from GitHub..."

# Download the repo as zip
curl -L -o planto.zip https://github.com/psychic-coder/planto-terminal/archive/refs/heads/main.zip

echo "📦 Unpacking Planto..."
unzip -q planto.zip

# Move into the extracted folder
cd planto-terminal-main || { echo "❌ Could not enter extracted folder."; exit 1; }

echo "🚀 Running installer..."
bash install-planto.sh
