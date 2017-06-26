Function Send-Command {
<#
	.SYNOPSIS
		Run any arbitrary command or script against one or multiple hosts

	.DESCRIPTION
		The script takes multiple optional arguments and based on those makes
		decisions on what kind of hosts it should run commands against. The
		options range from a plain text file to a connection against a VMM
		server that provides details on a number of hosts all at once. For
		running commands against a single or a handful of hosts, it is best
		to use a text file and specify it as a -Path argument

		It is highly advised to run this function with -Verbose defined!

	.EXAMPLE
		Send-Command -Path C:\Path\To\My\Text\File -Domain MyDomain
		Send a command to all hosts in $Path using MyDomain to authenticate

	.EXAMPLE
		Send-Command -Domain MyDomain -User MyUser -ComputerName MyVMMServer -Type "win"
		Send a command to all Windows hosts in MyVMMServer using MyDomain and 
		MyUser to authenticate

	.EXAMPLE
		Send-Command -Cluster "MyCluster" -Verbose
		Send a command to all hosts in the MyCluster cluster in MyVMMServer using 
		default $User and $Domain to authenticate

	.PARAMETER Path
		Path to the input text file with individual hosts on separate lines

	.PARAMETER Domain
		Name of the domain you are working in; this will be required for
		setting up a persistent credentials variable for connecting to each
		host

	.PARAMETER User
		Name of the user you are doing connections as

	.PARAMETER ComputerName
		FQDN of the VMM server you are trying to query in case Path was not provided

	.PARAMETER Type
		The type of hosts you want to query, which defaults to "hv" for Hyper-V
		hosts, but this can also be "vm" for virtual machines or "win" for Windows
		machines

	.PARAMETER Cluster
		Name of the cluster you want to target. Wildcards are already set into the
		function so just input as much as you know the name of cluster to be

	.LINK
		VirtualMachineManager module: https://technet.microsoft.com/en-us/library/hh875013(v=sc.12).aspx

	.NOTES
		Name: Send-Command.ps1
		Author: Üllar Seerme
		Created: 01-07-2016
		Modified: 26-02-2017
		Version: 1.1.2
#>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$True)]
		[string]$Path,
		[string]$Domain="MyDomain",
		[string]$User="MyUser",
		[string]$ComputerName="MyVMMServer",
		[string]$Type="hv",
		[string]$Cluster
	)

	Begin {
		If (!$PSBoundParameters.ContainsKey('Path')) {
			Write-Verbose "No value given for Path. Assuming VMM server is going to be used with a value of '$ComputerName'"

			Write-Verbose "Importing 'VirtualMachineManager' module"
			Import-Module VirtualMachineManager

			Write-Verbose "Connecting to VMM management server"
			$VMMServer = Get-SCVMMServer -ComputerName $ComputerName

			If (!$PSBoundParameters.ContainsKey('Cluster')) {
				Write-Verbose "No value given for Cluster."

				If (!$PSBoundParameters.ContainsKey('Type')) {
					Write-Verbose "No value given for Type. Using default value of '$Type'"
				} Else {
					Write-Verbose "Using given value of '$Type'"
				}

				Write-Verbose "Obtaining all '$Type' hostnames from '$ComputerName'"
				Switch -Wildcard ($Type.ToLower()) {
					"hv"      { $VMHosts = Get-SCVMHost -VMMServer $VMMServer }
					"vm"      { $VMHosts = Get-SCVirtualMachine -VMMServer $VMMServer }
					"win*"    { $VMHosts = Get-SCVirtualMachine -VMMServer $VMMServer | Where-Object { $_.OperatingSystem.IsWindows } }
					"*n[ui]x" { $VMHosts = Get-SCVirtualMachine -VMMServer $VMMServer | Where-Object { !$_.OperatingSystem.IsWindows } }
				}
			} Else {
				Write-Verbose "Obtaining all hostnames from '$Cluster' listed in '$ComputerName'"
				$VMHosts = Get-SCVMHost -VMMServer $VMMServer | Where-Object { $_.VMHostGroup -Like "*$Cluster*" }
			}
		} Else {
			Write-Verbose "Using text file with list of host names from '$Path'"
			$VMHosts = Get-Content $Path

			Write-Verbose "Clearing any other conflicting variables"
			$ComputerName = ""
			$Type = ""
		}

		If (!$PSBoundParameters.ContainsKey('Domain')) {
			Write-Verbose "No value given for Domain. Using default value of '$Domain'"
		} Else {
			Write-Verbose "Using given value of '$Domain'"
		}
		
		If (!$PSBoundParameters.ContainsKey('User')) {
			Write-Verbose "No value given for User. Using default value of '$User'"
		} Else {
			Write-Verbose "Using given value of '$User'"
		}

		Write-Verbose "Creating counter variables"
		$OKCount = 0
		$FailArray = @()
		$TotalCount = $VMHosts.Count
		$Count = 0

		Write-Verbose "Sorting hosts by name"
		$VMHosts = $VMHosts | Sort-Object ComputerName

		Write-Verbose "Listing all hosts:"
		$VMHosts | ForEach-Object { 
			Write-Verbose $_
		}

		Write-Verbose "Starting with $TotalCount hosts"

		Write-Verbose "Creating persistent variable for credentials`n"
		$Creds = Get-Credential "$Domain\$User"
	} # End of Begin-section

	Process {
		Write-Verbose "Setting optional variable to be used inside each invoked command`n"
		$Password = Read-Host "Enter password" -AsSecureString

		ForEach ($Server in $VMHosts) {
			$Count += 1
			Write-Verbose "($Count / $TotalCount) Processing $Server"

			Write-Verbose "Running custom command(s)"
			$Script = {
				Param(
					$FilePassword
				)
				Add-Content file.txt "$FilePassword"
			}

			Invoke-Command -ComputerName $Server -ArgumentList $Password -ScriptBlock $Script -Credential $Creds -Authentication Credssp

			If (!$?) {
				Write-Verbose "Failed with $Server. Updating statistics"
				$FailArray += $Server
			} Else {
				$OKCount += 1
			}

			Write-Verbose "Finished with $Server `n"
		}
	} # End of Process-section

	End {
		Write-Verbose "Finished script with $OKCount / $TotalCount hosts"
		
		If ($($FailArray.Length) -Ne 0) {
			Write-Host "Could not reach $($FailArray.Length) hosts"
			Write-Host "Failed hosts:"
			ForEach ($Server In $FailArray) {
				If (!$PSBoundParameters.ContainsKey('Path')) {
					Write-Output $Server | Select Name, VMHostGroup
				} Else {
					Write-Output $Server
				}
			} # End of ForEach
		} # End $($FailArray.Length)
	} # End of End-section
} # End of Send-Command function
