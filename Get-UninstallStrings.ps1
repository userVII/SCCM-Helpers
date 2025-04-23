$arr = @()

function Add-RegValuesToArray(){
    param (
        [object]$ProgramRegistryName,
        [int]$Arch

    )
    
    $x32path = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $x64path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

    $uninstallerProgramName = $uninstaller.Name
    $smallName = $uninstallerProgramName -replace '.*\\'
    
    if($Arch -eq 32){
        $regKeyPath = "$x32path\$smallName"
        $installArch = "x32"
        
    }elseif($Arch -eq 64){
        $regKeyPath = "$x64path\$smallName"
        $installArch = "x64"
    }

    $displayName = (Get-ItemProperty -path "$regKeyPath").DisplayName
    $displayVersion = (Get-ItemProperty -path "$regKeyPath").DisplayVersion
    $installLocation = (Get-ItemProperty -path "$regKeyPath").InstallLocation
    $productGUID = (Get-ItemProperty -path "$regKeyPath").ProductGUID
    $uninstallString = (Get-ItemProperty -path "$regKeyPath").UninstallString
    
    $realUninstaller = ""
    if($uninstallString -like "*MsiExec*"){
        $pattern = '(?<=\{).+?(?=\})'
        $realUninstaller = [regex]::Matches($uninstallString, $pattern).Value
        $realUninstaller = "MsiExec.exe /X $realUninstaller /quiet /qn"
    }

    return [PSCustomObject]@{InstallArch = $installArch; RegName = $smallName; DisplayName = $displayName; DisplayVersion = $displayVersion; InstallLocation = $installLocation; GUID = $productGUID; UninstallString = $uninstallString; ActualMSIUninstaller = $realUninstaller}
}

$64bitUninstallers = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($uninstaller in $64bitUninstallers){
    $arr += Add-RegValuesToArray -ProgramRegistryName $uninstaller -Arch 64
}

$32bitUninstallers = = Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($uninstaller in $32bitUninstallers){
    $arr += Add-RegValuesToArray -ProgramRegistryName $uninstaller -Arch 32
}


$userDownloadsFolder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$arr | Export-Csv -Path "$userDownloadsFolder\UninstallStrings.csv" -NoTypeInformation
