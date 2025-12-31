#!/bin/bash

## Copyright (C) 2023 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

set -x
set -e
set -o pipefail
set -o nounset

## Only on developer machine for local test builds only.
#export use_ppcross_x64_maybe="--compiler=/usr/bin/ppcrossx64"
#export skip_fpc_windows_dependencies_check="true"

export TARGET_SYSTEM="WINDOWS"

## hardcoded
export VERSION_FULL="LXQt-18.0.8.3.Intel_AMD64"

export FILE_LICENSE="../deps/license.txt"
export FILE_WHONIX_OVA="../deps/Whonix-$VERSION_FULL.ova"
export FILE_WHONIX_STARTER_MSI="../deps/WhonixStarterInstaller.msi"
export FILE_VCREDIST_INST_EXE="../deps/VC_redist.x64.exe"
export FILE_VBOX_INST_EXE="../deps/VirtualBox-7.2.4-170995-Win.exe"
export FILE_INSTALLER_BINARY_FINAL="build/WhonixInstaller-$VERSION_FULL.exe"

./build.sh

exit 0
