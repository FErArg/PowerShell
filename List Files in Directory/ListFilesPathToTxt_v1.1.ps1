$Origen = "\\server1\recordedsoundfiles\2022\1"
$DataToCompare = "texto_to_compare"
$Date2 = Get-Date -Format "yyyy-MM-dd_hh.mm.ss"
$Log = -join ($Date2,".txt")
$LogDir = -join ("C:\Install\")
$LogFile = -join ($LogDir,"\",$Log)

$Files = Get-ChildItem -Recurse $Origen | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name

ForEach ($File in $Files){
    If($File -match $DataToCompare){
        Write-Host $File.Name
        Add-Content $LogFile -value $File.Name
    }
}