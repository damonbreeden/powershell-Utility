function Install-OraclePatches {
    <#
    .SYNOPSIS
        Patches Oracle on Windows
    .DESCRIPTION
        Patches Oracle on Windows
    .PARAMETER patchSourceDir
        -patchSourceDir specifies where the patches are stored
    .PARAMETER patchDestination
        -patchDestination specifies where the patches get extracted to
    .PARAMETER oracleHomeKey
        Required.
        -oracleHome specifies the Oracle Home. This should be grabbed outside of this script       
    .INPUTS
        Requires a patchSourceDir and a patchDestination
    .OUTPUTS
        None
    .NOTES
        Script:         function Install-OraclePatches
        Author:         Damon Breeden
        Requirements:   Powershell v5
        Creation Date:  2020-01-14
        History:
            version 1.0 2020-01-14 - Initial script development
    .EXAMPLE
        Installs patches, using "\\mpsshr02\oracleadmins$\PATCH_CURRENT\11G" as the patchSourceDir and "D:\PATCH" as the patchDestination directory
        Install-OraclePatches -patchSourceDir '\\mpsshr02\oracleadmins$\PATCH_CURRENT\11G' -patchDestination 'D:\PATCH'
    #>

    [CmdletBinding()]

    param (
        [Parameter(
            HelpMessage = "-patchSourceDir specifies where the patches are stored",
            Mandatory = $false
        )]
        [System.IO.FileInfo]$patchSourceDir = '\\mpsshr02\oracleadmins$\PATCH_CURRENT\11G',
    
        [Parameter(
            HelpMessage = "-patchDestination specifies where the patches get extracted to",
            Mandatory = $false
        )]
        [System.IO.FileInfo]$patchDestination = 'D:\PATCH',
        [Parameter(
            HelpMessage = 'oracleHomeKey specifies the Oracle Home key. This should be grabbed outside of this script',
            Mandatory = $true
        )]
        [System.IO.FileInfo]$oracleHomeKey
    )

    # test the vars

    while (!(Test-Path -Path $oracleHomeKey)) {
        $oracleHomeKey = Read-Host "Could not locate $oracleHomeKey! Please specify the path to the Oracle Home key (e.g. HKLM:\SOFTWARE\oracle\KEY_OraDb11g_home1)"
    }
    
    Write-Host "Using $oracleHomeKey as the Oracle Home key"

    while (!(Test-Path -Path $patchSourceDir -PathType Container)) {
        $patchSourceDir = Read-Host "Could not locate $patchSourceDir or it was not of expected type (directory)! Please specify the complete path to the patch source directory"
    }

    Write-Host "Using $patchSourceDir as the patch source directory"

    Write-Host "Using $patchDestination as the patch destination directory"

    # execution

    $patchFile = Get-ChildItem -Path "$patchSourceDir\*.zip"
    $patchFileName = $patchFile.Name
    Write-Host "Patch file name is $patchFileName"

    #start patching
    If ($patchFile.count -eq 0) {
        $message = "Found 0 zip files in $patchSourceDir, skipping patches"
        Write-Host $message @wh_p
        continue
    }
    elseif ($patchfile.count -gt 1) {
        $message = "Found $($patchFile.count) zip files in $patchSourceDir, please ensure there is exactly one!"
        Write-Host $message @wh_p
        Read-Host -Prompt "Press enter to break this script"
        break
    }
    else {
        #first kill some services
        Write-Host "Killing all Oracle and some M$ services"
        $oraServices = @()
        $oraServices += (Get-Service -Name "*oracle*" | Where-Object status -eq Running).Name
        # verify services exist??
        $oraServices += "MSDTC", "HealthService", "SENS", "Winmgmt", "VMTools", "ComSysApp"
        foreach ($os in $oraServices) {
            try {
                Stop-Service -Name $os -Force
                Write-Host "Stopped $os" -Flag 0
                Set-Service -Name $os -StartupType Disabled
                Write-Host "Set $os to disabled"
            }
            catch {
                Read-Host -Prompt "Could not stop service $os, please review the errors, manually stop service $os and press Enter to continue"
            }
        }
        # expand the zip file to the $patchDestination
        # logic that ensures a clean directory
        [string]$i = 1
        while (Test-Path $patchDestination) {
            $patchDestination = $patchDestination + $i
            $i++
        }
        $i = $null

        New-Item -ItemType Directory -Path $patchDestination -Force
        Write-Host "Created $patchDestination"

        $outPath = ($patchDestination + "\$patchFileName").replace(".zip", "")
        Write-Host "Extracting patches to $outPath"

        [System.Reflection.Assembly]::LoadwithPartialName('System.IO.Compression.FileSystem')
        [System.IO.Compression.ZipFile]::ExtractToDirectory($patchFile.FullName, $outPath)
        Write-Host "Extracted $($patchFile.Fullname) to $outPath"
    
        #set some locations
        $oracle_home = Get-ItemProperty -Path $oracleHomeKey | Select-Object ORACLE_HOME
        $oracle_home = $oracle_home.ORACLE_HOME
        Write-Host "Using $oracle_home as the Oracle_Home"
        $opatch = ";$oracle_home\OPatch"
        $env:Path += $opatch
        Write-Host "Using OPatch at $opatch"
        # probably don't need this line but here we are
        set-location $outpath
        # this finds the actions.xml file
        $actionsFile = Get-ChildItem -Filter "actions.xml" -recurse

        # in this case the file is at D:\PATCH\p28761877_112040_MSWIN-x86-64\28761877\etc\config
        # we need to be in the numbered folder- 28761877
        # so we have to go two levels above actions.xml
        # first do a try/catch to verify that $actionsfile is defined
        try {
            Set-Location ((get-Item $actionsFile.FullName).Directory.Parent.Parent)
        }
        catch {
            $message = "Could not set location in `$actionsFile. Does it exist?`
            `$actionsFile is defined as: $actionsFile`
            Note that if the above is blank then no `$actionsFile was found.
            This is a terminating error."
            Write-Error $message
            break
        }
        # need a check here to see if opatch actually runs
        # $opatchResult = opatch apply
        Start-Process -FilePath 'opatch' -ArgumentList 'apply' -Verb RunAs
        #restart services
        foreach ($os in $oraServices) {
            try {
                Set-Service -Name $os -StartupType Automatic
                Write-Host "Set $os to Automatic"
                Start-Service -Name $os
                Write-Host "Started $os"
            }
            catch {
                Write-Error "Could not start $os. Pleas start it manually"
                Read-Host -Prompt "Press enter to continue"
            }
        }
        Read-Host -Prompt "Opatch finished. There is no error handling in this script. Please manually verify that the patches have been applied. Press enter to continue."
    }
}