Function Get-WinEventBetween {

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
        [Int32]$Level = 4
    )

    # Get all log names (*) from $ComputerName, where logs with 0 records are excluded
    $Logs = (Get-WinEvent -ListLog * -ComputerName $ComputerName | Where-Object { $_.RecordCount -Ne 0 } ).LogName

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

    Get-WinEvent -ComputerName $ComputerName -FilterHashtable $FilterTable
}
