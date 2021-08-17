#VARs

#SMTP Host
$SMTPHost = "smtp.office365.com"
#Who is the e-mail from
$FromEmail = "fernando.rodriguez.ext@vwgroupretail.es"
#Password expiry days
$expireindays = 7

#Program File Path
$DirPath = "C:\PS\PasswordExpiry"

#Set OU
$OUpath = 'OU=Levante,OU=Concesiones,DC=VGRS,DC=local'

$Date = Get-Date
#Check if program dir is present
$DirPathCheck = Test-Path -Path $DirPath
If (!($DirPathCheck))
{
	Try
	{
		#If not present then create the dir
		New-Item -ItemType Directory $DirPath -Force
	}
	Catch
	{
		$_ | Out-File ($DirPath + "\" + "Log.txt") -Append
	}
}
#CredObj path
$CredObj = ($DirPath + "\" + "EmailExpiry.cred")
#Check if CredObj is present
$CredObjCheck = Test-Path -Path $CredObj
If (!($CredObjCheck))
{
	"$Date - INFO: creating cred object" | Out-File ($DirPath + "\" + "Log.txt") -Append
	#If not present get office 365 cred to save and store
	$Credential = Get-Credential -Message "Please enter your Office 365 credential that you will use to send e-mail from $FromEmail. If you are not using the account $FromEmail make sure this account has 'Send As' rights on $FromEmail."
	#Export cred obj
	$Credential | Export-CliXml -Path $CredObj
}

Write-Host "Importing Cred object..." -ForegroundColor Yellow
$Cred = (Import-CliXml -Path $CredObj)


# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
"$Date - INFO: Importing AD Module" | Out-File ($DirPath + "\" + "Log.txt") -Append
Import-Module ActiveDirectory
"$Date - INFO: Getting users" | Out-File ($DirPath + "\" + "Log.txt") -Append
$users = Get-Aduser -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress -SearchBase $OUpath -filter { (Enabled -eq 'True') -and (PasswordNeverExpires -eq 'False') } | Where-Object { $_.PasswordExpired -eq $False }

$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
	$Name = (Get-ADUser $user | ForEach-Object { $_.Name })
	Write-Host "Working on $Name..." -ForegroundColor White
	Write-Host "Getting e-mail address for $Name..." -ForegroundColor Yellow
	$emailaddress = $user.emailaddress
	If (!($emailaddress))
	{
		Write-Host "$Name has no E-Mail address listed, looking at their proxyaddresses attribute..." -ForegroundColor Red
		Try
		{
			$emailaddress = (Get-ADUser $user -Properties proxyaddresses | Select-Object -ExpandProperty proxyaddresses | Where-Object { $_ -cmatch '^SMTP' }).Trim("SMTP:")
		}
		Catch
		{
			$_ | Out-File ($DirPath + "\" + "Log.txt") -Append
		}
		If (!($emailaddress))
		{
			Write-Host "$Name has no email addresses to send an e-mail to!" -ForegroundColor Red
			#Don't continue on as we can't email $Null, but if there is an e-mail found it will email that address
			"$Date - WARNING: No email found for $Name" | Out-File ($DirPath + "\" + "Log.txt") -Append
		}
		
	}
	#Get Password last set date
	$passwordSetDate = (Get-ADUser $user -properties * | ForEach-Object { $_.PasswordLastSet })
	#Check for Fine Grained Passwords
	$PasswordPol = (Get-ADUserResultantPasswordPolicy $user)
	if (($PasswordPol) -ne $null)
	{
		$maxPasswordAge = ($PasswordPol).MaxPasswordAge
	}
	
	$expireson = $passwordsetdate + $maxPasswordAge
	$today = (get-date)
	#Gets the count on how many days until the password expires and stores it in the $daystoexpire var
	$daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
	
	If (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
	{
		"$Date - INFO: Sending expiry notice email to $Name" | Out-File ($DirPath + "\" + "Log.txt") -Append
		Write-Host "Sending Password expiry email to $name" -ForegroundColor Yellow
		
		$SmtpClient = new-object system.net.mail.smtpClient
		$MailMessage = New-Object system.net.mail.mailmessage
		
		#Who is the e-mail sent from
		$mailmessage.From = $FromEmail
		#SMTP server to send email
		$SmtpClient.Host = $SMTPHost
		#SMTP SSL
		$SMTPClient.EnableSsl = $true
		#SMTP credentials
		$SMTPClient.Credentials = $cred
		#Send e-mail to the users email
		$mailmessage.To.add("$emailaddress")
		#Email subject
		$mailmessage.Subject = "Su clave de usuario caduca en $daystoexpire días"
		#Notification email on delivery / failure
		$MailMessage.DeliveryNotificationOptions = ("onSuccess", "onFailure")
		#Send e-mail with high priority
		$MailMessage.Priority = "High"
		$mailmessage.Body =
		"Buenas $Name,
		
Tu clave de usuario/correo electrónico expira en $daystoexpire.

Actualiza la clave o contacta con el departamento IT para que te ayuden a actualizarla lo antes posible.

Para asistencia técnica, utilice siempre el Formulario Contacto - https://bit.ly/3lTg7xS 


Atentamente,

Fernando A. Rodríguez Mallou

Servicio IT Externo

Mvl +34 659 69 20 48
Ext 2973
fernando.rodriguez.ext@vwgroupretail.es
soporte.levante@vwgroupretail.es

"
		Write-Host "Sending E-mail to $emailaddress..." -ForegroundColor Green
		Try
		{
			$smtpclient.Send($mailmessage)
		}
		Catch
		{
			$_ | Out-File ($DirPath + "\" + "Log.txt") -Append
		}
	}
	Else
	{
		"$Date - INFO: Password for $Name not expiring for $daystoexpire days" | Out-File ($DirPath + "\" + "Log.txt") -Append
		Write-Host "Password for $Name does not expire for $daystoexpire days" -ForegroundColor White
	}
}
