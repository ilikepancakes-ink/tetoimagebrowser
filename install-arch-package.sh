#!/bin/bash

# Installation script for tuff Image Browser Arch Linux package

set -e

echo "=== tuff Image Browser Arch Package Installer ==="
echo

# Check if we're on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "Error: This script is for Arch Linux systems only."
    exit 1
fi

# Check if makepkg is available
if ! command -v makepkg &> /dev/null; then
    echo "Error: makepkg not found. Please install base-devel:"
    echo "sudo pacman -S base-devel"
    exit 1
fi

# Check dependencies
echo "Checking dependencies..."
missing_deps=()

for dep in ninja clang cmake pkg-config; do
    if ! pacman -Qi "$dep" &> /dev/null; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "Installing missing dependencies: ${missing_deps[*]}"
    sudo pacman -S "${missing_deps[@]}"
fi

# Check for Flutter
if ! command -v flutter &> /dev/null; then
    echo "Warning: Flutter not found in PATH."
    echo "Make sure Flutter is installed and available in your PATH."
    echo "You can install Flutter from: https://flutter.dev/docs/get-started/install/linux"
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build the package
echo "Building the package..."
makepkg -f

# Find the built package
package_file=$(ls tetoimagebrowser-*.pkg.tar.zst | head -n1)

if [ ! -f "$package_file" ]; then
    echo "Error: Package file not found!"
    exit 1
fi

echo "Package built successfully: $package_file"
echo

# Ask if user wants to install
read -p "Install the package now? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Package built but not installed."
    echo "To install later, run: sudo pacman -U $package_file"
    exit 0
fi

# Install the package
echo "Installing the package..."
sudo pacman -U "$package_file"

echo
echo "=== Installation Complete ==="
echo "You can now run 'tetoimagebrowser' from the command line"
echo "or find 'tuff Image Browser' in your application menu."
