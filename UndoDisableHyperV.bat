bcdedit /set hypervisorlaunchtype auto
dism /Online /Enable-Feature:HypervisorPlatform /NoRestart
dism /Online /Enable-Feature:VirtualMachinePlatform /NoRestart
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v Enabled /t REG_DWORD /d 1 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v WasEnabledBy /t REG_DWORD /d 2 /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f
