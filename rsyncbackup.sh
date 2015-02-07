#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

has_pv=$(command -v pv || true)
has_rsync=$(command -v rsync || true)
has_time=$(command -v time || true)

if [ $has_rsync ]; then
	hostname=${HOSTNAME:-$(hostname -s || uname -n)}
	hostname=${hostname%%.*}

	user=${USER:-$(whoami)}
	user=${user##*\\}

	src=${RSYNC_SRC:-$HOME}
	if [ "$(uname -s)" = "Darwin" ]; then
		dest=${RSYNC_DEST:="/Volumes/backup"}
	else
		dest=${RSYNC_DEST:="/mnt/backup"}
	fi
	dest="$dest/$hostname/$user"

	backup_flags="-rlptDz"
	delete_flags="--delete --delete-excluded"
	exclude_flags="\\
	--exclude '.*DS_Store' \\
	--exclude '.atom' \\
	--exclude '.cache' \\
	--exclude '.dropbox' \\
	--exclude '.node-gyp' \\
	--exclude '.npm' \\
	--exclude '.nvm' \\
	--exclude '.vim*' \\
	--exclude '.Trash' \\
	--exclude 'Downloads' \\
	--exclude 'Dropbox' \\
"
	link_flags="--safe-links"
	test_flags="--dry-run"
	verb_flags="-v --progress --human-readable"

	command_args=""

	backup=
	delete=
	dry_run=
	exclude=
	file=
	link=
	verbose=
	while getopts bd:DeE:ls:tv opt; do
		case $opt in
			b)  backup=1;;
			d)  dest="$OPTARGS";;
			D)  delete=1;;
			e)  exclude=1;;
			E)  file="$OPTARGS";;
			l)  link=1;;
			d)  src="$OPTARGS";;
			t)  dry_run=1;;
			v)  verbose=1;;
			?)  echo "
Usage $0: [-bDelv] [-d destination] [-E exclude_file] [-s source] args
	-b:   backup [$backup_flags]
	-D:   delete files-not in source or excluded-from estination [$delete_flags]
	-e:   pre-defined excludes [$exclude_flags]
	-l:   use safe links [$link_flags]
	-t:   dry-run [$test_flags]
	-v:   verbose [$verb_flags]

	-d:   the destination folder
	      [default: RSYNC_DEST or {backup_mount}/{hostname}/{user}]
	-e:   a plain text file newline-delimited for patterns to exclude
	-s:   the source folder [default: RSYNC_SRC or HOME]

	args: passed through to $has_rsync
"
				  exit 2;;
		esac
	done

	shift $(($OPTIND - 1))
	args=$*

	if [ ! -d $src ]; then
		echo "Source: $src does not exist"
		exit 2
	fi

	if [ ! -r $src ]; then
		echo "Source: $src is not readable"
		exit 2
	fi

	if [ ! -d $dest ]; then
		echo "Destination: $dest does not exist"
		exit 2
	fi

	if [ ! -r $dest ]; then
		echo "Destination: $dest is not writable"
		exit 2
	fi

	if [ -n "$backup" ]; then
		command_args="$command_args $backup_flags"
	fi

	if [ -n "$delete" ]; then
		command_args="$command_args $delete_flags"
	fi

	if [ -n "$exclude" ]; then
		command_args="$command_args $exclude_flags"
	fi

	if [ -n "$file" ] && [ -r $file ]; then
		command_args="$command_args --exclude-from=\"$file\""
	fi

	if [ -n "$link" ]; then
		command_args="$command_args $link_flags"
	fi

	if [ -n "$dry_run" ]; then
		command_args="$command_args $test_flags"
	fi

	if [ -n "$verbose" ]; then
		command_args="$command_args $verb_flags"
	fi

	if [ -n "$args" ]; then
		echo "Passing $args through to $has_brew"
		$command_args="$command_args $args"
	fi

	command_args=${command_args%*\ }
	echo "Running rsync $command_args $src $dest"
	rsync $command_args "$src" "$dest"

	exit 0
fi

exit 1

