$Installers = get-wmiobject -query "SELECT * FROM CCM_Application" -namespace "ROOT\ccm\ClientSDK" | Select-Object FullName, InstallState, EvaluationState, ErrorCode, Id, Revision, IsMachineTarget | Where-Object {($_.FullName -Like "*SCCM Console*"-or $_.FullName -like "*Active Roles*") -and ($_.ErrorCode -eq 0)}
foreach($install in $Installers){
    #$install
    $fullName = $install.FullName
    $isInstalled = $install.InstallState
    $appID = $install.ID
    $appRevision = $install.Revision
    $appMachineTarget = $install.IsMachineTarget
    if($isInstalled -ne "Installed"){
        Write-Host "$fullName still needs installing..."
        try{
            ([WmiClass]'Root\CCM\ClientSDK:CCM_Application').Install($appID, $appRevision, $appMachineTarget, 0, "Normal", $false) | Out-Null -ErrorAction Stop
        }
        catch [Exception]{
             $errorMessage = $_.Exception
             Write-Host "Failed to start the installation. Reason: $errorMessage"
        }
    }else{
        Write-Host "$fullName is already installed."
    }
}
