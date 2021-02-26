#!/bin/sh

# taken from: https://tylermade.net/2017/10/05/how-to-create-a-bootable-iso-image-of-macos-10-13-high-sierra-installer/

# TODO: check if macos

hdiutil create -o /tmp/HighSierra.cdr -size 5200m -layout SPUD -fs HFS+J

hdiutil attach /tmp/HighSierra.cdr.dmg -noverify -mountpoint /Volumes/install_build

sudo /Applications/Install\ macOS\ High\ Sierra.app/Contents/Resources/createinstallmedia \
    --volume /Volumes/install_build \
    --applicationpath /Applications/Install\ macOS\ High\ Sierra.app \
    --nointeraction

mv /tmp/HighSierra.cdr.dmg ${HOME}/Desktop/InstallSystem.dmg

hdiutil detach /Volumes/Install\ macOS\ High\ Sierra

hdiutil convert ${HOME}/Desktop/InstallSystem.dmg -format UDTO -o ${HOME}/Desktop/HighSierra.iso

if [ -f "${HOME}/Desktop/HighSierra.iso.cdr" ]; then
    mv ${HOME}/Desktop/HighSierra.iso.cdr ${HOME}/Desktop/HighSierra.iso
fi

[ -f "${HOME}/Desktop/InstallSystem.dmg" ] && rm -f ${HOME}/Desktop/InstallSystem.dmg
