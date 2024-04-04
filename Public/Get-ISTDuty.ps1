function Get-ISTDuty {

	[CmdletBinding()]

	param (
		# Organisation Id to retrieve duties from
		[Parameter()]
		[guid]
		$Organisation,

		# Type
		[Parameter(
			ParameterSetName = "DutyRole"
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
		
		$RequestUrl = if ($DutyRole) {
			if ($Organisation) {
				Format-RequestUrl -Action duties -DutyRole $DutyRole -Organisation $Organisation
			}
			else {
				Format-RequestUrl -Action duties -DutyRole $DutyRole
			}
		}
		else {
			Format-RequestUrl -Action duties
		}

		Write-Host $RequestUrl -ForegroundColor Green

		try {
			$Response = Invoke-ISTAdminAPI -RequestUrl $RequestUrl -Method Get -ErrorAction Stop
			
			$Data = if ($APIReady) {
				Format-APICall -Property duties -InputObject $Response -APIReady $APIReady -ErrorAction Stop
			}
			else {
				Format-APICall -Property duties -InputObject $Response -ErrorAction Stop
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
			return $RequestUrl
		}
	}
}
# End function.