$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "Software Name" 
}

$app.Uninstall()


$app = Get-WmiObject -Class Win32_Product `
                     -Filter "Name = 'Software Name'"
$app.Uninstall()
