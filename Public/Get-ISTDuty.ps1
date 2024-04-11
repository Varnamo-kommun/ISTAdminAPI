function Get-ISTDuty {

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