function Get-ISTDuty {
	<#
	.SYNOPSIS
	Retrieve a duty from EduCloud

	.DESCRIPTION
	This cmdlet will help you retrieve one or more duties based on how you fill out the parameters.

	.PARAMETER Organisation
	Retrieve duties connected to a specific organisation.

	.PARAMETER DutyRole
	Only retrieve a specific type of duty

	.PARAMETER PersonId
	Retrieve all duties connected to a specific person

	.PARAMETER Id
	Retrieve a specific duty based on it's id.

	.PARAMETER LookUp
	Feed this parameter with a hashtable of duty id's to retrieve them from the API

	.PARAMETER ExpandPerson
	Switch parameter that will provide the person connected to the duty/duties that you retrieve

	.PARAMETER StartDateOnOrBefore
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same starting date or started before

	.PARAMETER StartDateOnOrAfter
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same starting date or starts after

	.PARAMETER EndDateOnOrBefore
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends before

	.PARAMETER EndDateOnOrAfter
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends before

	.EXAMPLE
	! Start filling out examples. Be sure to cover all scenarios. 2024-04-12

	.NOTES
	Author: Simon Mellergård | It-center, Värnamo kommun
	#>
	[CmdletBinding(
		DefaultParameterSetName = "Manual"
	)]

	param (
		# Organisation Id to retrieve duties from
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[guid]
		$Organisation,

		# Filter returned results based on duty role
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[ValidateSet(
			"Rektor",
			"Lärare",
			"Förskollärare",
			"Barnskötare",
			"Bibliotekarie",
			"Lärarassistent",
			"Fritidspedagog",
			"Annan personal",
			"Studie- och yrkesvägledare",
			"Förstelärare",
			"Kurator",
			"Skolsköterska",
			"Skolläkare",
			"Skolpsykolog",
			"Speciallärare/specialpedagog",
			"Skoladministratör",
			"Övrig arbetsledning",
			"Övrig pedagogisk personal",
			"Förskolechef"
		)]
		[string]
		$DutyRole,

		# Retrieve duties connected to one person
		[Parameter(
			ParameterSetName = "Manual"
		)]
		[guid]
		$PersonId,

		# Retrieve duties connected to one person
		[Parameter(
			ParameterSetName = "Id"
		)]
		[guid]
		$Id,

		#
		[Parameter(
			ParameterSetName = "LookUp"
		)]
		[guid[]]
		$LookUp,

		# Switch to determine whether to expand person connected to duty or not.
		[Parameter(ParameterSetName = "LookUp")]
		[Parameter(ParameterSetName = "Manual")]
		[Parameter(ParameterSetName = "Id")]
		[switch]
		$ExpandPerson,

		# Only retrieve duties that starts on or before provided date. Must be RFC3339 format
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

		# Only retrieve duties that starts on or before provided date
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

		# Only retrieve duties that starts on or before provided date
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

		# Only retrieve duties that starts on or before provided date
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

		$RequestUrl = Format-RequestUrl -Action duties -Properties $PSBoundParameters
		
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
			# return $Response
		}
		else {
			# return $RequestUrl
			return $RequestUrl
		}
	}
}
# End function.