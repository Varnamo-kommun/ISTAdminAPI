function Format-RequestUrl {

	[CmdletBinding()]

	param (
		# What type of API call that will be made
		[Parameter()]
		[ValidateSet(
			'organisations',
			'organisations_lookup',
			'organisations_id',
			'persons',
			'persons_lookup',
			'persons_id',
			'persons_relationship',
			'placements',
			'placements_lookup',
			'placements_id',
			'duties',
			'duties_lookup',
			'duties_id',
			'groups_lookup'
		)]
		[string]
		$Action,

		# Filter based on type. Allows multiple choices.
		[Parameter(
			ParameterSetName = "Org"
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
			ParameterSetName = "Org"
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

		# Name to search for in IST
		[Parameter(
			ParameterSetName = "Filter"
		)]
		[string]
		$Filter,

		# Social security number to search for
		[Parameter(
			ParameterSetName = "CivicNo"
		)]
		[string]
		$CivicNo,

		# Id of person to get
		[Parameter(
			ParameterSetName = "Id"
		)]
		[string]
		$Id,

		# Retrieve all children of parent Id
		[Parameter(
			ParameterSetName = "Id"
		)]
		[switch]
		$Parent,

		# Array of either social security numbers or id's.
		[Parameter(
			ParameterSetName = "Lookup"
		)]
		[System.Object]
		$PersonsLookup,

		#
		[Parameter()]
		[ValidateSet(
			'ids',
			'civicNos'
		)]
		[string]
		$Type,

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

		# Properties to include in the API call
		[Parameter(
			ParameterSetName = "Properties"
		)]
		[System.Object]
		$Properties,

		# Properties to expand when retrieving duties in the API call (Get-ISTDuty).
		[Parameter(
			ParameterSetName = "DutyRole"
		)]
		[System.Object]
		$DutyProperties,

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

		# Organisation Id to retrieve duties from
		[Parameter()]
		[string]
		$Organisation
	)
	
	begin {

	}
	
	process {
		$Url = switch ($Action) {
			organisations {

				if ($OrgType -and $SchoolType) {
					$First = $true
					[string]$Url = ""

					foreach ($OType in $OrgType) {
						if ($First) {
							$SpecialChar = ConvertFrom-SpecialCharacter -String $OrgType
							$Url = "$($ISTSettings.Server)/organisations?type=$SpecialChar"
							$First = $false
						}
						else {
							$SpecialChar = ConvertFrom-SpecialCharacter -String $OrgType
							$Url = $Url + "&type=$SpecialChar"
						}
					}

					foreach ($SType in $SchoolType) {
						$Url = $Url + "&schoolTypes=$SType"
					}

				}
				elseif ($OrgType) {
					$First = $true
					[string]$Url = ""
					foreach ($OType in $OrgType) {
						if ($First) {
							$SpecialChar = ConvertFrom-SpecialCharacter -String $OrgType
							$Url = "$($ISTSettings.Server)/organisations?type=$SpecialChar"
							$First = $false
						}
						else {
							$SpecialChar = ConvertFrom-SpecialCharacter -String $OrgType
							$Url = $Url + "&type=$SpecialChar"
						}
					}
				}

				$Url
			}
			organisations_lookup {}
			organisations_id {
				if ($Parent) {
					$UrlBase = "$($ISTSettings.Server)/organisations?parent=$Id"
					$UrlBase
					
				}
				else {
					$UrlBase = "$($ISTSettings.Server)/organisations/$Id"
					$UrlBase
				}
			}
			persons {
				$UrlBase = "$($ISTSettings.Server)/persons?"

				<# switch ($PSCmdlet.ParameterSetName) {
					Filter {
						if ($Filter.Contains(' ')) {
							$FilterSplit = $Filter.Split(' ')

							$Max = $FilterSplit.Count
							$Counter = 0

							$UrlPart = foreach ($string in $FilterSplit) {
								$Counter++

								if ($Counter -lt $Max) {
									"nameContains=$string&"
								}
								elseif ($Counter -eq $Max) {
									"nameContains=$string"
								}
							}

							$UrlPart = $UrlPart -join ''
						}
						else {
							$UrlPart = foreach ($string in $Filter) {
								"nameContains=$string"
							}
						}

						if ($Properties) {
							foreach ($Property in $Properties) {
								$UrlPart = $UrlPart + "&expand=$Property"
							}
						}

						$UrlBase+$(-join $UrlPart)
					}
					CivicNo {
						$UrlPart = "civicNo=$CivicNo"

						if ($Properties) {
							foreach ($Property in $Properties) {
								$UrlPart = $UrlPart + "&expand=$Property"
							}
						}

						$UrlBase + $UrlPart
					}
				} #>

				$PropArray = switch ($Properties.Keys) {
					NameContains {"&nameContains=$($Properties.NameContains)"}
					CivicNo {"&civicNo=$($Properties.CivicNo)"}
					Id {
						$UrlBase = "$($ISTSettings.Server)/persons/$($Properties.Id)"
						if ($Properties.ExpandProperties) {
							$UrlBase = $UrlBase + "?"
						}
					}
					RelationshipEntity {"&relationship.entity.type=$($Properties.RelationshipEntity)"}
					RelationshipOrganisation {"&relationship.organisation=$($Properties.RelationshipOrganisation)"}
					LookUp {}
					LookUpType {
						$LookUp = if ($Properties.ExpandProperties) {
							foreach ($LookUpExpand in $Properties.ExpandProperties) {
								if (-not $LookUpBuilder) {
									$LookUpBuilder = "?expand=$($LookUpExpand)"
								}
								else {
									$LookUpBuilder = $LookUpBuilder + "&expand=$($LookUpExpand)"
								}
							}

							[PSCustomObject]@{
								Url = "$($ISTSettings.Server)/persons/lookup" + $LookUpBuilder
								Data = [PSCustomObject]@{
									$($Properties.LookUpType) = $Properties.Lookup
								} | ConvertTo-Json
							}
						}
						else {
							[PSCustomObject]@{
								Url = "$($ISTSettings.Server)/persons/lookup"
								Data = [PSCustomObject]@{
									$($Properties.LookUpType) = $Properties.Lookup
								} | ConvertTo-Json
							}
						}
					}
					ExpandProperties {
						foreach ($Expand in $Properties.ExpandProperties) {
							"&expand=$($Expand)"
						}
					}
					StartDateOnOrAfter {"&relationship.startDate.onOrAfter=$($Properties.StartDateOnOrAfter)"}
					StartDateOnOrBefore {"&relationship.startDate.onOrBefore=$($Properties.StartDateOnOrBefore)"}
					EndDateOnOrAfter {"&relationship.endDate.onOrAfter=$($Properties.EndDateOnOrAfter)"}
					EndDateOnOrBefore {"&relationship.endDate.onOrBefore=$($Properties.EndDateOnOrBefore)"}
				}

				if ($LookUp) {
					$LookUp
				}
				else {
					foreach ($Property in $PropArray) {
						if (-not $StringBuilder) {
							$StringBuilder = $Property
						}
						else {
							$StringBuilder = $StringBuilder + $Property
						}
					}
	
					if ($Properties.ExpandProperties) {
						$UrlBase + $StringBuilder.TrimStart("&")
					}
					else {
						$UrlBase + $StringBuilder
					}
				}
			}
			persons_lookup {
				$UrlBase = "$($ISTSettings.Server)/persons/lookup"

				if ($Properties) {
					foreach ($Property in $Properties) {
						if (-not $StringBuilder) {
							$StringBuilder = "?expand=$Property"
						}
						else {
							$StringBuilder = $StringBuilder + "&expand=$Property"
						}
					}
					$UrlBase = $UrlBase + $StringBuilder
				}

				[PSCustomObject]@{
					Url = $UrlBase
					Data = [PSCustomObject]@{
						$Type = $PersonsLookup
					} | ConvertTo-Json
				}
			}
			persons_id {
				$UrlBase = "$($ISTSettings.Server)/persons/$Id"
				
				if ($Properties) {
					foreach ($Property in $Properties) {
						if (-not $StringBuilder) {
							$StringBuilder = "?expand=$Property"
						}
						else {
							$StringBuilder = $StringBuilder + "&expand=$Property"
						}
					}
					$UrlBase = $UrlBase + $StringBuilder
				}
				$UrlBase
			}
			persons_relationship {
				$UrlBase = "$($ISTSettings.Server)/persons?relationship.entity.type=$RelationshipEntity&relationship.organisation=$RelationshipOrganisation"

				if ($Properties) {
					foreach ($Property in $Properties) {
						$UrlBase = $UrlBase + "&expand=$Property"
					}
				}
				$UrlBase
			}
			placements {}
			placements_lookup {}
			placements_id {}
			duties {
				$UrlBase = "$($ISTSettings.Server)/duties?"

				$PropArray = switch ($Properties.Keys) {
					Organisation {"&organisation=$($Properties.Organisation)"}
					DutyRole {"&dutyRole=$($Properties.DutyRole)"}
					PersonId {"&person=$($Properties.PersonId)"}
					Id {
						$UrlBase = "$($ISTSettings.Server)/duties/$($Properties.Id)"
						if ($Properties.ExpandPerson) {
							$UrlBase = $UrlBase + "?"
						}
					}
					LookUp {
						$LookUp = if ($Properties.ExpandPerson) {
							$LookUpBuilder = "/lookup?expand=person"

							[PSCustomObject]@{
								Url = "$($ISTSettings.Server)/duties" + $LookUpBuilder
								Data = [PSCustomObject]@{
									ids = $Properties.LookUp
								} | ConvertTo-Json
							}
						}
						else {
							[PSCustomObject]@{
								Url = "$($ISTSettings.Server)/duties/lookup"
								Data = [PSCustomObject]@{
									ids = $Properties.Lookup
								} | ConvertTo-Json
							}
						}
					}
					ExpandPerson {"&expand=person"}
					StartDateOnOrAfter {"&startDate.onOrAfter=$($Properties.StartDateOnOrAfter)"}
					StartDateOnOrBefore {"&startDate.onOrBefore=$($Properties.StartDateOnOrBefore)"}
					EndDateOnOrAfter {"&endDate.onOrAfter=$($Properties.EndDateOnOrAfter)"}
					EndDateOnOrBefore {"&endDate.onOrBefore=$($Properties.EndDateOnOrBefore)"}
				}

				if ($LookUp) {
					$LookUp
				}
				else {
					foreach ($Property in $PropArray) {
						if (-not $StringBuilder) {
							$StringBuilder = $Property
						}
						else {
							$StringBuilder = $StringBuilder + $Property
						}
					}
	
					if ($Properties.ExpandPerson) {
						$UrlBase + $StringBuilder.TrimStart("&")
					}
					else {
						$UrlBase + $StringBuilder
					}
				}
				<# switch ($PSCmdlet.ParameterSetName) {
					DutyRole {
						# $SpecialChar = ConvertFrom-SpecialCharacter -String $DutyRole

						if ($Organisation) {
							[string]$Url = ""
							$First = $true

							foreach ($DR in $DutyRole) {
								if ($First) {
									$SpecialChar = ConvertFrom-SpecialCharacter -String $DR
									$Url = "$($ISTSettings.Server)/duties?organisation=$Organisation&dutyRole=$SpecialChar"
									$First = $false
								}
								else {
									$SpecialChar = ConvertFrom-SpecialCharacter -String $DR
									$Url = $Url + "&dutyRole=$SpecialChar"
								}
							}
							
							$Url = $Url + "&expand=person"

							# $UrlBase = "$($ISTSettings.Server)/duties?organisation=$Organisation&dutyRole=$SpecialChar&expand=person"
						}
						else {
							[string]$Url = ""
							$First = $true

							foreach ($DR in $DutyRole) {
								if ($First) {
									$SpecialChar = ConvertFrom-SpecialCharacter -String $DR
									$Url = "$($ISTSettings.Server)/duties?organisation=$Organisation&dutyRole=$SpecialChar"
									$First = $false
								}
								else {
									$SpecialChar = ConvertFrom-SpecialCharacter -String $DR
									$Url = $Url + "&dutyRole=$SpecialChar"
								}
							}
							
							$Url = $Url + "&expand=person"
							
							# $UrlBase = "$($ISTSettings.Server)/duties?dutyRole=$SpecialChar&expand=person"
						}
						
						$Url
					}
					Id {
						$UrlBase = "$($ISTSettings.Server)/duties?person=$Id&expand=person"
						$UrlBase
					}
				} #>
			}
			duties_lookup {}
			duties_id {}
			groups_lookup {
				[PSCustomObject]@{
					Url = "$($ISTSettings.Server)/groups/lookup"
					Data = [PSCustomObject]@{
						$Type = $PersonsLookup
					} | ConvertTo-Json
				}
			}
		}
	}
	
	end {
		return $Url
	}
}
# End function.