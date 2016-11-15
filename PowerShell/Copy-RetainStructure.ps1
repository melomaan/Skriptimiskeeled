Function Copy-RetainStructureRework {
<#
    .SYNOPSIS
        Copy files and/or directories by retaining their directory tree up to
        the root

    .PARAMETER Source
        Absolute source path of what you want to copy

    .PARAMETER Destination
        Absolute destination path of where you want to copy

    .PARAMETER Include
        String to include in Source parameter; this will effectively narrow
        down the search to just those files

    .PARAMETER Exclude
        String to exclude in the Source parameter

    .PARAMETER Recurse
        Whether or not to recursively include files when including

    .NOTES
        Name: Copy-RetainStructureRework.ps1
        Author: Üllar Seerme
        Created: 08-11-2016
        Modified: 09-11-2016
        Version: 1.0.1
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)][string]$Source,
        [Parameter(Mandatory=$True)][string]$Destination,
        [string]$Include,
        [string]$Exclude,
        [switch]$Recurse
    )

    Try {
        Resolve-Path -Path $Source -ErrorAction Stop | Out-Null
        $Source = $(Resolve-Path -Path $Source).Path
    } Catch {
        Write-Verbose "Caught an exception: $($_.Exception.Message)"
        Write-Verbose "Source parameter destination does not exist. Stopping script!"
        Break
    }

    Try {
        Resolve-Path -Path $Destination -ErrorAction Stop | Out-Null
        $Destination = $(Resolve-Path -Path $Destination).Path
    } Catch {
        Write-Verbose "Caught an exception: $($_.Exception.Message)"
        $Check = Read-Host "Create destination path `"$Destination`"? (Y/N)"

        Switch -Regex ($Check.ToLower()) {
            "y(es)?" {
                Write-Host "Entered `"$Check`""
                Write-Host "Creating destination path $($Destination)"
                New-Item -Path $Destination -ItemType Directory | Out-Null
            }

            "n(o)?"  {
                Write-Host "Entered `"$Check`""
                Write-Host "Stopping"
                Break
            }

            Default  { 
                Write-Host "Didn't enter Y(es) or N(o)"
                Write-Host "Stopping"
                Break
            }
        } # End switch
    }

    If ($PSBoundParameters.ContainsKey('Include')) {
        $GetChildItem = Get-ChildItem "$Source\*" -Include "$Include" -Recurse:$Recurse
    } ElseIf ($PSBoundParameters.ContainsKey('Exclude')) {
        $GetChildItem = Get-ChildItem "$Source\*" -Exclude "$Exclude"
    } Else {
        $GetChildItem = Get-ChildItem -LiteralPath $Source
    }

    # If $Destination + $Source does not exist
    If (!(Test-Path ($Destination + $Source.Substring(2)))) {
        # If $Source is not a container (directory)
        If (!(Test-Path $Source -PathType Container)) {
            Copy-Item -Path $Source -Destination 
        }

        Write-Verbose "Directory `"$($Source.Substring(2))`" doesn't exist at destination `"$Destination`""
        Write-Verbose "$($Destination + $Source.Substring(2)) = $False"
        
        Write-Verbose "Creating directory `"$($Destination + $Source.Substring(2))`""
        Try {
            New-Item -Path ($Destination + $Source.Substring(2)) -ItemType Directory -ErrorAction Stop | Out-Null
        } Catch {
            Write-Verbose "Caught an exception: $($_.Exception.Message)"
        }
    } Else {

    }
} # End function
