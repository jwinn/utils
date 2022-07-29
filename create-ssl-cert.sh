#!/bin/sh -e

cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

host=${1:-"example.com"}
port=${2:-"443"}
cert=${3:-"file.crt"}

echo | openssl s_client -servername "${host}" -connect "${host}:${port}" 2>/dev/null | openssl x509 -text > ${cert}
