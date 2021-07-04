$OUpath = 'OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$ExportPath = 'c:\temp\users_in_ou1.csv'
Get-ADUser -Filter * -SearchBase $OUpath | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $ExportPath
