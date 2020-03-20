function Test-Administrator {
    # https://superuser.com/questions/749243/detect-if-powershell-is-running-as-administrator
    # test admin window (tests the window not the user account)
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}