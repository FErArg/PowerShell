Add-Type -AssemblyName 'System.Web'

$minLength = 5 ## characters
$maxLength = 10 ## characters
$length = Get-Random -Minimum $minLength -Maximum $maxLength
$nonAlphaChars = 5
$password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)

Write-Host $password