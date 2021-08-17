$OUpath = 'OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$ExportPath = 'c:\temp\users_in_ou1.csv'

# Get-ADUser -Filter * -SearchBase $OUpath | Select-object Name,UserPrincipalName | Export-Csv -NoType $ExportPath

Get-ADUser -Filter * -SearchBase $OUpath -Properties * | Select-Object * | export-csv $ExportPath
