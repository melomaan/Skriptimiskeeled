/* 
 * Script loops indefinitely asking about purchasing an elephant
 * without any regard to what the user inputs. This was our first
 * attempt at using PowerShell.
 */

$foo = "Wanna buy an elephant?"
$bar = "(Yes/No)"
Write-Host $foo

while ($true)
{
    $ans = Read-Host "$bar"
    Write-Host "Everybody says $ans, but do you" $foo.ToLower()
}
