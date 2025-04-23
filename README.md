# SCCM-Helpers

Modules and scripts I have created through the years to assist with working with SCCM. 

## Modules

### [PS-SCCM-Functions-Module](https://github.com/userVII/SCCM-Helpers/blob/main/PS-SCCM-Functions-Module.psm1)

Not ported completely yet, todo. PS Module to ease the use of automating SCCM in PS. Currently ported: Get-Collection functionality with returnable custom object.


## Scripts

### [Get-UninstallStrings](https://github.com/userVII/SCCM-Helpers/blob/main/Get-UninstallStrings.ps1)

Simple script to export a human readable list of uninstall strings from the registry to the current users downloads folder. When building SCCM apps, tracking these down can be a pain. Test your install, find the quiet uninstall string. Test, rinse, repeat.

### [Start-SCCMApplicationInstalls](https://github.com/userVII/SCCM-Helpers/blob/main/Start-SCCMApplicationInstalls.ps1)

Start application installs through PowerShell. Useful as part of a new image lazy init script when SCCM "Required" doesn't hit fast enough.
