Function Copy-RetainStructure {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$Source,
        [Parameter(Mandatory=$True)]
        [string]$Destination,
        [string]$Include,
        [string]$Exclude
    )

    If ($PSBoundParameters.ContainsKey('Include')) {
        $Command = Get-ChildItem -LiteralPath $Source -Filter "$Include"
    } ElseIf ($PSBoundParameters.ContainsKey('Exclude')) {
        $Command = Get-ChildItem -LiteralPath $Source | Where-Object { $_.FullName  -NotMatch "$Exclude" }
    } Else {
        $Command = Get-ChildItem -LiteralPath $Source
    }

    $Command | Select -Expand FullName | ForEach-Object {
        # Check if current entry is directory or not
        $DirectoryTest = Test-Path $_ -PathType Container

        # Check if current entry exists on remote server
        $PathTest = Test-Path ($Destination + ($_).Substring(2))

        <#
            If current entry is directory, then check whether path exists
            in the destination. If the path does not exist, create it. Copy
            all contents of path (since it is a directory) to (new) directory
        #>
        If ($DirectoryTest) {
            If (!$PathTest) {
                New-Item -Path ($Destination + ($_).Substring(2)) -ItemType Directory -Verbose
            }

            Copy-Item -Path ($_ + "\*") -Destination ($Destination + ($_).Substring(2)) -Recurse -Verbose
            
        <#
            If current entry is not a directory (a file), then check whether
            path exists in the destination. If the path does not exist, create it
            based on current entry. Copy current entry to (new) directory
        #>
        } Else {
            If (!$PathTest) {
                New-Item -Path ($Destination + (Split-Path $_ -Parent).Substring(2)) -ItemType Directory -Verbose
            }

            Copy-Item -Path $_ -Destination ($Destination + ($_).Substring(2)) -Verbose  
        } # End If ($DirectoryTest)
    } # End $Command
} # End function
