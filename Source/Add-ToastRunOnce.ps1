Function CurrentUser {
     $LoggedInUser = get-wmiobject win32_computersystem | select username
     $LoggedInUser = [string]$LoggedInUser
     $LoggedInUser = $LoggedInUser.split("=")
     $LoggedInUser = $LoggedInUser[1]
     $LoggedInUser = $LoggedInUser.split("}")
     $LoggedInUser = $LoggedInUser[0]
     $LoggedInUser = $LoggedInUser.split("\")
     $LoggedInUser = $LoggedInUser[1]
     Return $LoggedInUser
}

$CurrentUser = CurrentUser
$ProfileFolder = "c:\users\" + $CurrentUser
$ProfileFolder

$key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
$subkeys = (Get-Item $key).GetSubKeyNames()
foreach($subkey in $subkeys)
{
        $a = $key + "\" + $subkey
        $regsearch = Get-ItemProperty -Path $a

    if($regsearch.ProfileImagePath -eq $ProfileFolder) {
$ProfileSID = $subkey}
}

$ProfileSID


$ProfileRegPath = "HKU:\" + $ProfileSID + "\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
$ProfileRegPath

#Add HKEY_USERS to a PSDrive for easy access later
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS

Set-ItemProperty $ProfileRegPath -Name '!HAADJSplash' -Value 'powershell.exe -executionpolicy bypass -windowstyle Hidden -nologo -file "C:\ProgramData\HAADJOOBE\ToastNotification.ps1"'

Remove-PSDrive -Name HKU