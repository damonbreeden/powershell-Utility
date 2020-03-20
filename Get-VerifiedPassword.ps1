function Get-VerifiedPassword {
    <#
    .SYNOPSIS
        Verifies that a password is typed the same two times
    .DESCRIPTION
        Verifies that a password is typed the same two times
    .PARAMETER username
        Optional. Creates a [System.Management.Automation.PSCredential] object with the passed username. If left out will create a [System.Management.Automation.PSCredential] object with the username 'none'.
    .INPUTS
        None required.
    .OUTPUTS
        A [System.Management.Automation.PSCredential] object
    .NOTES
        Script:         function Get-VerifiedPassword
        Author:         Damon Breeden
        Requirements:   Powershell v5
        Creation Date:  2020-01-15
        History:
            version 1.0 2020-01-15 - Initial script development
    .EXAMPLE
        Get a password for user 'damon'
        Get-VerifiedPassword -username 'damon'
    .EXAMPLE
        Get a password with no named user
        Get-VerifiedPassword
    #>
    [CmdletBinding()]
    Param (
        [Parameter(
            HelpMessage = 'The username, not required',
            Mandatory = $false,
            ValueFromPipeline = $false
        )]
        [string]$username,

        [Parameter(
            HelpMessage = 'Confirm the username exists',
            Mandatory = $false
        )]
        [switch]$confirmUsername = $false
    )

    if ($confirmUsername) {
        if (!($PSBoundParameters.username)) {
            Write-Error '-confirmUsername specified but no username passed!'
            break
        }
        Get-LocalUser $username
    }
    if ($PSBoundParameters.username) {
        $i = 0
        do {
            if ($i -gt 0) { Write-Host "Password did not match!" -ForegroundColor Red }
            Write-Host "Please confirm the $username password.`
Note that this does not check the validity of the password , only that you've typed in the same thing twice."     
            $Password = Get-Credential -Username $username -Message "Please input the $username password"
            $PasswordConf = Get-Credential -Username $username -Message "Please verify the $username password"
            $i++
        }
        until ($Password.GetNetworkCredential().Password -eq $PasswordConf.GetNetworkCredential().Password)
        $i = $null
    }
    else {
        $i = 0
        do {
            if ($i -gt 0) { Write-Host "Password did not match!" -ForegroundColor Red }
            Write-Host "Please confirm the password.`
Note that this does not check the validity of the password , only that you've typed in the same thing twice." 
            $Password = Read-Host -Prompt "Please input the password" -AsSecureString
            $PasswordConf = Read-Host -Prompt "Please verify the password" -AsSecureString
            $UserName = 'none'
            $Password = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $Password
            $PasswordConf = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $PasswordConf
            $i++
        }
        until ($Password.GetNetworkCredential().Password -eq $PasswordConf.GetNetworkCredential().Password)
        $i = $null
    }
    return $password
}