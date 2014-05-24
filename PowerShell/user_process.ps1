/*
 * Script takes a domain name and user name as a single argument, and
 * returns the list of processes belonging to that certain set. Current
 * user is used should no parameter be given.
 */
param($user = "$env:USERDOMAIN\$env:USERNAME")
Get-Process -IncludeUserName | ? { $_.UserName -eq $user } | Format-Table
-AutoSize Id, UserName, ProcessName
