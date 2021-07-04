# Add a parameter called username.
 param (
     $username
 )
 # If the user did not provide a username value, show a message and exit the script.
 if (-not($username)) {
     Write-Host "You did not enter a username. Exiting script"
     return $null
 }
 # Check if the user exists or if the username is valid. Do not show the result on the screen.
 try {
     $null = Get-ADUser -Identity $username -ErrorAction Stop
 }
 # If the username cannot be found, show a message and exit the script.
 catch {
     Write-Host $_.Exception.Message
     return $null
 }
 # Generate a random password that is 12-characters long with five non-AlphaNumeric characters.
 $randomPassword = [System.Web.Security.Membership]::GeneratePassword(12, 5)
 # Convert the plain text password to a secure string.
 $newPassword = $randomPassword | ConvertTo-SecureString -AsPlainText -Force
 # Try to reset the user's password
 try {
     # Reset the user's password
     Set-ADAccountPassword -Identity $username -NewPassword $newPassword -Reset -ErrorAction Stop
     # Force the user to change password during the next log in
     Set-ADuser -Identity $username -ChangePasswordAtLogon $true
     # If the password reset was successfull, return the username and new password.
     [pscustomobject]@{
         Username = $username
         NewPassword = $randomPassword
     }
 }
 # If the password reset failed, show a message and exit the script.
 catch {
     Write-Host "There was an error performing the password reset. Please consult the error below."
     Write-host $_.Exception.Message
     return $null
 }
