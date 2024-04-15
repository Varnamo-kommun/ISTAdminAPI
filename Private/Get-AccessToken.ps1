function Get-AccessToken {
	<#
	.SYNOPSIS
	Retrieves an access token.
	
	.DESCRIPTION
	Retrieves an access token from skolid.se and uses it to authenticate against the IST Administration API.
	
	.PARAMETER Credential
	Uses client_id and client_secret that are provided by the vendor. Needs to be passed as a PSCredential.
	
	.EXAMPLE
	Get-AccessToken -Credential $CredObject
	
	.NOTES
	Author: Simon Mellergård | It-center, Värnamo kommun
	#>

	[CmdletBinding()]

	param (
		# Credential object with information provided from vendor.
		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential
	)

	begin {
		$RefreshToken = Confirm-NeedNewAccessToken
	}

	process {

		if ($RefreshToken) {
			# POST body with provided credentials
			$Body = @{
				grant_type    = 'client_credentials'
				client_id 	  = "$($Credential.UserName)"
				client_secret = "$($Credential.GetNetworkCredential().Password)"
			}

			# Splatted params for the web request.
			$InvokeParams = @{
				Uri         = 'https://skolid.se/connect/token'
				Method      = 'POST'
				Body		= $Body
				ErrorAction = "Stop"
			}
			
			# Try/Catch block executing the web request. Changes the boolean variable when successful.
			try {
				$Response   = Invoke-WebRequest @InvokeParams
				$TokenTime = Get-Date -Format s
				# $responseREST = Invoke-RestMethod
				$Token      = $Response.Content | ConvertFrom-Json | Select-Object -ExpandProperty access_token -ErrorAction Stop
				$ResponseOK = $true
			}
			catch {
				# Boolean variable that determines return value
				$ResponseOK = $false
				Write-Error -Message $_.Exception.Message
			}
		}
	}

	end {

		# Based on the boolean variable, the switch either returns the access token or error code.
		if ($RefreshToken) {
			switch ($ResponseOK) {
				True  {
					if (-not ($ISTSettings.Token)) {
						$ISTSettings | Add-Member -MemberType NoteProperty -Name Token -Value $Token
					}
					else {
						$ISTSettings.Token = $Token
					}

					if (-not ($ISTSettings.TokenTime)) {
						$ISTSettings | Add-Member -MemberType NoteProperty -Name TokenTime -Value $TokenTime
					}
					else {
						$ISTSettings.TokenTime = $TokenTime
					}
				}
				False {return $InvokeError}
			}
		}
		else {
			Write-Output "Current token still active."
		}
	}
}
# End function.