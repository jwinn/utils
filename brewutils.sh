#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

has_brew=$(command -v brew || true)

clean() {
  echo "Tidying up"
  brew cleanup;
}

doctor() {
  echo "The doctor is in"
  brew doctor;
}

install() {
  install=$*
  echo "Installing $install"
  brew install $install
}

remove() {
  remove=$*
  echo "Removing $remove"
  brew remove $remove
  has_deps=$(brew deps $remove)
  [ $has_deps ] && brew remove $(join <(brew leaves) <(brew deps $remove))
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
  Usage $0: [-cduU] [-i packages] [-r package] args
  -c:   clean
  -d:   doctor
  -h:   show this dialog
  -u:   update
  -U:   upgrade

  -i:   packages can be a space-delimited set
  -r:   packages can be a space-delimited set

  args: passed through to $has_brew
  "
}

if [ $has_brew ]; then
  clean=
  doctor=
  install=
  remove=
  update=
  upgrade=

  if [ -z "$*" ]; then
    usage
    exit
  fi

  while getopts cdhuUi:r: opt; do
    case $opt in
      c)  clean=1;;
      d)  doctor=1;;
      h)  usage && exit;;
      i)  install="$OPTARG";;
      r)  remove="$OPTARG";;
      u)  update=1;;
      U)  upgrade=1;;
      ?)  usage && exit 2;;
    esac
  done

  shift $(($OPTIND - 1))
  args=$*

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

  if [ -n "$clean" ]; then
    clean
  fi

  if [ -n "$doctor" ]; then
    doctor
  fi

  if [ -n "$args" ]; then
    echo "Passing $args through to $has_brew"
    brew $args
  fi

  exit 0
fi

exit 1
