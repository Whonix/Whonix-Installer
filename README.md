
# Whonix-Installer

Simple Installer for Whonix-Starter to setup and configure Whonix with VirtualBox.

# Build installer

install WiX-Toolset on Windows or wixl on Linux

Linux:

1. Install dependencies.

Using [`ppcross_install`](https://github.com/Whonix/misc/blob/main/ppcross_install).

```
./ppcross_install
```

2. sudo apt-get install wixl

3. copy Whonix.exe, Whonix.ova, license.txt and vbox.exe to source dir

4. go to source directory

5. run ./build.sh
