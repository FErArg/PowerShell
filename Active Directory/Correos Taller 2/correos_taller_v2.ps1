#VARs
[string[]]$palabras = Get-Content -Path 'palabras.txt'
[string[]]$numeros = Get-Content -Path 'numeros.txt'
[string[]]$simbolos = Get-Content -Path 'simbolos.txt'

# PARA EJECUTAR COMO ADMIN
$Cred = (Get-Credential)


#Password expiry days
$expireindays = 7
$FechaLog = get-date -format yyyy-MM-dd_HH-mm-ss-ff
$DirPath = 'C:\Users\fr006\Avisos_Caducidad'
$LogFile = $DirPath + "\" + $FechaLog + "_" + "Log.txt"
$Date = Get-Date

#Set OU
$OUpath0 = 'OU=TALLER,OU=POSTVENTA,OU=MAD,OU=0334_VW,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath1 = 'OU=TALLER,OU=POSTVENTA,OU=MAD,OU=0A11_SE,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath2 = 'OU=TALLER,OU=POSTVENTA,OU=382_VW,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath3 = 'OU=TALLER,OU=POSTVENTA,OU=383_VW,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath4 = 'OU=TALLER,OU=POSTVENTA,OU=LEIO,OU=5141_AU,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath5 = 'OU=TALLER,OU=POSTVENTA,OU=MAL,OU=5142_AU,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath6 = 'OU=TALLER,OU=Manises,OU=team,OU=shop,DC=FERARG,DC=local'
$OUpath7 = 'OU=PS222,OU=team,OU=shop,DC=FERARG,DC=local'


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

$OUs = @($OUpath0, $OUpath1, $OUpath2, $OUpath3, $OUpath4, $OUpath5, $OUpath6)

# ForEach cada OU
foreach ($ou in $OUs){
    $users = Get-Aduser -properties Name, SamAccountName, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress -SearchBase $ou -filter { (Enabled -eq 'True') -and (PasswordNeverExpires -eq 'False') } | Where-Object { $_.PasswordExpired -eq $False }

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
        $cuenta = $user.SamAccountName

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
            
            # Genera clave alearia basado en diccionarios
            Clear-Variable -Name "clave"
            For ($i=1; $i -lt 3; $i++){
                <# Write-Host $i #>
                if( $i -Eq '2'){
                    $item=(Get-Random -Maximum ([array]$numeros).count)
                    $numero=$numeros[$item]
                    $clave += $numero
                    <# Write-Host $numero #>
                }
                if( $i -Eq '2'){
                    $item=(Get-Random -Maximum ([array]$simbolos).count)
                    $simbolo=$simbolos[$item]
                    $clave += $simbolo
                    <# Write-Host $numero #>
                }
                $item=(Get-Random -Maximum ([array]$palabras).count)
                $palabra=$palabras[$item]
                $clave += $palabra
            }

            "$Date - INFO: Sending expiry notice email to $Name" | Out-File ($LogFile) -Append
            Write-Host "Sending Password expiry email to $name" -ForegroundColor Yellow
            
            $outlook = new-object -comobject outlook.application
            $email = $outlook.CreateItem(0)
            $email.To = "ferarg@ferarg.com"
            $email.Subject = "$Name - Aviso de Nueva Clave del Correo Corporativo"
            $email.Body = "Buenas $Name,
            
Se envía aviso al jefe de taller para que le avise.

Su clave de usuario/email estaba por expirar en $daystoexpire días.

Su usuario: $cuenta
Su nueva clave es: $clave

Para asistencia técnica, utilice siempre el Formulario Contacto 


Atentamente,
            " 
                    
            Write-Host "Sending E-mail to $emailaddress..." -ForegroundColor Green
            Try
            {
                $email.Send()

                #Cambio Clave en AD
                Start-Process -FilePath "powershell.exe" -ArgumentList "-Command Set-ADAccountPassword $cuenta -NewPassword (ConvertTo-SecureString -AsPlainText -String $clave -Force)" -Credential $Cred
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
