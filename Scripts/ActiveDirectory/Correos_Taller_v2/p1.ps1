#$Cred = (Get-Credential)
$cuenta = "jfer014"
$clave = "Iniciar465:Caliente"
#powershell Start-Process PowerShell -Verb runAS ntList "-Command Set-ADAccountPassword $cuenta -NewPassword (ConvertTo-SecureString -AsPlainText -String $clave -Force)" -Credential $Cred
#Powershell.exe -Command "& {Start-Process Powershell.exe -Verb RunAs}"
#powershell -Command 'Start-Process powershell -ArgumentList "-Command Set-ADAccountPassword $cuenta -NewPassword (ConvertTo-SecureString -AsPlainText -String $clave -Force)" -Verb RunAs'
powershell -Command 'Start-Process powershell -ArgumentList "-Command (Set-ADAccountPassword $cuenta -NewPassword (ConvertTo-SecureString -AsPlainText -String $clave -Force))" -Verb RunAs'
