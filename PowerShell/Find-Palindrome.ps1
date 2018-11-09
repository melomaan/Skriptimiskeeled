ForEach ($Word in $(Get-Content ~\words.txt)) {
    $Drow = $Word.ToLower() -split ''
    [Array]::Reverse($Drow)
    $Drow = $Drow -join ''

    If ($Word.ToLower() -eq $Drow) {
        Write-Output "$Word is a palindrome"
    }
}
