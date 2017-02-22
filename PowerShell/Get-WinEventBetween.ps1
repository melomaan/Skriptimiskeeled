Function Get-WinEventBetween {
<#
    .SYNOPSIS
        Get all the Windows events that were logged during a certain time period

    .DESCRIPTION
        Effectively this function is a wrapper on top of Get-WinEvent that allows the user
        to specify a period in-between which to query for events by defining start and end
        dates and times (optional)

        TBD: A parameter with which to define the number of days to go back from -StartTime

    .EXAMPLE
        All events during a single day that were logged as "Warning"
        Get-WinEventBetween -StartTime "21.02.2017" -EndTime "21.02.2017" -Level 2 -Verbose

    .PARAMETER ComputerName
        FQDN of the computer you are trying to query. This defaults to "localhost"

    .PARAMETER StartTime
        A starting point for the query in the format "DD.MM.YYYY [HH:MM:SS]", where
        the time part is optional. This defaults to the current day and the latest event
        from the current time

    .PARAMETER EndTime
        An endpoint for the query in the format "DD.MM.YYYY [HH:MM:SS]", where
        the time part is optional. Without defining this the function queries for the
        oldest log entry it can find

    .PARAMETER Level
        Defines the severity level of an event. They are defined within Windows as follows:
        0 - LogAlways
        1 - Critical
        2 - Error
        3 - Warning
        4 - Information
        5 - Verbose

    .NOTES
        Name: Get-WinEventBetween.ps1
        Author: Üllar Seerme
        Created: 16-11-2016
        Modified: 22-02-2017
        Version: 1.0.1
#>

    # Requires -RunAsAdministrator

	Param(
        [ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1})]
        [Parameter(ValueFromPipeline=$True, Position=0)]
        [Alias("CimSession", "Name", "Server")]
        [String]$ComputerName = "localhost",
        [Alias("Start")]
        [String]$StartTime,
        [Alias("End")]
        [String]$EndTime,
        [ValidateSet(0, 1, 2, 3, 4, 5)]
        [Int32]$Level = 4,
        [Int32]$DaysAfter
    )

    # Get all log names (*) from $ComputerName, where logs with 0 records are excluded
    $Logs = (Get-WinEvent -ListLog * -ComputerName $ComputerName | 
        Where-Object { $_.RecordCount -Ne 0 } ).LogName
	
	# Need to figure out logic relating to DaysAfter/DaysBefore and StartTime/EndTime
    If ($PSBoundParameters.ContainsKey('DaysAfter')) {
        If ($PSBoundParameters.ContainsKey('StartTime')) {
            [DateTime]$StartTime = Get-Date $StartTime

            If ($StartTime.AddDays($DaysAfter) -Ge (Get-Date)) {
                Write-Verbose "You've set the end time into the future..."
                Write-Verbose "Please set a more reasonable number of days"
                Break
            } Else {
                [DateTime]$EndTime = $StartTime.AddDays($DaysAhead)
                Write-Host $EndTime
            }
        }
    }

    <#
        Found no option to have a default "show all" level type for logs, so opted
        for an If-block-based hashtable creation
    #>
    If ($PSBoundParameters.ContainsKey('Level')) {
        $FilterTable = @{
            "LogName"   = $Logs
            "StartTime" = $StartTime
            "EndTime"   = $EndTime
            "Level"     = $Level
        }
    } Else {
        $FilterTable = @{
            "LogName"   = $Logs
            "StartTime" = $StartTime
            "EndTime"   = $EndTime
        }
    }

    Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterTable `
        -ErrorAction SilentlyContinue -ErrorVariable +Errors

    If ($Errors.Count -Gt 0) {
        Write-Verbose "There were some non-terminating errors (exceptions) while executing Get-WinEvent"
        ForEach ($Error In $Errors) {
            Write-Warning "Get-WinEvent: $Error"
        }
    }
}
