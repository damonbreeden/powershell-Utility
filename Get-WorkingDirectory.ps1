function Get-WorkingDirectory {
    if ([bool]($MyInvocation.MyCommand.psobject.properties.name -match "Path")) {
        return (Split-Path $MyInvocation.MyCommand.Path -Parent)
    } else {
        return $pwd.path
    }
}