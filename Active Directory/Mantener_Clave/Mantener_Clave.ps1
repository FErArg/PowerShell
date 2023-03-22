Import-Module ActiveDirectory

$LTars = @('ltar001', 'ltar002', 'ltar003', 'ltar006', 'ltar007', 'ltar008', 'ltar501', 'pcal002')
foreach ($ltar in $LTars){
    Write-Host $ltar
    Set-ADAccountPassword $ltar -NewPassword (ConvertTo-SecureString -AsPlainText -String "Levante!!000" -Force)
}

Write-Host "osop999"
Set-ADAccountPassword osop999 -NewPassword (ConvertTo-SecureString -AsPlainText -String "Valencia2k19@@9234" -Force)


$LRecs = @('lrec001', 'lrec003', 'lrec006', 'lrec501')
foreach ($lrec in $LRecs){
    Write-Host $lrec
    Set-ADAccountPassword $lrec -NewPassword (ConvertTo-SecureString -AsPlainText -String "Levante!!000" -Force)
}


$Otros = @('elev002', 'miguel.rozalen', 'carmen.lopez')
foreach ($Otro in $Otros){
    Write-Host $Otro
    Set-ADAccountPassword $Otro -NewPassword (ConvertTo-SecureString -AsPlainText -String "Valencia@123" -Force)
}