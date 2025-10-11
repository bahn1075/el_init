#!/bin/bash

# Firefox Korean Wayland Setup Script for WSL Ubuntu 24
# This script installs Korean fonts, sets up Korean locale, and configures Firefox for Wayland

set -e

echo "=========================================="
echo "Firefox Korean Wayland Setup"
echo "=========================================="
echo ""

# Update package lists
echo "[1/5] Updating package lists..."
sudo apt update

# Install Korean fonts and language pack
echo ""
echo "[2/5] Installing Korean fonts and language pack..."
sudo apt install -y fonts-noto-cjk fonts-noto-cjk-extra fonts-nanum language-pack-ko

# Verify Korean locale is generated
echo ""
echo "[3/5] Verifying Korean locale..."
if locale -a | grep -q "ko_KR.utf8"; then
    echo "✓ Korean locale (ko_KR.UTF-8) is available"
else
    echo "✗ Korean locale not found. Generating..."
    sudo locale-gen ko_KR.UTF-8
fi

# Detect shell configuration file
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
else
    RC_FILE="$HOME/.profile"
fi

echo ""
echo "[4/5] Configuring shell environment ($RC_FILE)..."

# Backup the RC file
cp "$RC_FILE" "${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✓ Backup created: ${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# Check if Korean locale settings already exist
if grep -q "export LANG=ko_KR.UTF-8" "$RC_FILE"; then
    echo "✓ Korean locale settings already exist in $RC_FILE"
else
    echo "" >> "$RC_FILE"
    echo "# Korean language support" >> "$RC_FILE"
    echo "export LANG=ko_KR.UTF-8" >> "$RC_FILE"
    echo "export LC_ALL=ko_KR.UTF-8" >> "$RC_FILE"
    echo "✓ Added Korean locale settings to $RC_FILE"
fi

# Check if Firefox Wayland settings already exist
if grep -q "export MOZ_ENABLE_WAYLAND=1" "$RC_FILE"; then
    echo "✓ Firefox Wayland settings already exist in $RC_FILE"
else
    echo "" >> "$RC_FILE"
    echo "# Firefox Wayland support" >> "$RC_FILE"
    echo "export MOZ_ENABLE_WAYLAND=1" >> "$RC_FILE"
    echo "✓ Added Firefox Wayland settings to $RC_FILE"
fi

# Verify installation
echo ""
echo "[5/5] Verifying installation..."
echo "✓ Korean fonts installed:"
fc-list :lang=ko | head -3

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Close and reopen your terminal, or run: source $RC_FILE"
echo "2. Launch Firefox"
echo "3. Visit about:support in Firefox and check 'Window Protocol' shows 'wayland'"
echo "4. Test Korean text rendering on any Korean website"
echo ""
echo "Note: If Firefox was already running, please restart it."
