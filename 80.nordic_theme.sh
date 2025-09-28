#!/bin/bash

# Nordic GTK Theme Installation Script
# This script downloads and installs the Nordic theme from GitHub

set -e

echo "🎨 Installing Nordic GTK Theme..."

# Variables
THEME_NAME="Nordic"
TEMP_DIR="/tmp/nordic-theme"
THEMES_DIR="$HOME/.themes"
REPO_URL="https://github.com/EliverLara/Nordic"
DOWNLOAD_URL="https://github.com/EliverLara/Nordic/archive/refs/heads/master.zip"

# Create temporary directory
echo "📁 Creating temporary directory..."
mkdir -p "$TEMP_DIR"

# Download Nordic theme
echo "⬇️  Downloading Nordic theme from GitHub..."
cd "$TEMP_DIR"
curl -L "$DOWNLOAD_URL" -o nordic-theme.zip

# Extract the theme
echo "📦 Extracting theme files..."
unzip -q nordic-theme.zip

# Create themes directory if it doesn't exist
echo "📂 Creating themes directory..."
mkdir -p "$THEMES_DIR"

# Install the theme
echo "🔧 Installing Nordic theme..."
if [ -d "$THEMES_DIR/$THEME_NAME" ]; then
    echo "⚠️  Nordic theme already exists. Removing old version..."
    rm -rf "$THEMES_DIR/$THEME_NAME"
fi

# Copy theme files
cp -r "$TEMP_DIR/Nordic-master" "$THEMES_DIR/$THEME_NAME"

# Set proper permissions
chmod -R 755 "$THEMES_DIR/$THEME_NAME"

# Apply the theme if GNOME is available
if command -v gsettings &> /dev/null; then
    echo "🎯 Applying Nordic theme to GNOME..."
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
    gsettings set org.gnome.desktop.wm.preferences theme "$THEME_NAME"
    echo "✅ Nordic theme applied to GNOME!"
else
    echo "ℹ️  GNOME settings not available. Theme installed but not applied."
    echo "   You can apply it manually using your desktop environment's theme settings."
fi

# Clean up
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "🎉 Nordic theme installation completed!"
echo "📍 Theme installed to: $THEMES_DIR/$THEME_NAME"

# Check theme application status
echo ""
echo "🔍 Checking theme application status..."
if command -v gsettings &> /dev/null; then
    CURRENT_GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
    CURRENT_WM_THEME=$(gsettings get org.gnome.desktop.wm.preferences theme)
    
    echo "   Current GTK theme: $CURRENT_GTK_THEME"
    echo "   Current WM theme: $CURRENT_WM_THEME"
    
    if [[ "$CURRENT_GTK_THEME" == "'$THEME_NAME'" ]] && [[ "$CURRENT_WM_THEME" == "'$THEME_NAME'" ]]; then
        echo "✅ Nordic theme is successfully applied!"
    else
        echo "⚠️  Nordic theme is installed but not fully applied."
        echo "   You may need to restart your session or apply manually."
    fi
else
    echo "ℹ️  Cannot check theme status (gsettings not available)"
fi

# Additional information
echo ""
echo "📋 Additional Notes:"
echo "   • To apply manually in other DEs, look for theme settings"
echo "   • Theme location: ~/.themes/Nordic"
echo "   • Original repository: $REPO_URL"
echo "   • For Firefox theme: https://github.com/EliverLara/firefox-nordic-theme"
echo ""
echo "🔧 Manual theme check commands:"
echo "   gsettings get org.gnome.desktop.interface gtk-theme"
echo "   gsettings get org.gnome.desktop.wm.preferences theme"
echo "   ls -la ~/.themes/Nordic"