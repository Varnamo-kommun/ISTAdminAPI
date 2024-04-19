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
	Must be in RFC3339 format - Will only retrieve duty/duties that either has the same ending date or ends after

	.EXAMPLE
	$Today = Get-Date -Format "yyyy-MM-dd"
	Get-ISTDuty -Organisation "f66c5203-4613-4655-91ce-487b1bfcd84e" -DutyRole Rektor -StartDateOnOrBefore $Today -EndDateOnOrAfter $Today
	# This example will retrieve all duties with the duty role "Rektor" that connected to the specified organisation. It will also filter out duties that don't match the provided start/end dates.

	.EXAMPLE
	Get-ISTDuty -PersonId "17e8cc3f-32b6-49a9-abc1-4f2c468cb71d"
	# This example will retrieve all duties connected to the specified person

	.EXAMPLE
	$DutyIds = @(
		"108f0e66-dadf-47b3-8c96-9122eebd141c",
		"dd181c39-c6c9-4d42-b2d7-86b66dcb6ad7",
		"f876453d-591f-4460-bd81-cd8b7a30a140",
		"1ad3aa60-b13d-4b5e-9dc5-e1f9c2deb9e0"
	)

	Get-ISTDuty -LookUp $DutyIds -ExpandPerson
	# This example will retrieve all four duties declared in $DutyIds and also get the connected person as an expandable object.

	.EXAMPLE
	Get-ISTDuty -DutyRole "Studie- och yrkesvägledare"
	# This example will retrieve all duties with the role "Studie- och yrkesvägledare" from your entire organisation.

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

		# Send an array of ids to the API.
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
		# Check to see if there exists an active access token. If it doesn't, one will be retrieved with information previously provided with the Initialize-SettingsFile cmdlet.
		if (Confirm-NeedNewAccessToken) {
			Get-AccessToken -Credential $(Get-Secret -LiteralPath $ISTSettings.ClientAuthorizationPath)
		}
	}

	process {
		# Format the request string based on what parameters used.
		$RequestUrl = Format-RequestUrl -Action duties -Properties $PSBoundParameters
		
		#region Debugging section
		<# if ($RequestUrl.Url) {
			Write-Host $RequestUrl.Url -ForegroundColor Yellow
		}
		else {
			Write-Host $RequestUrl -ForegroundColor Yellow
		} #>
		#endregion Debugging section

		# Try/Catch section that either sends a request string or a json payload based on what parameters used to the EduCloud API
		try {
			# Determine whether to send a payload or request string
			$Response = if ($RequestUrl.Url) {
				# Send the actual payload to the API
				Invoke-ISTAdminAPI -Payload $RequestUrl -Method POST -ErrorAction Stop
			}
			else {
				# Send the request string to the API
				Invoke-ISTAdminAPI -RequestUrl $RequestUrl -Method GET -ErrorAction Stop
			}

			# Converts the response from json into objects. Removes the "data" container object when the response is returned with it.
			$Data = Format-APICall -InputObject $Response -ErrorAction Stop
		}
		catch {
			Write-Error "Caught exception: $($_.Exception.Message) at $($_.InvocationInfo.ScriptLineNumber)"
		}
	}
	
	end {
		if ($Response) {
			# Return the formatted object(s)
			return $Data
		}
		else {
			# For debbuging purposes
			return $RequestUrl
		}
	}
}
# End function.