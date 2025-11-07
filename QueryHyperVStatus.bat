@echo off
setlocal ENABLEEXTENSIONS

REM Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
REM See the file COPYING for copying conditions.

REM Detect if we are running on a version of Windows earlier than 10. Those
REM versions of Windows are end-of-life, and don't feature
REM virtualization-based security, thus users shouldn't be using those
REM versions of Windows and probably won't run into Hyper-V issues if they are
REM still using them.

REM See:
REM https://stackoverflow.com/questions/13212033/get-windows-version-in-a-batch-file

for /f "tokens=4-5 delims=. " %%i in ('ver') do set WINVER=%%i.%%j
if not "%WINVER%" == "10.0" (
  echo This system is not running Windows 10 or higher. This script is likely irrelevant for this system.
  pause
  exit
)

REM Apparently the best way for a script to check if it is running as
REM administrator on Windows is to attempt to run a command that does
REM "nothing" but requires administrator privileges. "net session" is one such
REM command. See:
REM https://stackoverflow.com/a/11995662

net session >nul 2>&1
if not %errorlevel% == 0 (
  echo This script must be run as administrator. Right-click it, and click "Open as administrator".
  pause
  exit
)

echo This script will display information about several Hyper-V related features that may be present on the system. The
echo logs from this script may be useful for determining if Hyper-V has been disabled on the system or not.
echo.
echo Some of the commands this script runs may print error messages. These are not bugs and can be safely ignored.
echo.
pause
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Boot Configuration Data
bcdedit
echo END Boot Configuration Data
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Hyper-V Manager Status
dism /Online /Get-FeatureInfo /FeatureName:Microsoft-Hyper-V
echo END Hyper-V Manager Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Windows Subsystem for Linux Status
dism /Online /Get-FeatureInfo /FeatureName:Microsoft-Windows-Subsystem-Linux
echo END Windows Subsystem for Linux Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Windows Hypervisor Platform Status
dism /Online /Get-FeatureInfo /FeatureName:HypervisorPlatform
echo END Windows Hypervisor Platform Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Virtual Machine Platform Status
dism /Online /Get-FeatureInfo /FeatureName:VirtualMachinePlatform
echo END Virtual Machine Platform Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Memory Integrity Status
echo Displaying registry key
echo "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity",
echo value "Enabled"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v Enabled
echo Displaying registry key
echo "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity",
echo value "WasEnabledBy"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v WasEnabledBy
echo END Memory Integrity Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Virtualization-Based Security Status
echo Displaying registry key "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard",
echo value "EnableVirtualizationBasedSecurity"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity
echo Displaying key "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard",
echo value "RequirePlatformSecurityFeatures"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v RequirePlatformSecurityFeatures
echo END Virtualization-Based Security Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN Credential Guard Status
echo Displaying registry key "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa", value "LsaCfgFlags"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v LsaCfgFlags
echo Displaying registry key "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard", value "LsaCfgFlags"
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard /v LsaCfgFlags
echo END Credential Guard Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo BEGIN System Guard Secure Launch Status
echo Displaying registry key
echo "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard", value "Enabled"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard /v Enabled
echo END System Guard Secure Launch Status
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo All done. Relevant information about Hyper-V-related security features is displayed above.
pause
