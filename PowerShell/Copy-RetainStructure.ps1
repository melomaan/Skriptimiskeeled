Function Copy-RetainStructure {
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

	.EXAMPLE
		Copy-RetainStructure -Source C:\Users\MyUser\Documents\MyPDFs -Destination C:\MyPath
		This would create a destination tree of: C:\MyPath\Users\MyUser\Documents\MyPDFs
		including all files and directories under "MyPDFs"

	.EXAMPLE
		Copy-RetainStructure -Source C:\Users\MyUser\Documents\MyPDFs -Destination C:\MyPath -Include ".txt"
		This would copy all of the text files under "MyPDFs" without looking at directories below "MyPDFs"

	.EXAMPLE
		Copy-RetainStructure -Source C:\Users\MyUser\Documents\MyPDFs -Destination C:\MyPath -Include ".txt" -Recurse
		This would copy all of the text files under "MyPDFs" by checking directories under "MyPDFs" as well

	.EXAMPLE
		Copy-RetainStructure -Source C:\Users\MyUser\Documents\MyPDFs -Destination C:\MyPath -Exclude ".pdf"
		This would exclude files under "MyPDFs" by checking directories under "MyPDFs" as well
		The Exclude parameter for Get-ChildItem seems to recurse by default, so it is not possible to exclude
		just at the parent directory ("MyPDFs" in this case)

	.NOTES
		Name: Copy-RetainStructure.ps1
		Author: Üllar Seerme
		Created: 08-11-2016
		Modified: 16-11-2016
		Version: 1.0.5
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
				Write-Verbose "Entered `"$Check`""
				Write-Host "Creating destination path $($Destination)"
				New-Item -Path $Destination -ItemType Directory | Out-Null
			}

			"n(o)?"  {
				Write-Verbose "Entered `"$Check`""
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
	If (!(Test-Path ($Destination + $Source.Substring(2))) -And (Test-Path $Source -PathType Container)) {
		Write-Verbose "Directory `"$($Source.Substring(2))`" doesn't exist at destination `"$Destination`""
		Write-Verbose "Creating directory `"$($Destination + $Source.Substring(2))`""
		Try {
			New-Item -Path ($Destination + $Source.Substring(2)) -ItemType Directory -ErrorAction Stop | Out-Null
		} Catch {
			Write-Verbose "Caught an exception: $($_.Exception.Message)"
		}
	} ElseIf (!(Test-Path ($Destination + $Source.Substring(2))) -And (Test-Path $Source -PathType Leaf)) {
		Try {
			New-Item -Path ($Destination + (Split-Path $Source.Substring(2))) -ItemType Directory -ErrorAction Stop | Out-Null
		} Catch {
			Write-Verbose "Caught an exception: $($_.Exception.Message)"
		} Finally {
			Copy-Item -Path $Source -Destination ($Destination + (Split-Path $Source.Substring(2)))
		}
	}

	$GetChildItem | Select -Expand FullName | ForEach-Object {
		# Check if current entry is a directory or not
		$DirectoryTest = Test-Path $_ -PathType Container

		# Check if current entry exists in the destination
		$PathTest = Test-Path ($Destination + ($_).Substring(2))

		<#
			If current entry is directory, then check whether path exists
			in the destination. If the path does not exist, create it. Copy
			all contents of path (since it is a directory) to (new) directory
		#>
		If ($DirectoryTest) {
			If (!$PathTest) {
				Try {
					New-Item -Path ($Destination + ($_).Substring(2)) -ItemType Directory -Verbose -ErrorAction Stop
				} Catch {
					Write-Verbose "$($Destination + ($_).Substring(2)) already exists!"
				}
			}

			Copy-Item -Path ($_ + "\*") -Destination ($Destination + ($_).Substring(2)) -Recurse -Verbose
			
		<#
			If current entry is not a directory (a file), then check whether
			path exists in the destination. If the path does not exist, create it
			based on current entry. Copy current entry to (new) directory
		#>
		} Else {
			If (!$PathTest) {
				Try {
					New-Item -Path ($Destination + (Split-Path $_ -Parent).Substring(2)) -ItemType Directory -Verbose -ErrorAction Stop
				} Catch {
					Write-Verbose "$($Destination + (Split-Path $_ -Parent).Substring(2)) already exists!"
				}
			}

			Copy-Item -Path $_ -Destination ($Destination + ($_).Substring(2)) -Verbose
		} # End If ($DirectoryTest)
	} # End $GetChildItem
} # End function
