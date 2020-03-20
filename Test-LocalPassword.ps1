function Test-LocalPassword {
    # function to verify a password against the local computer
    # this works against network passwords
    [CmdletBinding()]
    Param (
        [Parameter(
            HelpMessage = 'The password object to test',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [System.Management.Automation.PSCredential]$passwordObject
    )
    # https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/test-local-user-account-credentials

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $env:COMPUTERNAME)
    $obj.ValidateCredentials($passwordObject.UserName, $passwordObject.GetNetworkCredential().Password) 
}