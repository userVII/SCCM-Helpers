<#
    .SYNOPSIS
        SCCM Powershell Functions Module

    .DESCRIPTION
        Common functions used to interact with SCCM.

    .NOTES
        Version:  1
        Creation Date:  01-30-2024
        Last Update:  09-27-2024
#>

$SiteCode = ""
$ProviderMachineName = ""
$CollectionID = ""
$initParams = @{}

function Test-ForSCCMModule(){
    if (Get-Module -All -Name ConfigurationManager) {
        return $true
    }else{
        return $false
    }
}

function Import-SCCMModule(){
    Write-Host "Attempting to load Configuration Manager from" $ConfigManagerPath
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    if (Get-Module -All -Name ConfigurationManager) {
        return $true
    }else{
        return $false
    }
}

function Get-SCCMComputersFromCollection(){
    <#
        .SYNOPSIS
            Retrieve all Computers from a given collection from SCCM

        .DESCRIPTION
            Takes in a Collection ID and returns a custom object of PC's from SCCM

        .PARAMETER CollectionID
            Specifies which collection to use for devices

        .NOTES
            Version:  1
            Creation Date:  01-30-2024
            Last Update:  01-31-2024
    #>
     Param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $CollectionID   
    )

    begin{
        $initLocation = Get-Location
        $sccmMachineArray = @()
    }
    
    process{
        $attemptSCCMImport = Test-ForSCCMModule
        if($attemptSCCMImport){
            Write-Information "SCCM module imported successfully" -InformationAction Continue

            # Customizations
            $initParams = @{}
            
            Write-Verbose "Connecting to the SCCM coonsole..."
            Write-Verbose "SiteCode: $SiteCode"
            Write-Verbose "Provider Machine Name: $ProviderMachineName"
            Write-Verbose "Collection ID: $CollectionID"
            Write-Verbose ""

            if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
                New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
            }

            Set-Location "$($SiteCode):\" @initParams

            $pcList = Get-CMCollectionMember -CollectionId $CollectionID
        
            foreach($pc in $pcList){
                $objectPC = New-Object System.Object
                $objectPC | Add-Member -type NoteProperty -name SCCM-PCName -value $($pc.Name)
                $objectPC | Add-Member -type NoteProperty -name SCCM-SerialNumber -value $($pc.SerialNumber)
                $objectPC | Add-Member -type NoteProperty -name SCCM-Active -value $($pc.IsActive)
                $objectPC | Add-Member -type NoteProperty -name SCCM-DeviceOSBuild -value $($pc.DeviceOSBuild)
                $objectPC | Add-Member -type NoteProperty -name SCCM-MACAddress -value $($pc.MACAddress)
                $objectPC | Add-Member -type NoteProperty -name SCCM-UserName  -value $($pc.UserName )
                $objectPC | Add-Member -type NoteProperty -name SCCM-LastLoggedInUser -value $($pc.LastLogonUser)
                $objectPC | Add-Member -type NoteProperty -name SCCM-LastPolicyRequest -value $($pc.LastPolicyRequest)
                $objectPC | Add-Member -type NoteProperty -name SCCM-LastActiveRequest -value $($pc.LastActiveTime)
                $objectPC | Add-Member -type NoteProperty -name SCCM-ResourceType -value $($pc.ResourceType)
                $sccmMachineArray += $objectPC
            }

            
        }else{
            Write-Information "SCCM module could not be imported. SCCM functionality is not possible." -InformationAction Continue
            return $null
        }
    }

    end{
        Set-Location $initLocation
        
        try{
            Get-PSDrive -Name $SiteCode -ErrorAction SilentlyContinue | Remove-PSDrive -Force
        }catch{
            Write-Information "Not connected to SCCM" -InformationAction Continue
        }

        return $sccmMachineArray
    }
    
}

<# Export Controls #>
Export-ModuleMember -function 'Get-*'
Export-ModuleMember -function 'Import-*'
Export-ModuleMember -function 'Remove-*'
Export-ModuleMember -function 'Test-*'
