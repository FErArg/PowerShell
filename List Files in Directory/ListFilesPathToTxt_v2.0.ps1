$TicketYear = Read-Host "Issue Year (Ex. 2021)"

$Origen1 = -join ('\\server1\recordedsoundfiles\',$TicketYear,'\')
$Origen2 = -join ('\\server2\recordedsoundfiles\',$TicketYear,'\')
$Origenes = @($Origen1,$Origen2)
$Log = -join ($TicketYear,'.txt')
$LogDir = -join ("C:\Install\")
$LogFile = -join ($LogDir,"\",$Log)

New-Item -ItemType file -Path $LogDir -Name $Log | Out-Null

ForEach($Origen in $Origenes){
    Write-Host $Origen
    ForEach($i in 1..10){
        $Files = Get-ChildItem -Recurse $Origen | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name

        ForEach ($File in $Files){
            Write-Host $File.Name
            Add-Content $LogFile -value $File.Name
        }
    }
}