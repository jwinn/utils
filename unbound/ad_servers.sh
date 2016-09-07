#!/bin/sh -e
# Convert the Yoyo.org anti-ad server listing into an unbound dns spoof
# redirection list

cwd=$(dirname -- "$0")
file="${cwd%/*}/etc/ad_servers"

curl -sS -L --compressed \
	"http://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&mimetype=plaintext" \
	 -o $file
