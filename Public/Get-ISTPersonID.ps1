function Get-ISTPersonID {

    [CmdletBinding()]

    param (
        # Id of persons to get
        [Parameter(
            ParameterSetName = "Id"
        )]
        [string]
        $Id,

        # Properties to include in the API call
        [Parameter()]
        [ValidateSet(
            "duties",
            "responsibleFor",
            "placements",
            "ownedPlacements",
            "groupMemberships"
        )]
        [string[]]
        $Properties
    )
    
    begin {
        if (Confirm-NeedNewAccessToken) {
            Get-AccessToken -Credential $(Get-Secret -LiteralPath $ISTSettings.ClientAuthorizationPath)
        }
    }
    
    process {
        
        $RequestUrl = Format-RequestUrl -Action persons_id -Id $Id

        if ($Properties) {
            foreach ($Property in $Properties) {
                if (-not ($RequestUrl -like '*?expand*')) {
                    $RequestUrl = $RequestUrl + "?expand=$Property"
                }
                else {
                    $RequestUrl = $RequestUrl + "&expand=$Property"
                }
            }
        }

        try {
            $Response = Invoke-ISTAdminAPI -RequestUrl $RequestUrl -Method GET -ErrorAction Stop
            $Data = Format-APICall -Property persons_id -InputObject $Response

        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    
    end {
        # return $Response
        return $Data
        # return $RequestUrl
    }
}
# End function.