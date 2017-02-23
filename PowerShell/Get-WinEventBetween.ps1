Function Get-WinEventBetween {
<#
    .SYNOPSIS
        Get all the Windows events that were logged during a certain time period

    .DESCRIPTION
        Effectively this function is a wrapper on top of Get-WinEvent that allows the user
        to specify a period in-between which to query for events by defining start and end
        dates and times (optional)

    .EXAMPLE
        All events during a single day that were logged as "Warning"
        Get-WinEventBetween -StartTime "21.02.2017" -EndTime "21.02.2017" -Level 2 -Verbose

    .PARAMETER ComputerName
        FQDN of the computer you are trying to query. This defaults to "localhost"

    .PARAMETER StartTime
        A starting point for the query in the format "dd.MM.yyyy [HH:mm.ss]", where
        the time part is optional. This defaults to the current day and the latest event
        from the current time

    .PARAMETER EndTime
        An endpoint for the query in the format "dd.MM.yyyy [HH:mm.ss]", where
        the time part is optional. Without defining this the function queries for the
        oldest log entry it can find

    .PARAMETER Days
        The number of days to either go back or forward depending on whether $StartTime or
        $EndTime was defined

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
        Modified: 23-02-2017
        Version: 1.0.2
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
        [Int32]$Days
    )

    # Get all log names (*) from $ComputerName, where logs with 0 records are excluded
    $Logs = (Get-WinEvent -ListLog * -ComputerName $ComputerName | 
        Where-Object { $_.RecordCount -Ne 0 } ).LogName
    
    If ($PSBoundParameters.ContainsKey('StartTime')) {
        If ($PSBoundParameters.ContainsKey('Days')) {

            [DateTime]$StartTime = Get-Date $StartTime
            If ($StartTime.AddDays($Days) -Le (Get-Date)) {
                $EndTime = ($StartTime.AddDays($Days)).ToString("dd.MM.yyyy")
                [String]$StartTime = $StartTime.ToString("dd.MM.yyyy")
            } Else {
                Write-Host "You've added too many days; the end point is now in the future"
                Write-Host "Please set a more reasonable number of days"
                Break
            }
        }
    }

    If ($PSBoundParameters.ContainsKey('EndTime')) {
        If ($PSBoundParameters.ContainsKey('Days')) {

            [DateTime]$EndTime = Get-Date $EndTime
            If ($EndTime -Le (Get-Date)) {
                $StartTime = ($EndTime.AddDays(-$Days)).ToString("dd.MM.yyyy")
                [String]$EndTime = $EndTime.ToString("dd.MM.yyyy")
            } Else {
                Write-Verbose "You've set the end time into the future..."
                Write-Verbose "Please set a more appropriate date for `$EndTime"
                Break
            }
        }
    }

    Write-Host "Start: $StartTime"
    Write-Host $StartTime.GetType()

    Write-Host "End: $EndTime"
    Write-Host $EndTime.GetType()

    $FilterTable = @{
        "LogName"   = $Logs
        "StartTime" = $StartTime
        "EndTime"   = $EndTime
        "Level"     = $Level
    }

    $FilterTable.GetEnumerator()

    Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterTable `
        -ErrorAction SilentlyContinue -ErrorVariable +Errors

    If ($Errors.Count -Gt 0) {
        Write-Verbose "There were some non-terminating errors (exceptions) while executing Get-WinEvent"
        ForEach ($Error In $Errors) {
            Write-Warning "Get-WinEvent: $Error"
        }
    }
}
