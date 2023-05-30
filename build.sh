#!/bin/bash

set -x
set -e
set -o pipefail
set -o nounset

## 1) Requires various envrionment variables:
## See build-einsiedler.sh

## 2) build msi package for whonix starter

if ! [ -x "$(command -v wixl)" ]; then
  echo "$0: ERROR wixl is not installed." >&2
  exit 1
fi

rm -f ./Whonix.msi

wixl \
  --verbose \
  --arch x64 \
  --define whonixVersion="$VERSION" \
  --define whonixInstallerVersion="$INSTALLER_VERSION" \
  --define whonixManufacturer="$MANUFACTURE" \
  --define whonixDescription="$DESCRIPTION" \
  --define whonixFileLicense="$FILE_LICENSE" \
  --define whonixFileMainExe="$FILE_WHONIX_EXE" \
  --output WhonixStarterSetup.msi \
  WhonixStarterSetup.wxs

## 3) set current whonix OVA size in INI file for main setup executable

FILE_WHONIX_OVA_SIZE=$(stat -c%s "$FILE_WHONIX_OVA")
printf "[general]\nsize=$FILE_WHONIX_OVA_SIZE" | tee "WhonixOvaInfo.ini" >/dev/null
## Debugging.
cat "WhonixOvaInfo.ini"

## 4) update resource files

cp "$FILE_LICENSE" LICENSE
cp "$FILE_VBOX_INST_EXE" VBoxSetup.exe

## 5) build executable WhonixSetup.exe

lazbuild -B WhonixSetup.lpr --cpu=x86_64 --os=win64 --compiler=/usr/bin/ppcrossx64

## 6) append Whonix OVA to WhonixSetup.exe

cat WhonixSetup.exe "$FILE_WHONIX_OVA" | tee "WhonixSetup-XFCE-$VERSION.exe" >/dev/null

exit 0
