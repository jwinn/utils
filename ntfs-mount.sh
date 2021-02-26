#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

diskutil=$(command -v diskutil || true)
if [ -z "${diskutil}" ]; then
  printf "Cannot find diskutil, exiting...\n"
  exit 1
fi

label=$(diskutil list | awk '/NTFS/ { for (i=1;i<=NF;i++) if ($i~"NTFS") print $(i+1) }')
disk=$($diskutil list | awk '/NTFS/ { sub(/s[0-9]/, "s1", $(NF)); print $(NF) }')

if [ -z "${disk}" ]; then
  printf "No NTFS disks found, exiting...\n"
  $diskutil list
  exit 1
fi

if [ -z "${label}" ]; then
  label="UNTITLED"
fi

sudo umount "/Volumes/${label}"
sudo mkdir -p "/Volumes/${label}"
sudo mount -t ntfs -o rw,auto,nobrowse "/dev/${disk}" "/Volumes/${label}"

