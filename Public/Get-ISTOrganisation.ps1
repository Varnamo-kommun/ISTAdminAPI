function Get-ISTOrganisation {

    [CmdletBinding()]
    
    param (

        # Filter based on type. Allows multiple choices.
        [Parameter(
            ParameterSetName = "Manual"
        )]
        [ValidateSet(
            "Huvudman",
            "Verksamhetsområde",
            "Förvaltning",
            "Rektorsområde",
            "Skola",
            "Skolenhet",
            "Varumärke",
            "Bolag",
            "Övrigt"
        )]
        [string[]]
        $OrgType,

        # Filter based on school type. Allows multiple choices.
        [Parameter(
            ParameterSetName = "Manual"
        )]
        [ValidateSet(
            "FS",
            "FKLASS",
            "FTH",
            "OPPFTH",
            "GR",
            "GRS",
            "TR",
            "SP",
            "SAM",
            "GY",
            "GYS",
            "VUX",
            "VUXSFI",
            "VUXGR",
            "VUXGY",
            "VUXSARGR",
            "VUXSARTR",
            "VUXSARGY",
            "SFI",
            "SARVUX",
            "SARVUXGR",
            "SARVUXGY",
            "KU",
            "YH",
            "FHS",
            "STF",
            "KKU",
            "HS",
            "ABU",
            "AU"
        )]
        [string[]]
        $SchoolType,

        # Parameter help description
        [Parameter(
            ParameterSetName = "Id"
        )]
        [string]
        $Id,

        # Retrieve all children of parent Id
        [Parameter(
            ParameterSetName = "Id"
        )]
        [switch]
        $Parent,

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

        $RequestString = switch ($PSCmdlet.ParameterSetName) {
            Id {
                if ($Parent) {
                    Format-RequestUrl -Action organisations_id -Id $Id -Parent
                }
                else {
                    Format-RequestUrl -Action organisations_id -Id $Id
                }
            }
            Manual {
                if ($OrgType -and $SchoolType) {
                    Format-RequestUrl -Action organisations -OrgType $OrgType -SchoolType $SchoolType
                }
                elseif ($OrgType) {
                    Format-RequestUrl -Action organisations -OrgType $OrgType
                }
                elseif ($SchoolType) {
                    Format-RequestUrl -Action organisations -SchoolType $SchoolType
                }
            }
        }

        # Write-Host $RequestString -ForegroundColor Magenta

        try {
            $Response = Invoke-ISTAdminAPI -RequestUrl $RequestString -Method GET -ErrorAction Stop

            $Data = switch ($PSCmdlet.ParameterSetName) {
                Id {
                    if ($APIReady) {
                        if ($Parent) {
                            Format-APICall -Property organisations_id -InputObject $Response -APIReady $APIReady -Parent -ErrorAction Stop
                        }
                        else {
                            Format-APICall -Property organisations_id -InputObject $Response -APIReady $APIReady -ErrorAction Stop
                        }
                    }
                    else {
                        if ($Parent) {
                            Format-APICall -Property organisations_id -InputObject $Response -Parent -ErrorAction Stop
                        }
                        else {
                            Format-APICall -Property organisations_id -InputObject $Response -ErrorAction Stop
                        }
                    }
                }
                Manual {
                    if ($APIReady) {
                        Format-APICall -Property organisations -InputObject $Response -APIReady $APIReady -ErrorAction Stop
                    }
                    else {
                        Format-APICall -Property organisations -InputObject $Response -ErrorAction Stop
                    }
                }
            }
        }
        catch {
            # Write-Error $_.Exception.Message
            # Get-Info
            Write-Error "Caught exception: $($_.Exception.Message) at $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    
    end {
        if ($Response) {
            return $Data
        }
        else {
            return $RequestString
        }
    }
}
# End function.