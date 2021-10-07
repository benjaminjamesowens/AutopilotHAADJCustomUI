# Autopilot Hybrid Azure AD Join with a Customised First Login Status
## Introduction
Provides a customised first login status which prevents the user from using the devices until Hybrid Azure AD Join from the Autopilot process. It's use is primarily for when the User ESP is configured to be skipped.

## Background
This is my version of customised HAADJ which is built on work and guidance in blogs/articles from Michael Niehaus, Steve Prentice and Joymalya Basu Roy.

You can use the files in the repository to create an Intune package for deployment as part of a HAADJ Autopilot Build

## Things to Prep

- Amend the file Deploy-HAADJOOBE.ps1 to include your tenant name and tenant ID if you're planning to use controlled validation using client side registry settings intead of deploying your SCP record in Active Directory (https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-control#configure-client-side-registry-setting-for-scp). If you're not using controlled validation, comment out the lines for your tenant name and ID.
- Change the PNG image for the toast notification if required by amending .\bin\toastimage.png
- Ensure you're deploying UserESP to be skipped as part of your HAADJ Autopilot setup

## How to Build
- Amend the files as required
- Run the makeapp.cmd to package files
- Follow the instructions to in the Intune_Install_Commands.txt on how to configure the Win32 package in Intune/MEM
- Target the package to be deployed to new device builds (note, I saw a good recommend in Joy's blog from Tommy Nielsen saying "If you would like to exclude all the devices already deployed do the following. Go to the dynamic Autopilot group. Export members to csv. Create new group called “Autopilot devices until (enter your date)”. Import the members csv file. Then add this group to excluded on the win32 app package.)
- Configure the app to be required during ESP in your deployment profile

## How it Works
- Deploys the package during device ESP which is essentially running the Deploy-HAADJOOBE.ps1 script which:
  - Copies the source files to the c:\ProgramData\HAADJOOBE\ directory
  - Creates a scheduled task called "Hybrid Azure AD Join Retry" which is set to run WaitForUserDeviceRegistration.ps1 (a modified version of Steve Prentice's script) which will:
    - Displays the Hybrid Azure AD Join Splash Screen by running the script Invoke-AADHybridLockOOBE.ps1 using ServiceUI.exe from MDT (credit to Joymalya Basu Roy on his script here). Using ServiceUI.exe means the process runs under the context of the SYSTEM account, but the splash screen is presented to the logged in user.
    - Keeps retrying the Automatic-Device-Join scheduled task until it's completed
    - Once successful, deletes it's own scheduled task "Hybrid Azure AD Join Retry" so it doesn't run at every login
    - Determines the interactively logged in user and adds the toast notification to be displayed/run at their next login using the HKCU RunOnce key
    - Reboots the workstation

