Function Toast-Notification {

    <#
    .SYNOPSIS
        Sends a notification to the end user
    .PARAMETER ToastAppID
        The AppID launcher associated to notification - run Get-StartApps for list of apps
    .PARAMETER ToastImage
        Image which will displayed
    .PARAMETER ToastTitle
        The main title of the script
    .PARAMETER ToastMessage
        The main text in the message
    #>

    Param (
            
            [Parameter(Mandatory = $true)]
            [string]$ToastAppID,

            [Parameter(Mandatory = $true)]
            [string]$ToastImage,

            [Parameter(Mandatory = $true)]
            [string]$ToastTitle,
            
            [Parameter(Mandatory = $true)]
            [string]$ToastAttribution,

            [Parameter(Mandatory = $true)]
            [string]$ToastText
    )
#Specify Launcher App ID
#Run Get-StartApps to find an appropriate AppID for association to your notification
$LauncherID = $ToastAppID

#Load Assemblies
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
 
#Build XML Template
#for reference
#<binding template="ToastImageAndText03">
[xml]$ToastTemplate = @"
<toast duration="long" launch="c:\temp">
    <visual>
    <binding template="ToastGeneric">
            <text id="1">$ToastTitle</text>
            <text id="2">$ToastText</text>
            <image placement="hero" id="1" src="$ToastImage"/>
            <text placement="attribution">$ToastAttribution</text>
        </binding>
    </visual>
    <actions>
  </actions>
</toast>
"@
 
#Prepare XML
$ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
$ToastXml.LoadXml($ToastTemplate.OuterXml)
 
#Prepare and Create Toast
$ToastMessage = [Windows.UI.Notifications.ToastNotification]::New($ToastXML)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($LauncherID).Show($ToastMessage)

}

Toast-Notification -ToastAppID "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\msinfo32.exe" -ToastImage "$PSScriptRoot\bin\ToastImage.png" -ToastTitle "Autopilot Build Finished" -ToastAttribution "IT Team" -ToastText "The autopilot process has completed and you can use your device. There may be other applications which will install in the background."
