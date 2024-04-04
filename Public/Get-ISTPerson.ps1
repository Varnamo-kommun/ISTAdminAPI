function Get-ISTPerson {

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
		
		$RequestUrl = switch ($PSCmdlet.ParameterSetName) {
			NameContains {
				Format-RequestUrl -Action persons -Filter $NameContains
			}
			CivicNo {
				Format-RequestUrl -Action persons -CivicNo $CivicNo
			}
			Id {
				Format-RequestUrl -Action persons_id -Id $Id
				# Write-Host "Här var vi!" -ForegroundColor Green
			}
			Relationship {
				Format-RequestUrl -Action persons_relationship -RelationshipEntity $RelationshipEntity -RelationshipOrganisation $RelationshipOrganisation
			}
			LookUp {
				Format-RequestUrl -Action persons_lookup -PersonsLookup $LookUp -Type $LookUpType
				<# switch ($LookUpType) {
					Ids       {Format-RequestUrl -Action persons_lookup -PersonsLookup $LookUp -Type ids}
					CivicNos  {Format-RequestUrl -Action persons_lookup -PersonsLookup $LookUp -Type civicNos}
				} #>
			}
		}

		if ($ExpandProperties) {
			foreach ($Property in $ExpandProperties) {
				if (-not ($RequestUrl -like '*?expand*')) {
					if ($LookUp) {
						$RequestUrl.Url = $RequestUrl.Url + "?expand=$Property"
					}
					else {
						$RequestUrl = $RequestUrl + "?expand=$Property"
					}
				}
				else {
					if ($LookUp) {
						$RequestUrl.Url = $RequestUrl.Url + "&expand=$Property"
					}
					else {
						$RequestUrl = $RequestUrl + "&expand=$Property"
					}
				}
			}
		}

		try {
			$Response = if ($RequestUrl.Url) {
				Write-Host $RequestUrl -ForegroundColor Green
				Invoke-ISTAdminAPI -Payload $RequestUrl -Method POST -ErrorAction Stop
			}
			else {
				Invoke-ISTAdminAPI -RequestUrl $RequestUrl -Method GET -ErrorAction Stop
			}

			$Data = switch ($PSCmdlet.ParameterSetName) {
				NameContains {
					Format-APICall -Property persons -InputObject $Response -ErrorAction Stop
				}
				CivicNo {
					if ($APIReady) {
						Format-APICall -Property persons -InputObject $Response -APIReady -ErrorAction Stop
					}
					else {
						Format-APICall -Property persons -InputObject $Response -ErrorAction Stop
					}
				}
				Id {
					Format-APICall -Property persons_id -InputObject $Response -ErrorAction Stop
				}
				Relationship {
					if ($APIReady) {
						$Global:EgilSchoolUnits = Get-EgilSchoolUnit -All
						Format-APICall -Property persons_relationship -InputObject $Response -APIReady $APIReady -RelationshipOrganisation $RelationshipOrganisation -ErrorAction Stop
						Remove-Variable EgilSchoolUnits -Scope Global -Force
					}
					else {
						Format-APICall -Property persons_relationship -InputObject $Response -ErrorAction Stop
					}
				}
				LookUp {
					Format-APICall -Property persons_lookup -InputObject $Response -ErrorAction Stop
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
			return $RequestUrl
		}
		# return $Response
		# return $RequestUrl
	}
}
# End function.