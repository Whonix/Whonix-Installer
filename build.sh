#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## This script will be called by:
## dm-prepare-release
## https://github.com/Kicksecure/developer-meta-files/blob/master/usr/bin/dm-prepare-release

set -x
set -e
set -o pipefail
set -o nounset

## 1) Requires various environment variables:
## See build-einsiedler.sh

## 2) sanity tests

if ! [ -x "$(command -v wixl)" ]; then
  echo "$0: ERROR: wixl is not installed." >&2
  exit 1
fi

if ! [ -x "$(command -v lazbuild)" ]; then
  echo "$0: ERROR: lazbuild is not installed." >&2
  exit 1
fi

for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_EXE" "$FILE_VBOX_INST_EXE" ; do
  test -r "$fso"
done

## 3) build msi package for whonix starter

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

## 4) set current whonix OVA size in INI file for main setup executable

FILE_WHONIX_OVA_SIZE=$(stat -c%s "$FILE_WHONIX_OVA")

echo "\
[general]
size=$FILE_WHONIX_OVA_SIZE
" | tee "WhonixOvaInfo.ini" >/dev/null

## Debugging.
cat "WhonixOvaInfo.ini"

## 5) update resource files

## TODO: use paths set through environment variables /
##       abolish need to copy/duplicate again here
cp "$FILE_LICENSE" LICENSE
cp "$FILE_VBOX_INST_EXE" VBoxSetup.exe

## 6) build executable WhonixSetup.exe

lazbuild -B WhonixSetup.lpr --cpu=x86_64 --os=win64 --compiler=/usr/bin/ppcrossx64

## 7) append Whonix OVA to WhonixSetup.exe

cat WhonixSetup.exe "$FILE_WHONIX_OVA" | tee "$FILE_INSTALLER_BINARY_WITH_APPENDED_OVA" >/dev/null

exit 0
