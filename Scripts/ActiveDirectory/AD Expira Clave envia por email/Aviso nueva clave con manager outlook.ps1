#VARs

#Password expiry days
$expireindays = 7
$FechaLog = get-date -format yyyy-MM-dd_HH-mm-ss-ff
$DirPath = 'C:\Users\frod006\OneDrive - Porsche Holding Salzburg\Logs\Avisos_Caducidad_Talleres'
$LogFile = $DirPath + "\" + $FechaLog + "_" + "Log.txt"
$Date = Get-Date

#Set OU
$OUpath0 = 'OU=TALLER,OU=POSTVENTA,OU=CID,OU=03334_VW,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath1 = 'OU=TALLER,OU=POSTVENTA,OU=CID,OU=0A311_SE,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath2 = 'OU=TALLER,OU=POSTVENTA,OU=30082_VW,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath3 = 'OU=TALLER,OU=POSTVENTA,OU=30083_VW,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath4 = 'OU=TALLER,OU=POSTVENTA,OU=QUART,OU=51A41_AU,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath5 = 'OU=TALLER,OU=POSTVENTA,OU=SEDAVI,OU=51A42_AU,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath6 = 'OU=TALLER,OU=Manises,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'
$OUpath7 = 'OU=PS222,OU=Levante,OU=Concesiones,DC=VGRS,DC=local'


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
		$_ | Out-File ($LogFile) -Append
	}
}

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
"$Date - INFO: Importing AD Module" | Out-File ($LogFile) -Append
Import-Module ActiveDirectory
"$Date - INFO: Getting users" | Out-File ($LogFile) -Append

$OUs = @($OUpath0, $OUpath1, $OUpath2, $OUpath3, $OUpath4, $OUpath5, $OUpath6, $OUpath7)

# ForEach cada OU
foreach ($ou in $OUs){
	$users = Get-Aduser -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress -SearchBase $ou -filter { (Enabled -eq 'True') -and (PasswordNeverExpires -eq 'False') } | Where-Object { $_.PasswordExpired -eq $False }

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
				$_ | Out-File ($LogFile) -Append
			}
			If (!($emailaddress))
			{
				Write-Host "$Name has no email addresses to send an e-mail to!" -ForegroundColor Red
				#Don't continue on as we can't email $Null, but if there is an e-mail found it will email that address
				"$Date - WARNING: No email found for $Name" | Out-File ($LogFile) -Append
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
			# busca email de manager
			$manager = Get-ADUser -Id $user -Properties Manager | select Manager
			$manager = $manager.manager
			$managerEmail = Get-ADUser -Identity $manager -Properties *
			$managerEmailFiltrado = $managerEmail.mail
		
			"$Date - INFO: Sending expiry notice email to $Name" | Out-File ($LogFile) -Append
			Write-Host "Sending Password expiry email to $name" -ForegroundColor Yellow
			
			$outlook = new-object -comobject outlook.application
			$email = $outlook.CreateItem(0)
			$email.To = "fernando.rodriguez.ext@vwgroupretail.es"
			# $email.To = $emailaddress
			# $email.Cc = "soporte.levante@vwgroupretail.es, $managerEmailFiltrado" 
			$email.Subject = "$Name - Aviso de Nueva Clave del Correo"
			$email.Body = "Buenas $Name,
			
			manager email $managerEmailFiltrado

	Su clave de usuario/email expira en $daystoexpire días.

	Actualiza la clave o contacta con el departamento IT para que te ayude a actualizarla lo antes posible.

	Para asistencia t�cnica, utilice siempre el Formulario Contacto - https://bit.ly/3lTg7xS 


	Atentamente,

	Fernando A. Rodr�guez Mallou
	Servicio IT Externo

	Mvl +34 659 69 20 48
	Ext 2973
	fernando.rodriguez.ext@vwgroupretail.es
	soporte.levante@vwgroupretail.es
	" 
					
			Write-Host "Sending E-mail to $emailaddress..." -ForegroundColor Green
			Try
			{
				$email.Send()
			}
			Catch
			{
				$_ | Out-File ($LogFile) -Append
			}
		}
		Else
		{
			"$Date - INFO: Password for $Name not expiring for $daystoexpire days" | Out-File ($LogFile) -Append
			Write-Host "Password for $Name does not expire for $daystoexpire days" -ForegroundColor White
		}
	}
}

<#
$outlook = new-object -comobject outlook.application
$email = $outlook.CreateItem(0)
$email.To = "it-levante@vwgroupretail.es"
$email.Cc = "soporte.levante@vwgroupretail.es"
$email.Subject = "$FechaLog - Detalle Avisos de Contrase�as pr�ximas a Caducar"
$email.Attachments.add($LogFile)
$email.Body = "Buenas,

Adjunto Logs de env��o de correo de Aviso de Contrase�a pr�xima a Caducar"
$email.Send()
#>