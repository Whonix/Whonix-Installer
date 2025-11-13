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
  echo This system is not running Windows 10 or higher. Hyper-V generally does not need to be disabled on these systems.
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
echo This tool will disable Hyper-V on your Windows 10 or 11 device. This may improve Whonix performance.
echo.
echo Several Windows features depend on Hyper-V in order to function. These features will be disabled:
echo - Windows Hello
echo - Windows Subsystem for Linux (WSL2)
echo - Memory Integrity
echo - Credential Guard
echo - Virtualization-based security
echo - System Guard Secure Launch
echo - Windows Hypervisor Platform
echo - Hyper-V Manager
echo.
echo Additionally, the system may present a BitLocker recovery screen on the next reboot.
echo.
echo Disabling the above features will reduce the overall security of your system (although it will not substantially
echo affect the security of Whonix). If this is unacceptable, you should not proceed with this script.
echo.
echo Before proceeding, please ensure:
echo - You can log into Windows without Windows Hello
echo - If device encryption or BitLocker is enabled, you can access your recovery key
echo - You do not use or need any of the features listed above
echo.
echo This script is not able to modify Group Policy, Intune, or App Control settings, nor can it disable Credential
echo Guard if it is enabled with UEFI lock.
echo.
pause
echo.
echo FINAL CONFIRMATION: Are you sure you want to disable Hyper-V?
echo.
pause
echo.
echo OK, disabling Hyper-V.
echo.

REM "timeout" is subtly broken and not usable for short sleeps, but it is
REM reasonably usable in this script. See:
REM https://stackoverflow.com/questions/1672338/how-to-sleep-for-five-seconds-in-a-batch-file-cmd#comment16795532_1672375

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Setting "hypervisorlaunchtype" in Boot Configuration Data to "auto", then to "off", by running:
echo     bcdedit /set hypervisorlaunchtype auto
echo     bcdedit /set hypervisorlaunchtype off
timeout 10 /nobreak
bcdedit /set hypervisorlaunchtype auto
bcdedit /set hypervisorlaunchtype off
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Uninstalling Hyper-V Manager, by running:
echo     dism /Online /Disable-Feature:Microsoft-Hyper-V /NoRestart
echo NOTE: This command may print error messages if you are using Windows Home. This is expected and can be safely ignored.
timeout 10 /nobreak
dism /Online /Disable-Feature:Microsoft-Hyper-V /NoRestart
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Uninstalling Windows Subsystem for Linux, by running:
echo     dism /Online /Disable-Feature:Microsoft-Windows-Subsystem-Linux /NoRestart
timeout 10 /nobreak
dism /Online /Disable-Feature:Microsoft-Windows-Subsystem-Linux /NoRestart
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Uninstalling Windows Hypervisor Platform, by running:
echo     dism /Online /Disable-Feature:HypervisorPlatform /NoRestart
timeout 10 /nobreak
dism /Online /Disable-Feature:HypervisorPlatform /NoRestart
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Uninstalling Virtual Machine Platform, by running:
echo     dism /Online /Disable-Feature:VirtualMachinePlatform /NoRestart
timeout 10 /nobreak
dism /Online /Disable-Feature:VirtualMachinePlatform /NoRestart
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Disabling Memory Integrity, by running:
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity
echo         /v Enabled /t REG_DWORD /d 0 /f
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity
echo         /v WasEnabledBy /t REG_DWORD /d 2 /f
timeout 10 /nobreak
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v Enabled /t REG_DWORD /d 0 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v WasEnabledBy /t REG_DWORD /d 2 /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Disabling Virtualization-Based Security in the registry, by running:
echo     reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity /f
echo     reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v RequirePlatformSecurityFeatures /f
echo NOTE: These commands may print error messages. They may be safely ignored.
timeout 10 /nobreak
reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity /f
reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v RequirePlatformSecurityFeatures /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Disabling Virtualization-Based Security in boot configuration data, by running:
echo     bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO,DISABLE-VBS
echo     bcdedit /set vsmlaunchtype off
echo NOTE These commands may print error messages. They may be safely ignored.
timeout 10 /nobreak
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO,DISABLE-VBS
bcdedit /set vsmlaunchtype off
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Disabling Credential Guard in registry, by running:
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v LsaCfgFlags /t REG_DWORD /d 0 /f
echo     reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard /v LsaCfgFlags /t REG_DWORD /d 0 /f
timeout 10 /nobreak
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v LsaCfgFlags /t REG_DWORD /d 0 /f
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard /v LsaCfgFlags /t REG_DWORD /d 0 /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo Disabling System Guard Secure Launch, by running:
echo     reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard
echo         /v Enabled /t REG_DWORD /d 0 /f
timeout 10 /nobreak
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard /v Enabled /t REG_DWORD /d 0 /f
echo.

echo =========================================================================
echo -------------------------------------------------------------------------
echo =========================================================================
echo All done. Hyper-V should now be disabled.
echo Reboot your system for the above changes to take effect.
pause
