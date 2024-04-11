function Format-APICall {

	[CmdletBinding()]

	param (
		# Property to be used
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

	}

	process {

		$UTF8 = [System.Text.Encoding]::UTF8.GetString($InputObject.Content.ToCharArray())
		$Converted = $UTF8 | ConvertFrom-Json

		$Result = if ($Converted | Select-Object -ExpandProperty data -ErrorAction SilentlyContinue) {
			$Converted | Select-Object -ExpandProperty data
		}
		else {
			$Converted
		}
	}

	end {
		return $Result
	}
}
# End function.