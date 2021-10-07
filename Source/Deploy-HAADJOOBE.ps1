# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

# Create a tag file just so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\HAADJOOBE"))
{
    Mkdir "$($env:ProgramData)\HAADJOOBE"
}
Set-Content -Path "$($env:ProgramData)\HAADJOOBE\HAADJOOBEDeployment.tag" -Value "Installed"

# Start logging
Start-Transcript "$($env:ProgramData)\HAADJOOBE\HAADJOOBEDeployment.log"

# Setting source folder
$installFolder = "$PSScriptRoot\"

# Adding registry items for Hybrid Azure Active Directory Join
Write-Host "Setting registry items for Hybrid Azure Active Directory Join"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD" /v TenantId /t REG_SZ /d 40ccd880-3f4e-44fb-bcaa-721b070aae5d /f | Out-Host
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD" /v TenantName /t REG_SZ /d delosincorporated.onmicrosoft.com /f | Out-Host

# STEP 19: Adding Hybrid Azure AD Join script process
Write-Host "Setting registry items for running Hybrid Azure AD Join at machine startup for 60 minutes"
If (-Not (Test-Path "$($env:ProgramData)\HAADJOOBE"))
{
    Mkdir "$($env:ProgramData)\HAADJOOBE"
}

# Copy items to c:\programdata\ folder
Copy-Item -Path "$installFolder\*" -Destination "$($env:ProgramData)\HAADJOOBE\" -Recurse -Force
$argument = "-Noprofile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""$($env:ProgramData)\HAADJOOBE\WaitForUserDeviceRegistration.ps1"""
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $Argument
$trigger =  New-ScheduledTaskTrigger -AtLogOn
#$trigger.Delay = 'PT2M'
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 12)
Register-ScheduledTask -RunLevel Highest -Action $action -Trigger $trigger -TaskName "Hybrid Azure AD Join Retry" -Description "Starts Powershell script at login which will keep retrying the Automatic-Device-Join scheduled tasks under '\Microsoft\Windows\Workplace Join' until the device becomes Hybrid Azure AD Joined" -User "NT Authority\SYSTEM" -Settings $Settings

Stop-Transcript
