function ConvertFrom-SpecialCharacter {

    [CmdletBinding()]

    param (
        # Character input
        [Parameter()]
        [string]
        $String
    )
    
    begin {

    }

    process {
        switch ($String) {
            {$String.Contains('/')} {$String = $String -replace '/', '%2F'}
            {$String.Contains('å')} {$String = $String -creplace 'å', '%C3%A5'}
            {$String.Contains('Å')} {$String = $String -creplace 'Å', '%C3%85'}
            {$String.Contains('ä')} {$String = $String -creplace 'ä', '%C3%A4'}
            {$String.Contains('Ä')} {$String = $String -creplace 'Ä', '%C3%84'}
            {$String.Contains('ö')} {$String = $String -creplace 'ö', '%C3%B6'}
            {$String.Contains('Ö')} {$String = $String -creplace 'Ö', '%C3%96'}
            {$String.Contains(' ')} {$String = $String -replace ' ', '+'}
            {$String.Length -gt 1} {$String = $String.Trim()}
        }
    }

    end {
        return $String
    }
}
# End function.