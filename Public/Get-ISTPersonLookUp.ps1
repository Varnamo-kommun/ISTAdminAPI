function Get-ISTPersonLookUp {

    [CmdletBinding()]

    param (
        # List of Id to search the IST API for.
        [Parameter(
            ParameterSetName = "Ids"
        )]
        [System.Object]
        $Ids,

        # List of social security numbers to search the IST API for.
        [Parameter(
            ParameterSetName = "CivicNos"
        )]
        [System.Object]
        $CivicNos,

        # Returns active duties
        [Parameter()]
        [bool]
        $Duties,

        # Returns persons that user are responsible for
        [Parameter()]
        [bool]
        $ResponsibleFor,

        # Returns active placements
        [Parameter()]
        [bool]
        $Placements,
        
        # Returns owned placements
        [Parameter()]
        [bool]
        $OwnedPlacements,

        # Return active group memberships
        [Parameter()]
        [bool]
        $GroupMemberships,

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
        $Properties,

        # Determines how the returned object should be prepared as a payload for the Egil API
		[Parameter()]
		[ValidateSet(
			"Organisation",
			"SchoolUnitGroup",
			"SchoolUnit",
			"Student",
            "StudentLookUp",
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
        
        $Payload = switch ($PSCmdlet.ParameterSetName) {
            Ids {
                Write-Host "inne i Payload/Ids" -ForegroundColor Green
                Format-RequestUrl -Action persons_lookup -PersonsLookup $Ids -Type ids
            }
            CivicNos {
                Format-RequestUrl -Action persons_lookup -PersonsLookup $CivicNos -Type civicNos
            }
        }

        # $ExpandAdded = $false

        if ($Properties) {
            foreach ($Property in $Properties) {
                if (-not ($Payload.Url -like '*?expand*')) {
                    $Payload.Url = $Payload.Url + "?expand=$Property"
                }
                else {
                    $Payload.Url = $Payload.Url + "&expand=$Property"
                }
            }
        }

        Write-Host $Payload.Url -ForegroundColor Blue

        try {
            $Response = Invoke-ISTAdminAPI -Payload $Payload -Method Post -ErrorAction Stop

            $Data = if ($APIReady) {
                Format-APICall -Property persons_lookup -InputObject $Response -APIReady $APIReady -ErrorAction Stop
            }
            else {
                Format-APICall -Property persons_lookup -InputObject $Response -ErrorAction Stop
            }
        }
        catch {
            Write-Error "Caught exception: $($_.Exception.Message) at $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    
    end {
        # return $Payload
        # return $Payload
        if ($Response) {
            return $Data
        }
        else {
            return $Payload
        } #>
    }
}
# End function.