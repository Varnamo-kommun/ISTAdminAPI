function Format-APICall {

	[CmdletBinding()]

	param (
		# Property to be used
		[Parameter(Mandatory = $true)]
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
			'groups',
			'groups_lookup'
		)]
		[string]
		$Property,

		# Input object to be parsed and formatted.
		[Parameter()]
		[Microsoft.PowerShell.Commands.HtmlWebResponseObject]
		$InputObject,

		# SchoolType
        [Parameter()]
        [string]
        $SchoolType,

		# Determines how the returned object should be prepared as a payload for the Egil API
		[Parameter()]
		[ValidateSet(
			"Organisation",
			"SchoolUnitGroup",
			"SchoolUnit",
			"Student",
			"StudentLookUp",
			"StudentMemberShip",
			"StudentGroup",
			"TeacherRole",
			"Employment",
			"Teacher"
		)]
		[string]
		$APIReady,

		# Retrieve all children of parent Id
		[Parameter()]
		[switch]
		$Parent,

		# Id of organisation that the person has a relationship to.
		[Parameter()]
		[guid]
		$RelationshipOrganisation
	)

	begin {
		# $Cred = Get-Credential
		$UTF8 = [System.Text.Encoding]::UTF8.GetString($InputObject.Content.ToCharArray())
	}

	process {

		$Result = switch ($Property) {
			organisations {
				$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
			}
			organisations_lookup {}
			organisations_id {
				if ($Parent) {
					$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
				}
				else {
					$UTF8 | ConvertFrom-Json
				}
			}
			persons {
				$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
			}
			persons_lookup {
				$UTF8 | ConvertFrom-Json
			}
			persons_id {
				$UTF8 | ConvertFrom-Json
			}
			persons_relationship {
				$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
			}
			placements {}
			placements_lookup {}
			placements_id {}
			duties {
				$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
			}
			duties_lookup {}
			duties_id {}
			groups {
				$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
				
				<# if ($UTF8.data) {
					$UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data
				}
				else {
					$UTF8 | ConvertFrom-Json
				} #>
			}
			groups_lookup {
				$UTF8 | ConvertFrom-Json
			}
		}

		$Final = if ($APIReady) {
			switch ($APIReady) {
				{$_ -eq 'Organisation' -or $_ -eq 'SchoolUnitGroup'} {
					#region 1
					# $ThrowAwayVar = $UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data

					foreach ($item in $Result) {
						[PSCustomObject]@{
							externalId  = $item.id
							displayName = $item.displayName
							<# schoolUnit  = [PSCustomObject]@{
								externalId      = $item.id
								displayName     = $item.displayName
								schoolUnitCode  = $item.schoolUnitCode
								organisation    = Get-MunicipalityId
								schoolUnitGroup = $item.parentOrganisation.id
								schoolType      = $item.schoolTypes -join ""
							} #>
						}
					}

					#endregion 1
				}
				SchoolUnit {
					# $ThrowAwayVar = $UTF8 | ConvertFrom-Json

					foreach ($item in $Result) {
						[PSCustomObject]@{
							externalId      = $item.id
							displayName     = $item.displayName
							schoolUnitCode  = $item.schoolUnitCode
							organisation    = Get-MunicipalityId
							schoolUnitGroup = $item.parentOrganisation.id
							schoolType      = $item.schoolTypes -join ""
						}
					}
				}
				Student {
					$ThrowAwayVar = $UTF8 | ConvertFrom-Json | Select-Object -ExpandProperty data

					# Setting parameters for the aduser call
					$ADParams = @{
						Filter = "vkPnr12 -eq '$($ThrowAwayVar.civicNo.value)'"
						Properties = @(
							"mail",
							"vkePPN"
						)
						Credential = $Cred
						ErrorAction = "Stop"
					}

					# Retrieving the aduser properties
					$ADUser = Get-ADUser @ADParams | Select-Object $ADParams.Properties

					# Current date in a variable used to filter out persons past and future enrolments and groupmemberships
					$CurrentDate = Get-Date -Format yyyy-MM-dd

					# Filter out enrolments
					$SchoolInfo = foreach ($item in $ThrowAwayVar.enrolments) {
						if ($item.startDate -le $CurrentDate -and $item.endDate -ge $CurrentDate) {
							$item
						}
					}

					# Filter out group memberships
					$GroupMemberships = foreach ($Group in $ThrowAwayVar._embedded.groupMemberships) {
						if ($Group.startDate -le $CurrentDate -and $Group.endDate -ge $CurrentDate) {
							$Group
						}
					}

					# Creating the Egil API-ready payload.
					[PSCustomObject]@{
						externalId  = $ThrowAwayVar.id
						userName    = $ADUser.vkePPN # EPPN
						displayName = "$($ThrowAwayVar.givenName) $($ThrowAwayVar.familyName)" # Givenname + Surname
						givenName   = $ThrowAwayVar.givenName
						familyName  = $ThrowAwayVar.givenName
						email       = $ADUser.mail # Get email from AD
						schoolYear  = $SchoolInfo.schoolYear
						schoolType  = $SchoolInfo.schoolType
						schoolUnit  = $SchoolInfo.enroledAt.id
						programCode = $SchoolInfo.educationCode
						ssn         = $ThrowAwayVar.civicNo.value
						studentMemberships = foreach ($Membership in $GroupMemberships.group) {
							@{
								studentId      = $ThrowAwayVar.id
								studentGroupId = $Membership.id
								owner          = $Membership.organisation.id
							}
						}
					}
				}
				StudentLookUp {

					# Current date in a variable used to filter out persons past and future enrolments
					$CurrentDate = Get-Date -Format yyyy-MM-dd

					# Setting parameters for the aduser call
					$ADParams = @{
						Filter = "DisplayName -like '*- Elev'"
						Properties = @(
							"Enabled",
							"mail",
							"vkePPN",
							"vkPNR12"
						)
						Credential = $Cred
						ErrorAction = "Stop"
					}

					# Retrieving the aduser properties
					$AllADStudents = Get-ADUser @ADParams | Select-Object $ADParams.Properties

					foreach ($Student in $Result) {

						if ($Student.civicNo.value -in $AllADStudents.vkPNR12) {
							# Declare variable with AD information on current student.
							$StudentADObject = $AllADStudents | Where-Object {$_.vkPNR12 -eq $Student.civicNo.value}

							# Filter out enrolments
							$SchoolInfo = foreach ($Enrolment in $Student.enrolments) {
								if ($Enrolment.startDate -le $CurrentDate -and $Enrolment.endDate -ge $CurrentDate) {
									$Enrolment
								}
							}

							# Filter out group memberships
							$GroupMemberships = foreach ($Group in $Student._embedded.groupMemberships) {
								if ($Group.startDate -le $CurrentDate -and $Group.endDate -ge $CurrentDate) {
									$Group
								}
							}

							if ($SchoolInfo -and $GroupMemberships -and ($StudentADObject.Enabled -eq $true)) {

								[string]$SchoolYear = if (-not ($SchoolInfo.schoolYear)) {
									$null
								}
								else {
									$SchoolInfo.schoolYear
								}

								# Creating the Egil API-ready payload.
								try {
									[PSCustomObject]@{
										externalId  = $Student.id
										userName    = $StudentADObject.vkePPN # EPPN
										displayName = "$($Student.givenName) $($Student.familyName)" # Givenname + Surname
										givenName   = $Student.givenName
										familyName  = $Student.familyName
										email       = $StudentADObject.mail # Get email from AD
										schoolYear  = $SchoolYear
										schoolType  = $SchoolInfo.schoolType
										schoolUnit  = $SchoolInfo.enroledAt.id
										programCode = $SchoolInfo.educationCode
										ssn         = $Student.civicNo.value
										studentMemberships = foreach ($Membership in $GroupMemberships.group) {
											@{
												studentId      = $Student.id
												studentGroupId = $Membership.id
												owner          = $Membership.organisation.id
											}
										}
									}
								}
								catch {
									Write-Host "$($Student.id) failed: $($_.Exception.Message)" -ForegroundColor Yellow
								}

								Remove-Variable -Name SchoolInfo, GroupMemberships, StudentADObject -Force
							}
						}
					}
				}
				StudentMemberShip {}
				StudentGroup {
					if ($SchoolType) {
						foreach ($item in $Result) {
							#! Tries to split mixed student groups into single ones. Failed on the need to generate unique student groups per constructedName
							<#  if ($item.Split("/")[0] -like '*-*') {
								$Range = $($item.Split("/")[0] -replace "[A-Ö]", "").Split("-")
								$Numbers = for ([int]$i = $range[0]; $i -le [int]$Range[1]; $i++) {
									$i
								}

								$Letters = $item.Split("/")[0] -replace "[0-9,-]", ""
							} #>
							[PSCustomObject]@{
								externalId       = $item.id
								displayName      = $item.displayName
								owner            = $item.organisation.id
								studentGroupType = $item.groupType
								schoolType       = $SchoolType
								constructedName  = New-ConstructedName -String $item.displayName -SchoolType $SchoolType
							}
						}
					}
					else {
						foreach ($item in $Result) {
							[PSCustomObject]@{
								externalId       = $item.id
								displayName      = $item.displayName
								owner            = $item.organisation.id
								studentGroupType = $item.groupType
							}
						}
					}
				}
				TeacherRole {}
				Employment {}
				Teacher {
					$CheckSchoolUnits = Get-EgilSchoolUnit -All
					foreach ($item in $Result) {

						if (-not ($item.id -eq "fa026e5b-b0cc-4f38-8b05-dc0bfe912026")) {

							$ADParams = @{
								Filter = "vkPnr12 -eq '$($item.civicNo.value)' -and mail -notlike '*politiker*'"
								Properties = @(
									"mail",
									"vkePPN"
								)
								Credential = $Cred
								ErrorAction = "Stop"
							}
		
							# Retrieving the aduser properties
							try {
								$Script:ADUser = Get-ADUser @ADParams | Select-Object $ADParams.Properties
							}
							catch {
								Write-Warning $_.Exception.Message
							}

							if ($ADUser) {

								$CurrentDate  = Get-Date -Format yyyy-MM-dd
								
								# Filter out duties
								$Script:Duties = foreach ($duty in $item._embedded.duties) {
									if ($duty.startDate -le $CurrentDate -and $duty.endDate -ge $CurrentDate -and $duty.dutyAt.id -in $CheckSchoolUnits.externalId -and $duty.dutyRole -ne 'Skoladministratör') {
										$duty
									}
								}
		
								<# $Script:CurrentEmployment = if ($SchoolInfo.count -gt 1) {
									# $EgilUnits = Get-EgilSchoolUnit -All
									foreach ($SchoolUnit in ($SchoolInfo)) {
										if ($Schoolunit.dutyAt.id -in $EgilSchoolUnits.externalId) {
											$SchoolUnit
										}
									}
								} #>

								<# $Script:CurrentRoles = if ($item._embedded.duties) {
									
									foreach ($Role in $item._embedded.duties | Where-Object {$_.startDate -le $CurrentDate -and $_.endDate -ge $CurrentDate}) {
										$Role | Where-Object {$_.assignmentRole.startDate -le $CurrentDate -and $_.assignmentRole.endDate -ge $CurrentDate}
									}
								} #>

								if ($Duties) {
									[PSCustomObject]@{
										externalId   = $item.id
										userName     = $ADUser.vkePPN
										displayName  = "$($item.givenName) $($item.familyName)"
										givenName    = $item.givenName
										familyName   = $item.familyName
										email        = $ADUser.mail
										ssn          = $item.civicNo.value
										employment   = if ($Duties.Count -gt 1) {
											foreach ($Duty in $Duties) {
												@{
													teacherId    = $Duty.person.id
													schoolUnitId = $Duty.dutyAt.id
													roleType     = $Duty.dutyRole
												}
											}
										}
										else {
											[array[]]@{
												teacherId    = $Duties.person.id
												schoolUnitId = $Duties.dutyAt.id
												roleType     = $Duties.dutyRole
												
											}
										}
										<# teacherRole = if ($Duties.assignmentRole.Count -ge 1) {
											foreach ($TeacherRole in $Duties) {
												@{
													teacherId      = $item.id
													studentGroupId = $TeacherRole.assignmentRole.group.id
													roleType       = $TeacherRole.assignmentRole.assignmentRoleType
													owner          = $TeacherRole.dutyAt.id
												}
											}
										}
										else {
											[array[]]@{}
										} #>
									}
								}

								if ($Duties) {
									Remove-Variable Duties -Scope Script -Force
								}
								if ($ADuser) {
									Remove-Variable ADUser -Scope Script -Force
								}
							}
						}
					}
				}
			}
		}
	}

	end {
		if ($APIReady) {
			return $Final
		}
		else {
			return $Result
		}
	}
}
# End function.