function Write-CMTLog {

    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $true)]
        [string]$LogFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateSet(1, 2, 3)]
        [int]$LogLevel = 1
    )

    $DateTime  = New-Object -ComObject WbemScripting.SWbemDateTime
    $DateTime.SetVarDate($(Get-Date))
    $UtcValue  = $DateTime.Value
    $UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21)

    $Component = "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)"
    $ExecUser  = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
    $Computer  = $env:COMPUTERNAME

    #Create the line to be logged
    $LogLine =  "<![LOG[$($ExecUser): $Message]LOG]!>" +`
                "<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
                "date=`"$(Get-Date -Format M-d-yyyy)`" " +`
                "component=`"$Computer\$Component`" " +`
                "context=`"$($ExecUser)`" " +`
                "type=`"$LogLevel`" " +`
                "thread=`"$($pid)`" " +`
                "file=`"`">"

    
    # Write the line to the log file
    Add-Content -Value $LogLine -Path $LogFilePath -Encoding UTF8
}
# End function.