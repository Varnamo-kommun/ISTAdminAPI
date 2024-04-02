function Get-ISTStudentGroupLookUp {

    [CmdletBinding()]

    param (
        # List of Id to search the IST API for.
        [Parameter(
            ParameterSetName = "Ids"
        )]
        [System.Object]
        $Ids,

        # Determines how the returned object should be prepared as a payload for the Egil API
        [Parameter()]
        [ValidateSet(
            "Organisation",
            "SchoolUnitGroup",
            "SchoolUnit",
            "Student",
            "StudentMemberShip",
            "StudentGroup",
            "TeacherRole",
            "Employment",
            "Teacher"
        )]
        [string]
        $APIReady
    )
    
    begin {
        if (Confirm-NeedNewAccessToken) {
            Get-AccessToken -Credential $(Get-Secret -LiteralPath $ISTSettings.ClientAuthorizationPath)
        }
    }
    
    process {
        
        $Payload = Format-RequestUrl -Action groups_lookup -PersonsLookup $Ids -Type ids
        
        try {
            $Response = Invoke-ISTAdminAPI -Payload $Payload -Method Post -ErrorAction Stop

            $Data = if ($APIReady) {
                Format-APICall -Property groups_lookup -InputObject $Response -APIReady $APIReady -ErrorAction Stop
            }
            else {
                Format-APICall -Property groups_lookup -InputObject $Response -ErrorAction Stop
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    
    end {
        if ($Response) {
            return $Data
        }
        else {
            return $RequestString
        }
        # return $RequestString
    }
}
# End function.