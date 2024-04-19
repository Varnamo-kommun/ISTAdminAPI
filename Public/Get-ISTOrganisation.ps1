function Get-ISTOrganisation {
    <#
    .SYNOPSIS
    Retrieve an organisation

    .DESCRIPTION
    With this cmdlet you will be able to retrieve your organisations in a couple of different ways.

    .PARAMETER OrgType
    Retrieve organisations based on what type of organisation it is. Accepts values from a predefined list of strings. It's possible to feed the parameter with more than one value.

    .PARAMETER SchoolType
    Retrieve organisations based on what type of school it is. Accepts values from a predefined list of strings. It's possible to feed the parameter with more than one value.

    .PARAMETER Id
    Retrieve one specific organisation based on it's id.

    .PARAMETER Parent
    Retrieve organisations connected to provided id. It is possible to feed the parameter with multiple values.

    .PARAMETER LookUp_Ids
    With this parameter will let you send an object to the API containing multiple ids of organisations that you want to retrieve.

    .PARAMETER LookUp_SchoolUnitCodes
    With this parameter will let you send an object to the API containing multiple schoolUnitCodes of organisations that you want to retrieve.

    .PARAMETER LookUp_OrganisationCodes
    With this parameter will let you send an object to the API containing multiple organisationCodes of organisations that you want to retrieve.

    .EXAMPLE
    Get-ISTOrganisation -OrgType Huvudman
    # In this example you will retrieve your principal organisation.

    .EXAMPLE
    Get-ISTOrganisation -SchoolType GY
    # This example will retrieve all organisations with the schoolType GY.

    .EXAMPLE
    Get-ISTOrganisation -Id "24445547-9278-4c5a-ac0d-78cc6bf487a3"
    # Retrieve one specific organisation.

    .EXAMPLE
    Get-ISTOrganisation -Parent "874a3d02-25ff-4a32-b1d3-f03583f6e071"
    # Retrieve all organisations that has provided id as their parent organisation.

    .EXAMPLE
    Get-ISTOrganisation -Parent @("e95350b8-e162-41bd-b914-e162733f15e1", "71d2f3e2-ad74-4c22-81cc-c43eccd91dfc")
    # Retrieve organisations from multiple parent organisations.

    .EXAMPLE
    Get-ISTOrganisation -LookUp_Ids @("071546fb-5d2b-4905-b29a-fd2f46ea0c51", "bfd49638-c7e5-465c-8658-f6eaf0aa380f")
    # Send one post to the API containing multiple ids to retrieve.

    .NOTES
    Author: Simon Mellergård | It-center, Värnamo kommun
    #>
    [CmdletBinding(DefaultParameterSetName = "Manual")]
    
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

        # Id of the organisation to retrieve
        [Parameter(
            ParameterSetName = "Id"
        )]
        [guid]
        $Id,

        # Retrieve all children of parent Id
        [Parameter(
            ParameterSetName = "Manual"
        )]
        [guid[]]
        $Parent,

        # Send an array of ids instead of looping with the Id-parameter
        [Parameter(
            ParameterSetName = "LookUp",
            ValueFromPipeline = $true
        )]
        [guid[]]
        $LookUp_Ids,

        # Send an array of school unit codes to the API
        [Parameter(
            ParameterSetName = "LookUp"
        )]
        [string[]]
        $LookUp_SchoolUnitCodes,

        # Send an array of organisation codes to the API
        [Parameter(
            ParameterSetName = "LookUp"
        )]
        [string[]]
        $LookUp_OrganisationCodes
    )
    
    begin {
        if (Confirm-NeedNewAccessToken) {
            Get-AccessToken -Credential $(Get-Secret -LiteralPath $ISTSettings.ClientAuthorizationPath)
        }
    }
    
    process {
        $RequestUrl = Format-RequestUrl -Action organisations -Properties $PSBoundParameters

        #region Debugging section
		<# if ($RequestUrl.Url) {
			Write-Host $RequestUrl.Url -ForegroundColor Yellow
		}
		else {
			Write-Host $RequestUrl -ForegroundColor Yellow
		} #>
		#endregion Debugging section

        try {
            if ($PSCmdlet.ParameterSetName -eq "LookUp") {
                $Response = Invoke-ISTAdminAPI -Payload $RequestUrl -Method POST -ErrorAction Stop
            }
            else {
                $Response = Invoke-ISTAdminAPI -RequestUrl $RequestUrl -Method GET -ErrorAction Stop
            }

            $Data = Format-APICall -InputObject $Response -ErrorAction Stop
        }
        catch {
            Write-Error "Caught exception: $($_.Exception.Message) at $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    
    end {
        if ($Response) {
            return $Data
        }
        else {
            return $RequestUrl
        }
    }
}
# End function.