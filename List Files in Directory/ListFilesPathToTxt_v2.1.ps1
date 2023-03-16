$TicketYear = Read-Host "Issue Year (Ex. 2021)"
$TicketMonth = Read-Host "Issue Month (Ex. 1,2,3...12)"

$Origen1 = -join ('\\server1\recordedsoundfiles\',$TicketYear,'\',$TicketMonth)
$Origen2 = -join ('\\server2\recordedsoundfiles\',$TicketYear,'\',$TicketMonth)
$Origenes = @($Origen1,$Origen2)
# $Date2 = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"
$Log = -join ($TicketYear,'-',$TicketMonth,'.txt')
$LogDir = -join ("C:\Install\")
$LogFile = -join ($LogDir,"\",$Log)

New-Item -ItemType file -Path $LogDir -Name $Log | Out-Null

ForEach($Origen in $Origenes){
    Write-Host $Origen
    $Files = Get-ChildItem -Recurse $Origen | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name

    ForEach ($File in $Files){
        Write-Host $File.Name
        Add-Content $LogFile -value $File.Name
    }
}