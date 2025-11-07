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
  echo This system is not running Windows 10 or higher. Hyper-V generally does not need to be enabled on these systems.
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

REM There is no way to disable the "Terminate batch job?" prompt that appears
REM when the user presses Ctrl+C. Such a feature will probably not ever be
REM added to Windows, see
REM https://github.com/microsoft/terminal/issues/217#issuecomment-404240443

echo WARNING: Please read this entire message before proceeding, or you may unintentionally lock yourself out of your system!
echo NOTE: To exit this script, press Ctrl+C, then answer "Y" when asked if you want to terminate a batch job.
echo.
echo This tool will enable Hyper-V-related security features on your Windows 10 or 11 device. This will mostly undo the
echo effects of the corresponding DisableHyperV.bat script.
echo.
echo Several Windows features will be enabled by this:
echo - Device Guard (Memory integrity)
echo - Virtualization-based security
echo - System Guard Secure Launch (if possible)
echo - Windows Hypervisor Platform
echo.
echo The system may present a BitLocker recovery screen on the next reboot.
echo.
echo Enabling the above features will increase the overall security of your system. It will also reduce the performance
echo of VirtualBox and Whonix. If this is unacceptable, you should not proceed with this script.
echo.
echo Before proceeding, please ensure:
echo - If device encryption or BitLocker is enabled, you can access your recovery key
echo - You do not require high performance in Whonix or VirtualBox
echo.
echo This script is not able to modify Group Policy, Intune, or App Control settings, nor can it disable Credential
echo Guard if it is enabled with UEFI lock. The script will also not re-enable Credential Guard.
echo.
pause
echo.
echo FINAL CONFIRMATION: Are you sure you want to enable Hyper-V-related security features?
echo.
pause
echo.
echo OK, enabling security features.
echo.

REM "timeout" is subtly broken and not usable for short sleeps, but it is
REM reasonably usable in this script. See:
REM https://stackoverflow.com/questions/1672338/how-to-sleep-for-five-seconds-in-a-batch-file-cmd#comment16795532_1672375

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Setting "hypervisorlaunchtype" in Boot Configuration Data to "off", then to "auto", by running:
echo     bcdedit /set hypervisorlaunchtype off
echo     bcdedit /set hypervisorlaunchtype auto
timeout 10 /nobreak
bcdedit /set hypervisorlaunchtype off
bcdedit /set hypervisorlaunchtype auto
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Installing Windows Hypervisor Platform, by running:
echo     dism /Online /Enable-Feature:HypervisorPlatform /NoRestart
timeout 10 /nobreak
dism /Online /Enable-Feature:HypervisorPlatform /NoRestart
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Installing Virtual Machine Platform, by running:
echo     dism /Online /Enable-Feature:VirtualMachinePlatform /NoRestart
timeout 10 /nobreak
dism /Online /Enable-Feature:VirtualMachinePlatform /NoRestart
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Enabling Device Guard (Memory integrity), by running:
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity
echo         /v Enabled /t REG_DWORD /d 1 /f
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity
echo         /v WasEnabledBy /t REG_DWORD /d 2 /f
timeout 10 /nobreak
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v Enabled /t REG_DWORD /d 1 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v WasEnabledBy /t REG_DWORD /d 2 /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Enabling Virtualization-Based Security in the registry, by running:
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity
echo         /t REG_DWORD /d 1 /f
timeout 10 /nobreak
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Enabling System Guard Secure Launch, by running:
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard
echo         /v Enabled /t REG_DWORD /d 1 /f
timeout 10 /nobreak
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard /v Enabled /t REG_DWORD /d 1 /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo All done. Hyper-V-related security features should now be enabled.
echo Reboot your system for the above changes to take effect.
pause
