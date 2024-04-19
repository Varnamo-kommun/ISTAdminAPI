function Get-ISTGroup {
    <#
    .SYNOPSIS
    Retrieve group(s)

    .DESCRIPTION
    This cmdlet will let you retrieve one or more groups from EduCloud based on what information the parameters are feed with.

    .PARAMETER GroupType
    Filter groups on what type of group.

    .PARAMETER SchoolType
    Filter groups on what type of school it is.

    .PARAMETER Parent
    Retrieve all groups connected to specified organisation.

    .PARAMETER Id
    Retrieve one specific group based on it's id

    .PARAMETER LookUp
    Send an array of group ids to the API. This is useful when you need to retrieve many groups and don't want to loop with the Id parameter.

    .PARAMETER ExpandAssignmentRole
    Whether or not to retrieve assignment role connected to the group(s)

	.PARAMETER StartDateOnOrBefore
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same starting date or started before

	.PARAMETER StartDateOnOrAfter
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same starting date or starts after

	.PARAMETER EndDateOnOrBefore
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends before

	.PARAMETER EndDateOnOrAfter
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends after

    .EXAMPLE
    Get-ISTGroup -GroupType Klass
    # In this example, you will retrieve all groups where group type match "Klass". Note that depending on your organisation this might take a while.

    .EXAMPLE
    Get-ISTGroup -GroupType Undervisning -Parent "90000a8a-e63c-4b67-9626-7092a04eddb9"
    # This example will retrieve all groups where group type match "Undervisning" and are connected to specified organisation id.

    .EXAMPLE
    Get-ISTGroup -Parent "5237567b-06fd-4986-8aff-3806e611d82d"
    # Here you will retrieve all groups that are connected to specified organisation id.

    .EXAMPLE
    Get-ISTGroup -Id "caeb3b49-a29e-4ab2-9321-8a8a2ff66489" -ExpandAssignmentRole
    # This example will retrieve one specific group along with, if there are any, expanded assignment role.

    .EXAMPLE
    $GroupIds = @(
        "15d05368-563c-4d6a-88c2-d136dfd12eff",
        "8ab63dc9-8069-4442-b046-d226275acc5a",
        "dd1a17f6-845e-4bce-a958-b8570356abe9"
    )
    Get-ISTGroup -LookUp $GroupIds -ExpandAssignmentRole
    # This example is useful when you need to retrieve many groups with specific ids so you don't need to loop through the Id parameter.

    .EXAMPLE
    $Today = Get-Date -Format "yyyy-MM-dd"
    Get-ISTGroup -GroupType Undervisning -StartDateOnOrBefore $Today -EndDateOnOrAfter $Today
    # This example will retrieve all groups in your organisation that matches group type "Undervisning" and also filter out groups that meet the start/end date critera provided.

    .NOTES
    Author: Simon Mellergård | It-center, Värnamo kommun
    #>
    [CmdletBinding(DefaultParameterSetName = "Manual")]

    param (
        # Type of group returned. Multiple types supported
        [Parameter(
            ParameterSetName = "Manual"
        )]
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

        # Retrieve all groups from parent organisation. Allows multiple ids
        [Parameter(
            ParameterSetName = "Manual"
        )]
        [guid[]]
        $Parent,

        # Fetch one specific group based on it's id.
        [Parameter(
            ParameterSetName = "Id"
        )]
        [guid]
        $Id,

        # Send an array of ids to the API.
		[Parameter(
			ParameterSetName = "LookUp"
		)]
		[guid[]]
		$LookUp,

        # Switch to determine whether to expand connected assignment role or not.
		[Parameter(ParameterSetName = "LookUp")]
		[Parameter(ParameterSetName = "Manual")]
		[Parameter(ParameterSetName = "Id")]
		[switch]
		$ExpandAssignmentRole,

        # Only retrieve groups that starts on or before provided date. Must be RFC3339 format
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[ValidateScript({
			if (-not ($_ -match "^(\d{4}-\d{2}-\d{2})$")) {
				throw $_.Exception.Message
			}
			else {
				return $true
			}
		})]
		[string]
		$StartDateOnOrBefore,

		# Only retrieve groups that starts on or before provided date
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[ValidateScript({
			if (-not ($_ -match "^(\d{4}-\d{2}-\d{2})$")) {
				throw $_.Exception.Message
			}
			else {
				return $true
			}
		})]
		[string]
		$StartDateOnOrAfter,

		# Only retrieve groups that starts on or before provided date
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[ValidateScript({
			if (-not ($_ -match "^(\d{4}-\d{2}-\d{2})$")) {
				throw $_.Exception.Message
			}
			else {
				return $true
			}
		})]
		[string]
		$EndDateOnOrBefore,

		# Only retrieve groups that starts on or before provided date
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[ValidateScript({
			if (-not ($_ -match "^(\d{4}-\d{2}-\d{2})$")) {
				throw $_.Exception.Message
			}
			else {
				return $true
			}
		})]
		[string]
		$EndDateOnOrAfter
    )
    
    begin {
        if (Confirm-NeedNewAccessToken) {
            Get-AccessToken -Credential $(Get-Secret -LiteralPath $ISTSettings.ClientAuthorizationPath)
        }
    }
    
    process {
        $RequestUrl = Format-RequestUrl -Action groups -Properties $PSBoundParameters

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