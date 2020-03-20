function Convert-IndexToExcelColumn {
    <#
    .SYNOPSIS
        Takes an index number (base 1) and converts it to a valid column indicator for Excel
    .DESCRIPTION
        Takes an index number (base 1) and converts it to a valid column indicator for Excel. For example, index '3' would return 'C', and index '29' would return 'AC'
    .PARAMETER index
        The integer to convert
    .INPUTS
        -[int]index (required)
    .OUTPUTS
        The column name in [string] format
    .NOTES
        Function:       Convert-IndexToExcelColumn
        Author:         Damon Breeden
        Requirements:   TBD
        Creation Date:  2020-02-06
        History:
            version 0.1 2020-02-06 Initial development
    .EXAMPLE
        Convert-IndexToExcelColumn -index '2'
            Returns 'B'
        Convert-IndexToExcelColumn -index '30'
            Returns 'AD'
        Convert-IndexToExcelColumn -index '1'
            Returns A
        Convert-IndexToExcelColumn -index '0'
            Returns $null, as there is no column '0' in Excel
    #>

    [CmdletBinding()]
        Param(
            [Parameter(
            HelpMessage         = 'The index to convert',
            Mandatory           = $true,
            ValueFromPipeline   = $true
        )]
        [int]$index
    )

    # validate the input
    if (($index -le 0) -or ($index -ge (26 * 27 + 1))) {
        Write-Error "Index '$index' out of bounds"
        return $null
        break
    }

    # first create a map of 1..26 equal to A..Z
    # https://terrytlslau.tls1.cc/2015/04/powershell-foreach-to-z.html
    # run this in a terminal to see what's happening: 65..90 | %{[char]$_}
    [hashtable]$map = @{0 = $null}
    for ($i = 1; $i -le 26; $i++) {
        $map.$i = [char]($i + 64)
    }

    # take our index and find out how many times 26 fits into it. this gives us our first char. this only supports up to 26 * 26
    # 26 is Z
    # using Floor below always rounds down
    # have to be $index - 1, otherwise 'Z' (26) will return two chars (as 26/26 = 1)
    [int]$fits = [math]::Floor(($index - 1)/26)
    # then we find out the remainder afterwards
    [int]$remainder = $index % 26
    # validate for 26 (Z)
    if ($remainder -eq 0) {
        $remainder = 26
    }

    [string]$return  = ($map.$fits + $map.$remainder)
    $return = $return.Replace("@","")
    return $return
}

foreach ($i in (1..(26*27))) {
    Convert-IndexToExcelColumn -index $i
}

foreach ($i in (-10..10)) {
    Convert-IndexToExcelColumn -index $i
}