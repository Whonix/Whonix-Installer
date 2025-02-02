#!/bin/bash

## Copyright (C) 2023 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

set -x
set -e
set -o pipefail
set -o nounset

export TARGET_SYSTEM="WINDOWS"

export VERSION_FULL="Dummy"

## All files are created created as empty files using `touch` for the purpose of
## simulated local or CI builds only.
export FILE_LICENSE=~/windows-installer-dummy-temp-delete-me/license.txt
export FILE_WHONIX_OVA=~/windows-installer-dummy-temp-delete-me/Whonix-$VERSION_FULL.ova
export FILE_WHONIX_STARTER_MSI=~/windows-installer-dummy-temp-delete-me/WhonixStarterInstaller.msi
export FILE_VCREDIST_INST_EXE=~/windows-installer-dummy-temp-delete-me/vc_redist.x64.exe
export FILE_VBOX_INST_EXE=~/windows-installer-dummy-temp-delete-me/vbox.exe
export FILE_INSTALLER_BINARY_FINAL=~/windows-installer-dummy-temp-delete-me/WhonixInstaller-$VERSION_FULL.exe

rm --recursive --force ~/windows-installer-dummy-temp-delete-me

mkdir --parents ~/windows-installer-dummy-temp-delete-me

for fso in "$FILE_LICENSE" "$FILE_WHONIX_OVA" "$FILE_WHONIX_STARTER_MSI" "$FILE_VCREDIST_INST_EXE" "$FILE_VBOX_INST_EXE" ; do
  touch "$fso"
done

./build.sh

exit 0
