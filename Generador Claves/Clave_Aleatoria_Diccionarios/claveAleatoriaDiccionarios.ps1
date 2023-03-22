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
Write-Host $clave```