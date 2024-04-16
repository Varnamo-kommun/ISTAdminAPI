function Format-RequestUrl {

	[CmdletBinding()]

	param (
		# What type of API call that will be made
		[Parameter()]
		[ValidateSet(
			'organisations',
			'persons',
			'placements',
			'duties',
			'groups_lookup'
		)]
		[string]
		$Action,

		# Properties to include in the API call
		[Parameter()]
		[System.Object]
		$Properties
	)
	
	begin {

	}
	
	process {
		$Url = switch ($Action) {
			organisations {
				$UrlBase = "$($ISTSettings.Server)/organisations?"

				$PropArray = switch -Wildcard ($Properties.Keys) {
					OrgType    {
						foreach ($OrgType in $Properties.OrgType) {
							if ($OrgType -match "[åäö]+") {
								[string]$TmpString = $OrgType
								"&type=$(ConvertFrom-SpecialCharacter -String $TmpString)"
							}
							else {
								"&type=$OrgType"
							}
						}
					}
					SchoolType {
						foreach ($SchoolType in $Properties.SchoolType) {
							"&schoolTypes=$SchoolType"
						}
					}
					Id         {
						"$($ISTSettings.Server)/organisations/$($Properties.Id)"
					}
					Parent     {
						foreach ($Parent in $Properties.Parent) {
							"&parent=$($Parent)"
						}
					}
					"LookUp_*" {
						if (-not $LookUpBuilder) {
							$TmpTable = @{}
							if ($Properties.LookUp_Ids) {
								$TmpTable | Add-Member -MemberType NoteProperty -Name ids -Value $Properties.LookUp_Ids
							}
							if ($Properties.LookUp_SchoolUnitCodes) {
								$TmpTable | Add-Member -MemberType NoteProperty -Name schoolUnitCodes -Value $Properties.LookUp_SchoolUnitCodes
							}
							if ($Properties.LookUp_OrganisationCodes) {
								$TmpTable | Add-Member -MemberType NoteProperty -Name organisationCodes -Value $Properties.LookUp_OrganisationCodes
							}
							
							$LookUpBuilder = [PSCustomObject]@{
								Url = "$($ISTSettings.Server)/organisations/lookup"
								Data = $TmpTable | ConvertTo-Json
							}

							$LookUpBuilder
						}
					}
				}

				if ($LookUpBuilder) {
					# $Properties.LookUp_Id -or $Properties.LookUp_SchoolUnitCodes -or $Properties.LookUp_OrganisationCodes -or $Properties.Id
					$LookUpBuilder
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
					
					$UrlBase + $StringBuilder.TrimStart("&")
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
			placements {}
			duties {
				$UrlBase = "$($ISTSettings.Server)/duties?"

				$PropArray = switch ($Properties.Keys) {
					Organisation {"&organisation=$($Properties.Organisation)"}
					DutyRole {
						if ($Properties.DutyRole -match "[\s-åäö]+") {
							"&dutyRole=$(ConvertFrom-SpecialCharacter -String $Properties.DutyRole)"
						}
						else {
							"&dutyRole=$($Properties.DutyRole)"
						}
					}
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