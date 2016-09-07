#!/bin/sh -e

curl -sS -L ftp://FTP.INTERNIC.NET/domain/named.cache -o /var/unbound/etc/root.hints
