# Get-ADUser -filter * -properties * | select Displayname, Givenname, Surname, Enabled, EmployeeNumber, EmailAddress, Department, StreetAddress, Title, Country, Office, employeeType, SID, @{Name="ManagerEmail";Expression={(get-aduser -property emailaddress $_.manager).emailaddress}}

$manager = Get-ADUser -Id frod006 -Properties Manager | select Manager
$manager = $manager.manager
#Write-Host $manager


#$email = Get-ADUser -Filter * -Properties email,@{$manager}
$email = Get-ADUser -Identity $manager -Properties *
Write-Host $email.mail


