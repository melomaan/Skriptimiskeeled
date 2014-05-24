/*
 * Script takes a domain name and user name as a single argument, and
 * returns the list of processes belonging to that certain set. If none
 * is given, then current user is used.
 */
param($user = "$env:USERDOMAIN\$env:USERNAME")
Get-Process -IncludeUserName | ? { $_.UserName -eq $user } | Format-Table
-AutoSize Id, UserName, ProcessName