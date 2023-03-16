$Origen ="\\server1\recordedsoundfiles\2022\1"
$Date2 = Get-Date -Format "yyyy-MM-dd_hh.mm.ss"
$Log = -join ($Date2,".txt")
$LogDir = -join ("C:\Install\")
$LogFile = -join ($LogDir,"\",$Log)

$Files = Get-ChildItem -Recurse $Origen | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name

ForEach ($File in $Files){
    Write-Host $File.Name
    Add-Content $LogFile -value $File.Name
}