function New-Secret {
    
    <#
    .SYNOPSIS
    Saves a secret into a XML file.
    
    .DESCRIPTION
    This CMDlet will save either a PSCredential (username and password) or just a SecureString into an encrypted cliXML file.
    The exported cliXML file will only be readable on the very same computer it was generated on and by the user doing the export.
    
    .PARAMETER Name
    String provided here will be used to name the file. The filename will also be given the current user- and computer name running the action.
    
    .PARAMETER Path
    Where the encrypted cliXML file will be stored. If the directory does not exist, it will be created.
    
    .PARAMETER Username
    Username to be used in conjunction with the secret.
    
    .PARAMETER Secret
    The actual secret. Saved into a SecureString and masked in the console.
    
    .EXAMPLE
    New-Secret -Name "MyServiceAccountSecret" -Path "C:\TMP\Secrets" -Username "MyServiceAccount"
    This example will save the cliXML file to C:\TMP\Secrets. The file will be named "MyServiceAccountSecret.crd" and contain both the username and an encrypted string of the secret.
    
    .EXAMPLE
    New-Secret -Name 'MySecretAPIKey' -Path "C:\TMP\Secrets"
    This example will save the cliXML file to C:\TMP\Secrets. The file will be named "MySecretAPIKey.crd" and contain only an encrypted string of the secret.


    .NOTES
    General notes
    #>

    [CmdletBinding()]

    param (
        # Name of the secret file
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        # Path to store CLIXML file
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # Username that will be connected with the provided secret.
        [Parameter()]
        [string]
        $Username,

        # Secret to be encrypted
        [Parameter(
            Mandatory = $true,
            DontShow  = $true
        )]
        [securestring]
        $Secret
    )
    
    begin {

        # Boolean variable used to determine whether or not to return success code.
        $SecretStored = $false

        # Format the file name for consistensy
        if ($Name -notlike "*.*") {
            $Name = "$($Name)_$($env:USERNAME)-$($env:COMPUTERNAME).crd"
        }
        elseif ($Name -notlike '*.crd') {
            $Name = "$($Name.Substring(0, $Name.IndexOf('.')))_$($env:USERNAME)-$($env:COMPUTERNAME).crd"
        }

        # Test the provided path and create it if it does not exist.
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }

        # Create the object that will be returned in the end. Either a securestring or a pscredential.
        if (-not ($Username)) {
            [securestring]$CredObject = $Secret
        }
        else {
            [pscredential]$CredObject = New-Object -TypeName System.Management.Automation.PSCredential ($Username, $Secret)
        }
    }
    
    process {
        
        # The actual export of the credentials object.
        try {
            $CredObject | Export-Clixml -Path "$Path\$Name" -ErrorAction Stop
            $SecretStored = $true
        }
        catch {
            Write-Host $_.Exception.Message
        }
        
    }
    
    end {
        # Success code
        if ($SecretStored -eq $true) {
            Write-output "Secrets object successfully stored in $Path"
        }
    }
}
# End function.