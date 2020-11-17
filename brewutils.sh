#!/bin/sh -e

[ -n "$DEBUG" ] && set -x

brew=$(command -v brew || true)
[ ! $brew ] && exit 1
if [ -n "$(brew tap | grep 'cask')" ]; then
  has_cask=1
else
  has_cask=0
fi

clean() {
  echo "Tidying up"
  brew cleanup -s;
}

doctor() {
  echo "The doctor is in"
  #brew doctor;
  brew doctor `brew doctor --list-checks | grep -v stray_headers`
  # this is verbose send stdout to /dev/null
  [ $has_cask ] && brew doctor --verbose 1>/dev/null
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
  brew rm $remove
  has_deps=$(join <$(brew leaves) <$(brew deps $remove))
  if [ $has_deps ]; then
    brew rm $has_deps
  fi
}

update() {
  echo "Updating available packages"
  brew update;
}

upgrade() {
  echo "Upgrading packages"
  brew upgrade;
  [ $has_cask ] && brew upgrade --cask
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

  args: passed through, if install, to $brew
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
  echo "Passing \"$args\" through to $brew"
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
