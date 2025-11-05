bcdedit /set hypervisorlaunchtype off
dism /Online /Disable-Feature:Microsoft-Hyper-V /NoRestart
dism /Online /Disable-Feature:HypervisorPlatform /NoRestart
dism /Online /Disable-Feature:VirtualMachinePlatform /NoRestart
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v Enabled /t REG_DWORD /d 0 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v WasEnabledBy /t REG_DWORD /d 2 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f