function Initialize-SettingsFile {
    <#
    .SYNOPSIS
    Build a settings file and store it on the computer.

    .DESCRIPTION
    This CMDlet will build a CSV file with information on how to connect to your organizations instance of ISTAdmin.
    You will also be prompted to select your credential file. If you haven't generated a credential file, please refer to the module documentation.
    Lastly you will be prompted to select a folder where the settings file will be stored.

    .PARAMETER Server
    Your organizations API instance of ISTAdmin. e.g: https://api.ist.com/ss12000v2-api/source/<Your customer Id>/v2.0
    This parameter is by default hidden and pre populated with the server adress to the EduCloud API

    .PARAMETER CustomerID
    Your customer id eg. "SE00100"

    .EXAMPLE
    Initialize-SettingsFile -CustomerID SE00100
    # This will give you two different prompts. First one you will have to select the folder where the CSV file are to be stored. Second prompt will ask for the encrypted credential file holding you credentials.

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>

    [CmdletBinding()]

    param (

        # Server URI
        [Parameter(
            DontShow  = $true
        )]
        [string]
        $Server = "https://api.ist.com/ss12000v2-api/source/<REPLACE>/v2.0",

        # Your customer Id eg. SE00100
        [Parameter(Mandatory = $true)]
        [string]
        $CustomerID
    )

    begin {
        # Creating variable to store everything in.
        $SettingsTable = [PSCustomObject]@{}

        # Creates a open folder dialog for you to pick a location for the CSV file.
        $SettingsFilePath = Get-FilePath -Type Settings

        # Creating the correct api URI
        $Server = $Server.Replace('<REPLACE>', $CustomerID)
    }

    process {
        # Creates a open file dialog for you to choose the credential file holding your API key.
        $SettingsTable | Add-Member -MemberType NoteProperty -Name "ClientAuthorizationPath" -Value $(Get-FilePath -Type Authorization | Select-Object -ExpandProperty Authorization)

        # Add the server URI to SettingsTable
        $SettingsTable | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server

        # Add the customerId to the Settingstable
        $SettingsTable | Add-Member -MemberType NoteProperty -Name "CustomerId" -Value $CustomerID
    }

    end {
        # Writing the CSV file
        $SettingsTable | ConvertTo-Csv -NoTypeInformation | Set-Content -Path $SettingsFilePath.Settings

        # Writing a checkfile for the module to remember what location the settings file where stored.
        $SettingsFilePath.Settings | Out-File -LiteralPath $ISTAdminCheckSettingsFilePath

        Write-Output "Settings file saved to $($SettingsFilePath.Settings):"
        $SettingsTable

        Write-Warning -Message "You must reload the module for the changes to take effect and use the -Force parameter."
    }
}
# End function.