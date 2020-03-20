function Set-ServiceLogonAccount {
    # https://www.itprotoday.com/powershell/changing-service-credentials-using-powershell
    # this shouldn't be necessary after PS6
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'The service to set',
            Mandatory = $true,
            ValueFromPipeline = $false)]
        [string]$name,

        [Parameter(
            HelpMessage = 'The credential object to set',
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [System.Management.Automation.PSCredential]$credential
    )
    Write-Verbose "Validating the service $name"
    try { Get-Service -Name $name }
    catch [NoServiceFoundForGivenName, Microsoft.PowerShell.Commands.GetServiceCommand] {
        Write-Error "Service $name is not found. Quitting!"
        break
    }
    $params = @{
        "Namespace" = "root\CIMV2"
        "Class"     = "Win32_Service"
        "Filter"    = "Name='$name'"
    }
    $service = Get-WmiObject @params
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    $service.StopService()
    $service.Change($null,
        $null,
        $null,
        $null,
        $null,
        $null,
        $UserName,
        $Password,
        $null,
        $null,
        $null)
    $service.StartService()
    while ($service.State -ne 'Running') {
        Write-Host "Service $($service.DisplayName) not started! Please manually check the service. Will check service state again in 60 seconds."
        Start-Sleep -Seconds 60
    }
}