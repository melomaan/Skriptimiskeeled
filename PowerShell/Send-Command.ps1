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
        Send a command to all hosts in the MyCluster cluster in 
        MyVMMServer using default $User and $Domain to authenticate
    .NOTES
        Name: Send-Command.ps1
        Author: Üllar Seerme
        Created: 01-07-2016
        Modified: 28-09-2016
        Version: 1.0.5
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
                    "hv"        { $VMHosts = Get-SCVMHost -VMMServer $VMMServer }
                    "vm"        { $VMHosts = Get-VM -VMMServer $VMMServer }
                    "win*"      { $VMHosts = Get-VM -VMMServer $VMMServer | Where-Object {$_.OperatingSystem.IsWindows} }
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
        $FailCount = 0
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
        # Write-Verbose "Setting optional variable to be used inside each session`n"
        # $Password = Read-Host "Enter password" -AsSecureString

        ForEach ($Server in $VMHosts) {
            $Count += 1
            Write-Verbose "($Count / $TotalCount) Processing $Server"

            $Session = New-PSSession -ComputerName $Server -Credential $Creds -Authentication Credssp

            Write-Verbose "Running custom command(s)"
            $Script = {
                # Param(
                #     $FilePassword
                # )
                Get-Content "C:\Windows\Temp\test.txt" # -Credential $FilePassword
            }

            Invoke-Command -Session $Session -ScriptBlock $Script # -ArgumentList $Password

            If (!$?) {
                Write-Verbose "Failed with $Server. Updating statistics"
                $FailCount += 1
                $FailArray += $Server
            } Else {
                $OKCount += 1
            }

            Remove-PSSession $Server
            Write-Verbose "Finished with $Server `n"
        }
    } # End of Process-section

    End {
        Write-Verbose "Finished script with $OKCount / $TotalCount hosts"
        
        If ($FailCount -Ne 0) {
            Write-Host "Could not reach $FailCount hosts"
            Write-Host "Failed hosts:"
            ForEach ($Server In $FailArray) {
                Write-Output $Server | Select Name, VMHostGroup
            }
        }
    } # End of End-section
} # End of Send-Command function