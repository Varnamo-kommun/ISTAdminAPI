$ModuleRoot = $PSScriptRoot
$Script:ISTAdminCheckSettingsFilePath = "$env:ProgramData\ISTAdminAPI\ISTAdminCheck-$($env:USERNAME)_$($env:COMPUTERNAME).checkfile"
$SettingsFileExists = $false

try {
    Get-Variable -Name ISTSettings -Scope Global -ErrorAction Stop
    # Write-Host "Settings funnen!" -ForegroundColor Green
    $SettingsExist = $true
}
catch {
    $SettingsExist = $false
    # Write-Host "ISTSettings återfanns inte!" -ForegroundColor Red
}

$Private = @(Get-ChildItem -Path $ModuleRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem -Path $ModuleRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Nested  = @(Get-ChildItem -Path $ModuleRoot\Resources\SecretClixml\Public\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in @($Private + $Public + $Nested)) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

if (-not (Test-Path $ISTAdminCheckSettingsFilePath)) {
    if (-not (Test-Path $($ISTAdminCheckSettingsFilePath | Split-Path))) {
        try {
            New-Item -Path $($ISTAdminCheckSettingsFilePath | Split-Path) -ItemType Directory
        }
        catch {
            Write-Warning $_.Exception.Message
        }
    }
    Write-Warning -Message "No settings file found. Please configure the module by running Initialize-SettingsFile provided with your information."
    Export-ModuleMember -Function New-Secret, Get-Secret, Initialize-SettingsFile
}
elseif (-not (Test-Path -Path $(Get-Content -Path $ISTAdminCheckSettingsFilePath))) {
    Write-Warning -Message "No settings file found. Please configure the module by running Initialize-SettingsFile provided with your information."
    Export-ModuleMember -Function New-Secret, Get-Secret, Initialize-SettingsFile
}
else {
    if (-not ($SettingsExist)) {
        $CSV = Import-Csv -Path (Get-Content -Path $ISTAdminCheckSettingsFilePath)
        New-Variable -Name ISTSettings -Value $CSV -Scope Global -Force
    }
    $SettingsFileExists  = $true

    Export-ModuleMember -Function $Public.Basename
    # Export-ModuleMember -Function $Private.Basename
    Export-ModuleMember -Function $Nested.Basename
}

switch ($SettingsFileExists) {
    True    {
        if (-not ($SettingsExist)) {
            Export-ModuleMember -Variable ISTSettings
        }
        else {
            Write-Host "Reusing existing Settings variable." -ForegroundColor Green
        }
    }
    False   {Export-ModuleMember -Variable ISTAdminCheckSettingsFilePath}
    Default {}
}