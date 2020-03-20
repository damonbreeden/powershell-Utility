# put these lines in your script

# Dot-source my own functions
#either set UtilityBox with env vars or using a var above this line
# set the execution policy for now only
$executionPolicy = Get-ExecutionPolicy -scope Process
if ($executionPolicy -ne "Unrestricted") {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
}
if ($UtilityBox) {
    Write-Host "`$utilityBox specified by local var"
    Write-Host "Using UtilityBox in $utilityBox"
    foreach ($u in (Get-Item -Path "$utilityBox\*.ps1")) {
        Write-Host "Loading $u"
        . $u
    }
}
elseif ($env:UtilityBox) {
    Write-Host "`$utilityBox found in environment vars"
    $utilityBox = $env:utilityBox
    Write-Host "Using UtilityBox in $utilityBox"
    foreach ($u in (Get-Item -Path "$utilityBox\*.ps1")) {
        Write-Host "Loading $u"
        . $u
    }
}
else {
    Write-Host "No utility box found, none loaded!"
    Start-Sleep 10
}
Set-ExecutionPolicy -Scope Process -ExecutionPolicy $executionPolicy
