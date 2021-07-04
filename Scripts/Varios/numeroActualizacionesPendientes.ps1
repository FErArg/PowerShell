$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateupdateSearcher()
$Updates = @($UpdateSearcher.Search("IsInstalled=0").Updates)

#This will give the number of updates yet to install.
$actualizaciones = $Updates.Title.count 

Write-Host "Actualizaciones pendientes" $actualizaciones