function Get-ISTPerson {
	<#
	.SYNOPSIS
	Retrieve one or more person(s) from IST.

	.DESCRIPTION
	Long description

	.PARAMETER NameContains
	Parameter description

	.PARAMETER CivicNo
	Parameter description

	.PARAMETER Id
	Parameter description

	.PARAMETER RelationshipEntity
	Parameter description

	.PARAMETER RelationshipOrganisation
	Parameter description

	.PARAMETER LookUp
	Parameter description

	.PARAMETER LookUpType
	Parameter description

	.PARAMETER ExpandProperties
	Parameter description

	.EXAMPLE
	An example

	.NOTES
	Author: Simon Mellergård | It-center, Värnamo kommun
	#>

	[CmdletBinding()]

	param (
		# Filter on multiple users
		[Parameter(
			ParameterSetName = "NameContains"
		)]
		[string]
		$NameContains,

		# SSN of a user
		[Parameter(
			ParameterSetName = "CivicNo"
		)]
		[string]
		$CivicNo,

		# Id of persons to get
		[Parameter(
			ParameterSetName = "Id"
		)]
		[string]
		$Id,

		# Type of relationship entity
		[Parameter(
			ParameterSetName = "Relationship"
		)]
		[ValidateSet(
			"enrolment",
			"duty",
			"placement.child",
			"placement.owner",
			"responsibleFor.enrolment",
			"responsibleFor.placement",
			"groupMembership"
		)]
		[string]
		$RelationshipEntity,

		# Id of organisation that the person has a relationship to.
		[Parameter(
			ParameterSetName = "Relationship"
		)]
		[guid]
		$RelationshipOrganisation,

		# Parameter help description
		[Parameter(
			ParameterSetName = "LookUp"
		)]
		[string[]]
		$LookUp,

		# Type of look up (ids or civicNos)
		[Parameter(
			ParameterSetName = "LookUp"
		)]
		[ValidateSet(
			"ids",
			"civicNos"
		)]
		[string]
		$LookUpType,

		# Properties to expand
		[Parameter()]
		[ValidateSet(
			"duties",
			"responsibleFor",
			"placements",
			"ownedPlacements",
			"groupMemberships"
		)]
		[string[]]
		$ExpandProperties,

		# Only retrieve duties that starts on or before provided date. Must be RFC3339 format
		[Parameter(
			ParameterSetName = "Relationship"
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

		# Only retrieve duties that starts on or before provided date
		[Parameter(
			ParameterSetName = "Relationship"
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

		# Only retrieve duties that starts on or before provided date
		[Parameter(
			ParameterSetName = "Relationship"
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

		# Only retrieve duties that starts on or before provided date
		[Parameter(
			ParameterSetName = "Relationship"
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

		$RequestUrl = Format-RequestUrl -Action persons -Properties $PSBoundParameters

		if ($RequestUrl.Url) {
			Write-Host $RequestUrl.Url -ForegroundColor Yellow
		}
		else {
			Write-Host $RequestUrl -ForegroundColor Yellow
		}

		try {
			$Response = if ($RequestUrl.Url) {
				Invoke-ISTAdminAPI -Payload $RequestUrl -Method POST -ErrorAction Stop
			}
			else {
				Invoke-ISTAdminAPI -RequestUrl $RequestUrl -Method GET -ErrorAction Stop
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