param($user)
$processes = Get-Process -IncludeUserName | ? { $_.UserName -eq $user } | Format-Table -AutoSize Id, UserName, ProcessName

if ($processes.length -eq 0) {
    Write-Host "No such user. Defaulting to current user."
    $user = "$env:USERDOMAIN\$env:USERNAME"
    # Doesn't yet show process list of current user
    Write-Host $user
} else {
    $processes
}