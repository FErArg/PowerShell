#Busca usuarios inactivos en los �ltimos 60 d�as en la OU especificada
$When = ((Get-Date).AddDays(-60)).Date
$ou = 'OU=Levante,OU=Concesiones,DC=FERARG,DC=local'
Get-ADUser -Filter {LastLogonDate -lt $When} -Properties * -SearchBase $ou | select-object samaccountname,givenname,surname,LastLogonDate```