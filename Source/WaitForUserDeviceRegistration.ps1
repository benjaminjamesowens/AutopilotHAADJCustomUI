# WaitForUserDeviceRegistration.ps1
#
# Version 1.6
#
# Steve Prentice, 2020
#
# Used to pause device ESP during Autopilot Hybrid Join to wait for
# the device to sucesfully register into AzureAD before continuing.
#
# Use IntuneWinAppUtil to wrap and deploy as a Windows app (Win32).
# See ReadMe.md for more information.
#
# Tip: Win32 apps only work as tracked apps in device ESP from 1903.
#
# Exits with return code 3010 to indicate a soft reboot is needed,
# which in theory it isn't, but it suited my purposes.

# Create a tag file just so Intune knows this was installed
If (-Not (Test-Path "$($env:ProgramData)\HAADJOOBE"))
{
    Mkdir "$($env:ProgramData)\HAADJOOBE"
}

# Start Transcript Logging
Start-Transcript "$($env:ProgramData)\HAADJOOBE\WaitForUserDeviceRegistration.log"

# Opening external script to display splash screen for Hybrid Azure AD Process
Start-Process "$PSScriptRoot\ServiceUI.exe" -ArgumentList "-process:explorer.exe c:\Windows\System32\WindowsPowershell\v1.0\powershell.exe $PSScriptRoot\Invoke-AADHybridLockOOBE.ps1"


# Setting variables to gather events in the Microsoft-Windows-User Device Registration/Admin Event Log
$filter304 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '304' # Automatic registration failed at join phase
}

$filter306 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '306' # Automatic registration Succeeded
}

$filter334 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '334' # Automatic device join pre-check tasks completed. The device can NOT be joined because a domain controller could not be located.
}

$filter335 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '335' # Automatic device join pre-check tasks completed. The device is already joined.
}

$filter20225 = @{
  LogName = 'Application'
  Id = '20225' # A dialled connection to RRAS has sucesfully connected.
}

#Create a short pause before the scripts attempts to run the Automatic-Device-Join scheduled task
Start-Sleep -Seconds 30

#First attempt to run Automatic-Device-Join scheduled task
Start-ScheduledTask "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"

# Wait for up to 60 minutes, re-checking once a minute...
While (($counter++ -lt 60) -and (!$exitWhile)) {
    # Let's get some events...
    $events304   = Get-WinEvent -FilterHashtable $filter304   -MaxEvents 1 -EA SilentlyContinue
    $events306   = Get-WinEvent -FilterHashtable $filter306   -MaxEvents 1 -EA SilentlyContinue
    $events334   = Get-WinEvent -FilterHashtable $filter334   -MaxEvents 1 -EA SilentlyContinue
    $events335   = Get-WinEvent -FilterHashtable $filter335   -MaxEvents 1 -EA SilentlyContinue
    $events20225 = Get-WinEvent -FilterHashtable $filter20225 -MaxEvents 1 -EA SilentlyContinue

    If ($events335) { $exitWhile = "True" }

    ElseIf ($events306) { $exitWhile = "True" }

    ElseIf ($events20225 -And $events334 -And !$events304) {
        Write-Host "RRAS dialled sucesfully. Trying Automatic-Device-Join task to create userCertificate..."
        Write-Host ($Date = Get-Date -Format "yyyy/MM/dd HH:mm")
        Start-ScheduledTask "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
        Write-Host "Sleeping for 60s..."
        Start-Sleep -Seconds 60
    }

    Else {
        Write-Host "No events indicating successful device registration with Azure AD."
        Write-Host "Sleeping for 60s..."
        Start-Sleep -Seconds 60
        If ($events304) {
            Write-Host "Trying Automatic-Device-Join task again..."
            Write-Host ($Date = Get-Date -Format "yyyy/MM/dd HH:mm")
            Start-ScheduledTask "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
            Write-Host "Sleeping for 5s..."
            Start-Sleep -Seconds 5
        }
    }
}

If ($events306) { 
    Write-Host $events306.Message
    Set-Content -Path "$($env:ProgramData)\HAADJOOBE\HAADJOOBECompleted.tag" -Value "Installed"
    Write-Host "Exiting with return code 3010 to indicate a soft reboot is needed."
    
    # Removing scheduled task once HAADJ is detected as completed
    Unregister-ScheduledTask -TaskPath "\" -TaskName "Hybrid Azure AD Join Retry" -Confirm:$False

    # Adding Toast Notification for next login
    Start-Process powershell.exe -ArgumentList "-Noprofile -WindowStyle Hidden -ExecutionPolicy Bypass -File c:\programdata\HAADJOOBE\Add-ToastRunOnce.ps1" -Wait

    # Stopping transcript
    Stop-Transcript

    # Retstarting the device one HAADJ is detected as completed
    shutdown.exe /r /t 0 /f
    
    Exit 3010
}

If ($events335) { Write-Host $events335.Message }

Write-Host "Script complete, exiting."
Set-Content -Path "$($env:ProgramData)\HAADJOOBE\HAADJOOBECompleted.tag" -Value "Installed"

# Removing scheduled task once HAADJ is detected as completed
Unregister-ScheduledTask -TaskPath "\" -TaskName "Hybrid Azure AD Join Retry" -Confirm:$False

# Adding Toast Notification for next login
Start-Process powershell.exe -ArgumentList "-Noprofile -WindowStyle Hidden -ExecutionPolicy Bypass -File c:\programdata\HAADJOOBE\Add-ToastRunOnce.ps1" -Wait

# Stopping transcript
Stop-Transcript

# Retstarting the device one HAADJ is detected as completed
shutdown.exe /r /t 0 /f

