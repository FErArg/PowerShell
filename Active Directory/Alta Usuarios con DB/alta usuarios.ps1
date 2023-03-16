# https://theitbros.com/import-users-into-active-directory-from-csv/

Import-Module ActiveDirectory

$Domain="@mrjeffapp.com"

# CSV Format
# FullName;givenName;sn;sAMAccountName;Password

$UserOu="OU=Plug&Play,OU=External,DC=mrjeffapp,DC=com"

$NewUsersList=Import-CSV "C:\PS\prueba.csv"

ForEach ($User in $NewUsersList) {

$FullName=$User.FullName

$givenName=$User.givenName

$sn=$User.sn

$sAMAccountName=$User.sAMAccountName

$userPrincipalName=$User.sAMAccountName+$Domain

$userPassword=$User.Password

$expire=$null

New-ADUser -PassThru -Path $UserOu -Enabled $True -ChangePasswordAtLogon $False -AccountPassword (ConvertTo-SecureString $userPassword -AsPlainText -Force) -CannotChangePassword $True -PasswordNeverExpires $True -DisplayName $FullName -GivenName $givenName -Name $FullName -SamAccountName $sAMAccountName -Surname $sn -UserPrincipalName $userPrincipalName

}