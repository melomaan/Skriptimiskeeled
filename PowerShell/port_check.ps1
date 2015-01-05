<#
    Script either checks all common ports on an address or
    just the specified one.
#>

$ans = Read-Host "Do you want to scan a specific port? (Y/N)"
$ports = @(21, 22, 23, 25, 53, 80, 110, 115, 135, 139, 143, 
194, 443, 445, 1433, 3306, 3389, 5632, 5900)
$cn = New-Object System.Net.Sockets.TcpClient

If ($ans.ToLower() -eq "y")
{ 
    $port = Read-Host "Enter port number"
    $adr = Read-Host "Enter address"
    $cn.Connect($adr, $port)
    If ($cn.Connected)
    {
        Write-Host "Port $port is open on $adr"
        $cn.Close()
    } Else {
        Write-Host "Port $port is closed on $adr"
    }
} Else {
    $adr = Read-Host "Enter address for all common ports"
    Foreach ($port in $ports)
    {
        $cn.Connect($adr, $port)
        If ($cn.Connected)
        {
            Write-Host "Port $port is open on $adr"
            $cn.Close()
        } Else {
            Write-Host "Port $port is closed on $adr"
        }    
    }
}
