#!/bin/sh
# Script to install required packages on Alpine Linux

# Make sure we're running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Starting installation of required packages..."

# Hard-coded list of required packages
REQUIRED_PACKAGES="
    gptfdisk
    hwdata
    dmidecode
    pciutils
    logrotate
    btop
    openssh
    openrc
    sudo
    sysklogd
    openntpd
"

# Update package index
echo "Updating package index..."
apk update

# Install each package and handle errors
for package in $REQUIRED_PACKAGES; do
    echo "Installing $package..."
    if apk add "$package" >/dev/null 2>&1; then
        echo "✓ Successfully installed $package"
    else
        echo "✗ Failed to install $package - package might not exist or there was an error"
    fi
done

echo "Package installation completed."

# Check if all required packages are installed
echo "Verifying installations..."
FAILED=0

for package in $REQUIRED_PACKAGES; do
    if apk info -e "$package" >/dev/null 2>&1; then
        echo "✓ $package is installed"
    else
        echo "✗ $package verification failed"
        FAILED=$((FAILED + 1))
    fi
done

if [ $FAILED -eq 0 ]; then
    echo "All required packages were successfully installed."
else
    echo "Warning: $FAILED package(s) could not be verified."
fi

echo "Done."