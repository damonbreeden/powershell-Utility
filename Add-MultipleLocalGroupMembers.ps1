function Add-MultipleLocalGroupMembers {
    param(
        [Parameter(
            Mandatory = $true
        )]
        [hashtable]$groupDefinition
    )
    foreach ($d in $groupDefinition.GetEnumerator()) {
        foreach ($u in $d.Value) {
            Write-Host "Group is $($d.Name) and user is $u"
            if ($u -notin ((Get-LocalGroupMember $($d.Name)).Name)) {
                # Almost certainly need to run some verification of existence
                try {
                    Add-LocalGroupMember -Group $($d.Name) -Member $u
                }
                catch {
                    Write-Error "Could not add $u to $($d.Name). Is $u correct and in the correct (domain\username) format?"
                    Write-Error $Error[1]
                    continue
                }
                Write-Host "Added $u to $($d.name)"
            }
            else { Write-Host "$u already member of $($d.name)" }
        }
    }
}