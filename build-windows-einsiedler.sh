#!/bin/bash

## Copyright (C) 2023 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Developer script to allow easily only building the Windows-Installer.
## (Without building all of Whonix.)

set -x
set -e
set -o pipefail
set -o nounset

export TARGET_SYSTEM="WINDOWS"

export VERSION_MAJOR="16"
export VERSION_MINOR="0"
export VERSION_REVISION="9"
export VERSION_BUILD="8"

export VERSION_FULL="Xfce-$VERSION_MAJOR.$VERSION_MINOR.$VERSION_REVISION.$VERSION_BUILD"

export FILE_LICENSE="../deps/license.txt"
#export FILE_WHONIX_OVA="../deps/Whonix.ova"
export FILE_WHONIX_OVA="../deps/Whonix-$VERSION_FULL.ova"
export FILE_WHONIX_STARTER_MSI="../deps/WhonixStarterSetup.msi"
export FILE_VBOX_INST_EXE="../deps/vbox.exe"
export FILE_INSTALLER_BINARY_FINAL="WhonixInstaller-$VERSION_FULL.exe"

./build.sh

exit 0