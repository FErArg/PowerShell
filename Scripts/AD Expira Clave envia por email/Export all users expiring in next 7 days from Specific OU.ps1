$OUpath = 'OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -SearchBase $OUpath –Properties "DisplayName", "mail", "msDS-UserPasswordExpiryTimeComputed" | where { 
$diff = New-TimeSpan ([datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")) (Get-Date)
$diff.Days -le 7 -and $diff.Days -ge 0
} | select "DisplayName","mail",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Export-csv -Path c:\temp\user_pass_expiring_from_ou.csv
