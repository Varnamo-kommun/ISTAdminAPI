function Get-FilePath {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InitialDirectory
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding()]

    param (

        # Target type
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'Authorization',
            'Settings'
        )]
        [string[]]
        $Type
    )

    begin {

        $Table = [PSCustomObject]@{}

        function OpenDialog {
            param (
                [string]
                $Type,

                [string]
                $Title
            )

            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

            switch ($Type) {
                OpenFileDialog      {
                    $OpenDialog        = New-Object System.Windows.Forms.$Type
                    $OpenDialog.Title  = $Title
                    $OpenDialog.filter = "All files (*.*)| *.*"
                    $OpenDialog.ShowDialog() | Out-Null

                    return $OpenDialog.filename
                }
                FolderBrowserDialog {
                    $OpenDialog             = New-Object System.Windows.Forms.$Type
                    $OpenDialog.Description = $Title
                    $Form                   = New-Object System.Windows.Forms.Form -Property @{TopMost = $true}
                    $Result = $OpenDialog.ShowDialog($Form)

                    if ($Result -eq [Windows.Forms.DialogResult]::OK) {
                        $SettingsFilePath = "$($OpenDialog.SelectedPath)\ISTAdministrationAPI_Settings.csv"
                        return $SettingsFilePath
                    }
                }
            }
        }
    }

    process {

        switch ($Type) {
            Authorization   {
                $OpenParams = @{
                    Type  = "OpenFileDialog"
                    Title = "Select credential file with encrypted client authorization"
                }

                $Table | Add-Member -MemberType NoteProperty -Name $_ -Value $(OpenDialog @OpenParams)
            }
            Settings {
                $OpenParams = @{
                    Type  = "FolderBrowserDialog"
                    Title = "Select path to store the ""ISTAdministrationAPI_Settings.csv"" file"
                }

                $Table | Add-Member -MemberType NoteProperty -Name $_ -Value $(OpenDialog @OpenParams)
            }
        }
    }

    end {
        return $Table
    }
}
# End function.