function Get-ISTPerson {
	<#
	.SYNOPSIS
	Retrieve one or more person(s) from IST.

	.DESCRIPTION
	With this cmdlet you will be able to retrieve persons from the EduCloud API based on what information you feed the different parameters with.

	.PARAMETER NameContains
	Search filter. Based on the size of your organisation, this one might run slow.

	.PARAMETER CivicNo
	Retrieve a person based on the civic number

	.PARAMETER Id
	Retrieve a person based on the Id

	.PARAMETER RelationshipEntity
	When used in conjunction with the "RelationshipOrganisation" parameter, this parameter will let you filter out persons that has a specific relationship to a specific organisation.

	.PARAMETER RelationshipOrganisation
	Retrieve persons connected to one specific organsisation

	.PARAMETER LookUp
	Send an array of either ids or civic numbers to the API. When used, the "LookUpType" parameter becomes mandatory

	.PARAMETER LookUpType
	Specify what type of lookup you're doing. Either ids or civicnos

	.PARAMETER ExpandProperties
	Allows you to expand specific properties when retrieving persons. Allows for multiple choices.

	.EXAMPLE
	Get-ISTPerson -NameContains "Johan Johans" -ExpandProperties placements
	# This example will search your organisation for persons that match the search filter "Johan Johans". Persons will be retrieved that match both words. E.g. persons named "Johan Johansson" and "Johan Johanson" will be returned. Returned persons placements will also be returned.

	.EXAMPLE
	Get-ISTPerson -CivicNo "12345678xxxx" -ExpandProperties duties, responsibleFor
	# Here will spcify one specific persons civic number. We also say that we want that persons duties and the persons that are listed as having retrieved person as one of their responsibles.

	.EXAMPLE
	Get-ISTPerson -Id "7ff9d599-ff4e-4eb8-baba-0d5a7f55752a" -ExpandProperties groupMemberships
	# In this example we specify one specific id to retrieve along with that persons group memberships.

	.EXAMPLE
	Get-ISTPerson -RelationshipOrganisation "fa971b78-d804-49b5-a736-ed7d62138727" -RelationshipEntity duty
	# Here we retrieve all persons that has a duty at the specified organisation.

	.EXAMPLE
	$Today = Get-Date -Format "yyyy-MM-dd"
	Get-ISTPerson -RelationshipEntity duty -RelationshipOrganisation "2a00956d-18d9-41be-9621-b83ca92046ff" -StartDateOnOrBefore $today -EndDateOnOrAfter $today
	# Here we retrieve all persons that has a duty at the specified organisation that matches the start and end date filter provided.

	.EXAMPLE
	$LookUpIds = @(
		"55579f83-51ac-46fa-ad06-af6aa2a6d6be",
		"7b5995b7-c487-40c7-bcb6-b2ef81ff1b6d",
		"1862468d-b6d0-4fec-9147-df29c13ca847"
	)
	Get-ISTPerson -LookUp $LookUpIds -LookUpType ids -ExpandProperties duties, groupMemberships, responsibleFor, placements
	# In this example we send 3 different ids to the API and specify that we want to expand duties, groupMemberships, responsibleFor and placements

	.EXAMPLE
	$LookUpCivicNos = @(
		"12345678xxxx",
		"87654321xxxx",
	)
	Get-ISTPerson -LookUp $LookUpCivicNos -LookUpType civicNos
	# Here we send 2 different civic numbers to the API.

	.NOTES
	Author: Simon Mellergård | It-center, Värnamo kommun
	#>

	[CmdletBinding()]

	param (
		# Retrieve users based on your filter. Based on the size of your organisation, this one might run slow.
		[Parameter(
			ParameterSetName = "NameContains"
		)]
		[string]
		$NameContains,

		# Specific civic number of one person to retrieve
		[Parameter(
			ParameterSetName = "CivicNo"
		)]
		[string]
		$CivicNo,

		# Specific id of one person to retrieve.
		[Parameter(
			ParameterSetName = "Id"
		)]
		[string]
		$Id,

		# In conjunction with the "RelationshipOrganisation" parameter, this parameter filters out what persons with provided relationship entity
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

		# Send an array of either ids or civicnos to the API
		[Parameter(
			ParameterSetName = "LookUp"
		)]
		[string[]]
		$LookUp,

		# Type of look up (ids or civicNos)
		[Parameter(
			Mandatory = $true,
			ParameterSetName = "LookUp"
		)]
		[ValidateSet(
			"ids",
			"civicNos"
		)]
		[string]
		$LookUpType,

		# Properties to expand. Allows for multiple choices.
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

		#region Debugging section
		<# if ($RequestUrl.Url) {
			Write-Host $RequestUrl.Url -ForegroundColor Yellow
		}
		else {
			Write-Host $RequestUrl -ForegroundColor Yellow
		} #>
		#endregion Debugging section

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