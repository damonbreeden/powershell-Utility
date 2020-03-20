function Test-Credential {

    # ref for improvements:
    # https://blogs.technet.microsoft.com/dsheehan/2018/06/23/confirmingvalidating-powershell-get-credential-input-before-use/
    <#
        .SYNOPSIS
            Takes a PSCredential object and validates it against the domain (or local machine, or ADAM instance).
    
        .PARAMETER cred
            A PScredential object with the username/password you wish to test. Typically this is generated using the Get-Credential cmdlet. Accepts pipeline input.
            
        .PARAMETER context
            An optional parameter specifying what type of credential this is. Possible values are 'Domain' for Active Directory accounts, and 'Machine' for local machine accounts. The default is 'Domain.'
        
        .OUTPUTS
            A boolean, indicating whether the credentials were successfully validated.
    
        .NOTES
            Created by Jeffrey B Smith, 6/30/2010
    #>
        param(
            [parameter(Mandatory=$true,ValueFromPipeline=$true)]
            [System.Management.Automation.PSCredential]$credential,
            [parameter()][validateset('Domain','Machine')]
            [string]$context = 'Domain'
        )
        begin {
            Add-Type -AssemblyName System.DirectoryServices.AccountManagement
            $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::$context) 
        }
        process {
            $DS.ValidateCredentials($credential.GetNetworkCredential().UserName, $credential.GetNetworkCredential().password)
        }
    }