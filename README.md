# Autopilot Hybrid Azure AD Join with a Customised First Login Status
## Introduction
Provides a customised first login status which prevents the user from using the devices until Hybrid Azure AD Join from the Autopilot process. It's use is primarily for when the User ESP is configured to be skipped.

## Background
This is my version of customised HAADJ which is built on work and guidance in blogs/articles from Michael Niehaus, Steve Prentice and Joymalya Basu Roy.

You can use the files in the repository to create an Intune package for deployment as part of a HAADJ Autopilot Build

Things to note and change in your files:

- Amend the file Deploy-HAADJOOBE.ps1 to include your tenant name and tenant ID if you're planning to use controlled validation using client side registry settings intead of deploying your SCP record in Active Directory (https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-control#configure-client-side-registry-setting-for-scp). If you're not using controlled validation, comment out the lines for your tenant name and ID.
- Change the PNG image for the toast notification if required by amending .\bin\toastimage.png

How to build the package:
- Amend the files as required
- Run the makeapp.cmd to package files
- Target the package to be deployed to new device builds (note,

