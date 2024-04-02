function Confirm-NeedNewAccessToken {

    [CmdletBinding()]

    param (
        
    )
    
    begin {
        
    }
    
    process {
        $NewAccessToken = if ($ISTSettings.TokenTime) {
			if ((New-TimeSpan -Start $ISTSettings.TokenTime -End $(Get-Date)).TotalSeconds -lt 3600) {
				$false
			}
			else {
				$true
			}
		}
		else {
			$true
		}
    }
    
    end {
        return $NewAccessToken
    }
}
# End function.