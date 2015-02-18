#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

has_grep=$(command -v grep || true)
has_rsync=$(command -v rsync || true)
has_time=$(command -v time || true)

if [ $has_rsync ]; then
  hostname=${HOSTNAME:-$(hostname -s || uname -n)}
  hostname=${hostname%%.*}

  src=${RSYNC_SRC:-$HOME}
  if [ "$(uname -s)" = "Darwin" ]; then
    dest=${RSYNC_DEST:="/Volumes/backup"}
  else
    dest=${RSYNC_DEST:="/mnt/backup"}
  fi
  dest="$dest/$hostname"

  backup_flags="-rlptDz"
  delete_flags="--delete --delete-excluded"
  link_flags="--safe-links"
  test_flags="--dry-run"
  verb_flags="-v --progress --human-readable"

  usage() {
    echo "
Usage $0: [-bDlv] [-d destination] [-e exclude_file] [-s source] args
  -b:   backup [$backup_flags]
  -D:   delete files-not in source or excluded-from estination
        [$delete_flags]
  -h:   show this message
  -l:   use safe links [$link_flags]
  -t:   dry-run [$test_flags]
  -v:   verbose [$verb_flags]

  -d:   the destination folder
        [default: RSYNC_DEST or ${dest}]
  -e:   a plain text file newline-delimited for patterns to exclude
  -s:   the source folder [default: RSYNC_SRC or HOME]

  args: passed through to $has_rsync
    "
  }

  if [ $has_grep ]; then
    rsync_version=$(rsync --version \
      | grep -Eo 'version [0-9]+.[0-9]+.[0-9]+' \
      | grep -Eo '[0-9]+.[0-9]+.[0-9]+')
    rsync_has_progress=$(echo ${rsync_version%.*} 3.1 \
      | awk '{ if ($1 >= $2) print 1; else print 0 }')
  fi

  command_args=""

  backup=
  delete=
  dry_run=
  exclude=
  link=
  verbose=

  if [ -z "$*" ]; then
    usage
    exit
  fi

  while getopts bd:De:hls:tv opt; do
    case $opt in
      b)  backup=1;;
      d)  dest="$OPTARG";;
      D)  delete=1;;
      e)  exclude="$OPTARG";;
      h)  usage && exit;;
      l)  link=1;;
      s)  src="$OPTARG";;
      t)  dry_run=1;;
      v)  verbose=1;;
      ?)  usage && exit 2;;
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

if [ -n "$exclude" ] && [ -r $exclude ]; then
  command_args="$command_args --exclude-from $exclude"
fi

if [ -n "$link" ]; then
  command_args="$command_args $link_flags"
fi

if [ -n "$dry_run" ]; then
  command_args="$command_args $test_flags"
fi

if [ -n "$verbose" ]; then
  command_args="$command_args $verb_flags"
  if [ "$rsync_has_progress" -eq "1" ]; then
    command_args="$command_args --info=progress2"
  fi
fi

if [ -n "$args" ]; then
  echo "Passing $args through to $has_brew"
  $command_args="$command_args $args"
fi

if [ $has_time ]; then
  echo "Running: time rsync $command_args $src $dest"
  time rsync $command_args $src $dest
else
  echo "Running: rsync $command_args $src $dest"
  rsync $command_args $src $dest
fi

exit 0
fi

exit 1
