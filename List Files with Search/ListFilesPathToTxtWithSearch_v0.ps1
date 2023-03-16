$TicketYear = Read-Host "Issue Year (Ex. 2021)"
$TicketMonth = Read-Host "Issue Month (Ex. 1,2,3...12)"
$TicketDay = Read-Host "Issue Day (Ex. 1,2,3...12)"

$Origenes = @('\\server1\recordedsoundfiles\','\\server2\recordedsoundfiles\')
$Search = "ee461ec6"
# $Date2 = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"

$Log = -join ($TicketYear,'-',$TicketMonth,'-',$TicketDay,'.txt')
$LogDir = -join ("C:\Install\")
$LogFile = -join ($LogDir,"\",$Log)

New-Item -ItemType file -Path $LogDir -Name $Log | Out-Null

ForEach($Origen in $Origenes){
    $Origen = -join ($Origen,$TicketYear,'\',$TicketMonth,'\',$TicketDay)
    Write-Host $Origen
    $Files = Get-ChildItem -Recurse $Origen | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name

    ForEach ($File in $Files){
        if($File -like $Search){
            Write-Host $File.Name
            Add-Content $LogFile -value $File.Name
        }
        
    }
}