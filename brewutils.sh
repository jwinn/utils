#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

has_brew=$(command -v brew || true)

if [ $has_brew ]; then
  clean() {
    echo "Tidying up"
    brew cleanup -s --force;
  }

  doctor() {
    echo "The doctor is in"
    brew doctor;
  }

  install() {
    install=$*
    echo "Installing $install"
    brew install $install $args
  }

  info() {
    info=$*
    brew info $info
  }

  remove() {
    remove=$*
    echo "Removing $remove"
    brew rm $remove $args
    has_deps=$(brew deps $remove)
    if [ $has_deps ]; then
      brew rm $(join <(brew leaves) <(brew deps $remove))
    fi
  }

  update() {
    echo "Updating available packages"
    brew update;
  }

  upgrade() {
    echo "Upgrading packages"
    brew upgrade;
  }

  usage() {
    echo "
Usage $0: [-cduU] [-i packages] [-I packages] [-r package] -- args
  -c:   clean
  -d:   doctor
  -h:   show this dialog
  -u:   update
  -U:   upgrade

  -i:   install packages, can be a space-delimited set
  -I:   get info for packages, can be space-delimited set
  -r:   remove packages, can be a space-delimited set

  args: passed through, if install, to $has_brew
"
  }

  clean=
  doctor=
  info=
  install=
  remove=
  update=
  upgrade=

  if [ -z "$*" ]; then
    usage
    exit
  fi

  while getopts cdhuUi:I:r: opt; do
    case $opt in
      c)  clean=1;;
      d)  doctor=1;;
      h)  usage && exit;;
      i)  install="$OPTARG";;
      I)  info="$OPTARG";;
      r)  remove="$OPTARG";;
      u)  update=1;;
      U)  upgrade=1;;
      ?)  usage && exit 2;;
    esac
  done

  shift $(($OPTIND - 1))
  args=$*

  if [ -n "$args" ]; then
    echo "Passing \"$args\" through to $has_brew"
  fi

  if [ -n "$update" ]; then
    update
  fi

  if [ -n "$upgrade" ]; then
    upgrade
  fi

  if [ -n "$remove" ]; then
    remove $remove
  fi

  if [ -n "$install" ]; then
    install $install
  fi

  if [ -n "$info" ]; then
    info $info
  fi

  if [ -n "$clean" ]; then
    clean
  fi

  if [ -n "$doctor" ]; then
    doctor
  fi

  exit 0
fi

exit 1
