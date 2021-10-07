# Autopilot Hybrid Azure AD Join with a Customised First Login Status
Provides a customised first login status when deploying Autopilot Hybrid Azure AD Join with User ESP skipped

You can use the files in the repository to create an Intune package for deployment as part of a HAADJ Autopilot Build

Things to note and change in your files:

- Amend the file Deploy-HAADJOOBE.ps1 to include your tenant name and tenant ID if you're planning to use controlled validation using client side registry settings intead of deploying your SCP record in Active Directory (https://docs.microsoft.com/en-us/azure/active-directory/devices/hybrid-azuread-join-control#configure-client-side-registry-setting-for-scp)
- If you're not using controlled validation, comment out the lines for your tenant name and ID. 
