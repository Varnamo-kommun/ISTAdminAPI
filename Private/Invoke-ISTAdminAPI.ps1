function Invoke-ISTAdminAPI {

    [CmdletBinding()]

    param (
        # Request string to be used in the API call.
        [Parameter(
            ParameterSetName = "Payload"
        )]
        [PSCustomObject]
        $Payload,

        # Request URL
        [Parameter(
            ParameterSetName = "RequestUrl"
        )]
        [string]
        $RequestUrl,

        # Method
        [Parameter()]
        [string]
        $Method
    )
    
    begin {
        # $ResponseOK = $false
        
        if (Confirm-NeedNewAccessToken) {
            Get-AccessToken -Credential $(Get-Secret -LiteralPath $ISTSettings.ClientAuthorizationPath)
        }
    }
    
    process {

        $InvokeParams = switch ($PSCmdlet.ParameterSetName) {
            Payload {
                @{
                    Uri         = $Payload.Url
                    Headers     = @{'Authorization'="Bearer $($ISTSettings.Token)"}
                    Body        = $Payload.Data
                    Method      = $Method
                    ContentType = "application/json; charset=utf-8"
                    ErrorAction = "Stop"
                }
            }
            RequestUrl {
                @{
                    Uri         = $RequestUrl
                    Headers     = @{'Authorization'="Bearer $($ISTSettings.Token)"}
                    Method      = $Method
                    ContentType = "application/json; charset=utf-8"
                    ErrorAction = "Stop"
                }
            }
        }

        try {
            $Response   = Invoke-WebRequest @InvokeParams
            $ResponseOK = $true
        }
        catch {
            Write-Error $_.Exception.Message
            $ResponseOK = $false
        }
    }
    
    end {
        
        # Based on the boolean variable, the switch either returns the access token or error code.
		switch ($ResponseOK) {
			True  {return $Response}
			False {return $InvokeParams}
		}
    }
}
# End function.