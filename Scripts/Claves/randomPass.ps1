[string[]]$palabras = Get-Content -Path 'palabras.txt'
[string[]]$numeros = Get-Content -Path 'numeros.txt'
[string[]]$simbolos = Get-Content -Path 'simbolos.txt'

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
Write-Host $clave

$usuario = Read-Host -Prompt 'Usuario del AD'

Add-Type -AssemblyName 'System.Web'
$nuevaClave = $clave | ConvertTo-SecureString -AsPlainText -Force


$outlook = new-object -comobject outlook.application
$email = $outlook.CreateItem(0)
$email.To = "fernando.rodriguez.ext@vwgroupretail.es"
$email.Cc = "soporte.levante@vwgroupretail.es" 
$email.Subject = "$Name - Aviso de Contraseña próxima a Caducar"
$email.Body = "Buenas,
			
	Nueva clave:
    
    USUARIO; $usuario
    CLAVE: $clave
    
	Para asistencia t�cnica, utilice siempre el Formulario Contacto - https://bit.ly/3lTg7xS 
	
    Atentamente,
	
    Fernando A. Rodríguez Mallou
	Servicio IT Externo
	Mvl +34 659 69 20 48
	Ext 2973
	fernando.rodriguez.ext@vwgroupretail.es
	soporte.levante@vwgroupretail.es
	" 
					
$email.Send()

start powershell Set-ADAccountPassword -Identity $usuario -NewPassword $nuevaClave -Reset -credential ""
