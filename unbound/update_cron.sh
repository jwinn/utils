#!/bin/sh -e

cwd=$(dirname -- "$0")
tmpfile="/tmp/crontab.a"

crontab -l > $tmpfile

if [ -z "$(cat $tmpfile | grep '${cwd}/ad_servers.sh')" ]; then
	echo "" >> $tmpfile
	echo "# unbound ad server" >> $tmpfile
	echo "0\t13\t*\t*\t2\t${cwd}/ad_servers.sh" >> $tmpfile
fi

if [ -z "$(cat $tmpfile | grep '${cwd}/root_hints.sh')" ]; then
	echo "" >> $tmpfile
	echo "# unbound root hints" >> $tmpfile
	echo "0\t13\t*\t*/6\t*\t${cwd}/root_hints.sh" >> $tmpfile
fi

crontab $tmpfile
rm -f $tmpfile
