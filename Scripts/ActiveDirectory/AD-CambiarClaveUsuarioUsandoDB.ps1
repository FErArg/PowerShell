<#
Let’s consider another case. Suppose, you have a CSV / Excel file that contains a list of users you want to reset passwords of and set a unique password for every user. Here is the format of the users.csv file:

sAMAccountName;NewPassword
acidicjustine;Pa$$w0r1
josephomoore;N$isory01
simonecole;k@32d3!2

Using this PowerShell script, you can reset a password of each account in the specified csv file:
#>
Import-Csv users.csv -Delimiter ";" | Foreach {
$NewPass = ConvertTo-SecureString -AsPlainText $_.NewPassword -Force
Set-ADAccountPassword -Identity $_.sAMAccountName -NewPassword $NewPass -Reset -PassThru | Set-ADUser -ChangePasswordAtLogon $false
}
