$TicketYear = Read-Host "Issue Year (Ex. 2021)"
$TicketMonth = Read-Host "Issue Month (Ex. 1,2,3...12)"
$TicketMonth = ($TicketMonth -replace '^0+', '')
$TicketDay = Read-Host "Issue Day (Ex. 1,2,3...12)"
$TicketDay = ($TicketDay -replace '^0+', '')
$Search0 = Read-Host "What to Search (Ex. a3771209)"
$Search = -join("*",$Search0,"*")

$Origenes = @('\\server1\recordedsoundfiles\','\\server2\recordedsoundfiles\','\\server1\archivedsoundfiles\','\\server2\archivedsoundfiles\')

$Log = -join ($TicketYear,'-',$TicketMonth,'-',$TicketDay,'-Searched-',$Search0,'.txt')
$LogDir = -join ("C:\Install\")
$LogFile = -join ($LogDir,"\",$Log)

New-Item -ItemType file -Path $LogDir -Name $Log | Out-Null

ForEach($Origen in $Origenes){
    $Origen = -join ($Origen,$TicketYear,'\',$TicketMonth,'\',$TicketDay)
    Write-Host $Origen
    $Files = Get-ChildItem -Recurse $Origen | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name

    ForEach ($File in $Files){
        If($File -like $Search){
            Write-Host $File.Name
            Add-Content $LogFile -value $File.Name
        }
    }
}