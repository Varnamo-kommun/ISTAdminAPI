function New-ConstructedName {

    [CmdletBinding()]

    param (
        # String that will be converted to skolverkets namning convention.
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $String, 

        # SchoolType
        [Parameter()]
        [string]
        $SchoolType
    )
    
    begin {

    }
    
    process {

        switch ($SchoolType) {
            GR {

                $StringArray = $String.Split("/")
                $SchoolYear  = $StringArray[0] -replace "[A-Ö]", ""
                $Subject = if ($StringArray[2] -like '*-*') {
                    $StringArray[2].Split("-")[0]
                }
                else {
                    $StringArray[2]
                }

                $FormattedSubject = switch ($Subject) {
                    KE {"KEM"}
                    SV {"SVE"}
                    BI {"BIO"}
                    MA {"MAT"}
                    EN {"ENG"}
                    FY {"FYS"}
                    GE {"GEO"}
                    HI {"HIS"}
                    SH {"SAM"}
                }

                $StringBuilder = $SchoolType + $SchoolType + $FormattedSubject + "01" + "_$SchoolYear"
            }
            GY {
                $StringArray = $String.Split("/")
                $Subject = $StringArray[2]

                $StringBuilder = switch -Wildcard ($Subject) {
                    "KEMKEM*" {"$($Subject)_$SchoolType"}
                    "SVESVE*" {"$($Subject)_$SchoolType"}
                    "BIOBIO*" {"$($Subject)_$SchoolType"}
                    "MATMAT*" {"$($Subject)_$SchoolType"}
                    "ENGENG*" {"$($Subject)_$SchoolType"}
                    "FYSFYS*" {"$($Subject)_$SchoolType"}
                    "GEOGEO*" {"$($Subject)_$SchoolType"}
                    "HISHIS*" {"$($Subject)_$SchoolType"}
                    "SAMSAM*" {"$($Subject)_$SchoolType"}
                    "RELREL*" {"$($Subject)_$SchoolType"}
                }
            }
        }
    }
    
    end {
        if ($StringBuilder) {
            return $StringBuilder
        }
        else {
            return $null
        }
    }
}
# End function.