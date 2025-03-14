#!/bin/sh
# Script to remove all installed packages with GPL-3.0-or-later license
# While preserving packages with licenses like LGPL-3.0-or-later
# IT CANNOT REMOVE THE PACKAGES THAT ARE DEPENDENCIES OF OTHER PACKAGES!!! 

# Make sure we're running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Checking all installed packages for GPL-3.0-or-later licenses..."

# Create a temporary file to store the packages to be removed
TMP_FILE=$(mktemp)
# Create a temporary file to count packages
COUNT_FILE=$(mktemp)
echo "0" > "$COUNT_FILE"

# Get all installed packages with their license information
apk list -I > /tmp/installed_packages.txt

# Process each line
while read -r line; do
    # Check if the license is GPL-3.0-or-later but not LGPL-3.0-or-later
    if echo "$line" | grep -q "GPL-3.0-or-later"; then
        if ! echo "$line" | grep -q "LGPL-3.0-or-later"; then
            # Extract package name and clean it
            package_name=$(echo "$line" | awk '{print $1}')
            clean_name=$(echo "$package_name" | sed 's/-[0-9].*//')
            
            echo "Found package with GPL-3.0-or-later license: $clean_name"
            echo "$clean_name" >> "$TMP_FILE"
            
            # Update counter
            count=$(cat "$COUNT_FILE")
            count=$((count + 1))
            echo "$count" > "$COUNT_FILE"
        else
            echo "Skipping package with LGPL-3.0-or-later license: $(echo "$line" | awk '{print $1}')"
        fi
    fi
done < /tmp/installed_packages.txt

# Get the final count
found_count=$(cat "$COUNT_FILE")
echo "Found $found_count packages with GPL-3.0-or-later license."

if [ "$found_count" -eq 0 ]; then
    echo "No packages with GPL-3.0-or-later license found."
    rm "$TMP_FILE" "$COUNT_FILE" /tmp/installed_packages.txt
    exit 0
fi

echo "The following packages will be removed:"
cat "$TMP_FILE"
echo ""

# Remove packages one by one and handle errors
while read -r package; do
    echo "Removing package: $package"
    if apk del "$package" >/dev/null 2>&1; then
        echo "Successfully removed $package"
    else
        echo "Failed to remove $package (possibly due to dependencies) - skipping"
    fi
done < "$TMP_FILE"

echo "Removal process completed."

# Cleanup
rm "$TMP_FILE" "$COUNT_FILE" /tmp/installed_packages.txt
echo "Done."