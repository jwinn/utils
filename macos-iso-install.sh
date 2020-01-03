#!/bin/sh -e

version=${1:-Catalina}

# Remove the virtual disk, if it exists
[ -f "/tmp/${version}" ] && rm -f /tmp/${version}
[ -f "/tmp/${version}.dmg" ] && rm -f /tmp/${version}.dmg

# Create a virtual disk for installation media (DMG file)
hdiutil create -o /tmp/${version} -size 8000m -layout SPUD -fs HFS+J

# Mount the disk
hdiutil attach /tmp/${version}.dmg -noverify -mountpoint /Volumes/install_build

# Write the installer into mount point
sudo /Applications/Install\ macOS\ ${version}.app/Contents/Resources/createinstallmedia --volume /Volumes/install_build --nointeraction

# Unmount the installer app
hdiutil detach /Volumes/Install\ macOS\ ${version}

# Save DMG into ISO format
hdiutil convert /tmp/${version}.dmg -format UDTO -o ~/Downloads/${version}

# Change file extension to ISO
mv ~/Downloads/${version}.cdr ~/Downloads/${version}.iso

# Remove the virtual disk, if it exists
[ -f "/tmp/${version}" ] && rm -f /tmp/${version}
[ -f "/tmp/${version}.dmg" ] && rm -f /tmp/${version}.dmg
