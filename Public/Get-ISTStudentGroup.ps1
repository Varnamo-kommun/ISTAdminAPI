function Get-ISTStudentGroup {

    [CmdletBinding()]

    param (
        # Parameter help description
        [Parameter()]
        [guid]
        $Id,

        # Type of group returned
        [Parameter()]
        [ValidateSet(
            "Undervisning",
            "Klass",
            "Mentor",
            "Provgrupp",
            "Schema",
            "Avdelning",
            "Personalgrupp",
            "Övrigt"
        )]
        [string[]]
        $GroupType,

        # Retrieve all children of parent Id
        [Parameter()]
        [guid]
        $Parent,

        # SchoolType
        [Parameter()]
        [string]
        $SchoolType,

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

        $CurrentDate = Get-Date -Format yyyy-MM-dd
    }
    
    process {

        if ($Id) {
            $Uri = "/$($Id)?expand=assignmentRoles"
        }

        if ($GroupType) {
            $Counter = 1
            $Uri = foreach ($Type in $GroupType) {
                if ($Counter -eq 1) {
                    "?groupType=$Type"
                }
                else {
                    "&groupType=$Type"
                }

                $Counter++
            }

            if ($Uri.count -gt 1) {
                $Uri = $Uri -join ""
            }
        }

        if ($Parent) {
            if ($Uri) {
                $Uri = $Uri + "&organisation=$Parent"
            }
            else {
                $Uri = "?organisation=$Parent"
            }
        }

        if ($Id) {
            $RequestString = "$($ISTSettings.Server)/groups$($Uri)&startDate.onOrBefore=$CurrentDate&endDate.onOrAfter=$CurrentDate"
        }
        else {
            $RequestString = "$($ISTSettings.Server)/groups$($Uri)&startDate.onOrBefore=$CurrentDate&endDate.onOrAfter=$CurrentDate"
        }
        
        try {
            Write-Host $RequestString -ForegroundColor Green
            $Response = Invoke-ISTAdminAPI -RequestUrl $RequestString -Method GET -ErrorAction Stop

            $Data = if ($APIReady) {
                if ($SchoolType) {
                    Format-APICall -Property groups -InputObject $Response -SchoolType $SchoolType -APIReady $APIReady -ErrorAction Stop
                }
                else {
                    Format-APICall -Property groups -InputObject $Response -APIReady $APIReady -ErrorAction Stop
                }
            }
            else {
                Format-APICall -Property groups -InputObject $Response -ErrorAction Stop
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