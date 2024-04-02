function Get-Secret {

    <#
    .SYNOPSIS
    Retrieves a saved secret.

    .DESCRIPTION
    This function will retrieve a previously saved secret. Note that the secret will only be readable by the user whom saved it and on the same computer it was saved.

    .PARAMETER Path
    Path to the secret.

    .EXAMPLE
    $Secret = Get-Secret -Path "C:\Secrets\TestAPI_USERNAME-COMPUTERNAME.crd"

    .NOTES
    Author: Simon Mellergård | It-avdelningen, Värnamo kommun
    #>

    [CmdletBinding()]

    param (
        # Path to secrets file
        [Parameter()]
        [ValidateScript({$(Test-Path $_) -eq $true})]
        [string]
        $LiteralPath
    )
    
    begin {

    }
    
    process {
        try {
            $CredObject = Import-Clixml -Path $LiteralPath
        }
        catch {
            
        }
    }
    
    end {
        return $CredObject
    }
}