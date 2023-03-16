<#
 List services status running in remote server, one by one

 Execute de PS script as Domain Administrator

#>
# $Servers = @('192.168.51.1','192.168.51.11','192.168.51.12','192.168.51.13')
$Servers = @('L1-01','L1-02','L1-03')

$FAServices = @('Spool','Appinfo','BthAvctpSvc','ACD01','ALM01','ALT01','AOM01')

Clear-Host

ForEach ($Server in $Servers){
    $PingResponse = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Server -Quiet
    If ($PingResponse -eq "TRUE"){
        Write-Host "================ $Server ================" -f Green
        $Services = (Get-Service -ComputerName $Server | Sort-Object Name)
        ForEach ($Service in $Services){
            If($FAServices -match $Service){
                If($Service.status -eq "Running"){
                    Write-Host "Service: " $Service.Name - "Status: " $Service.Status -f Green
                    Write-Host "Stoping Services: $Service.Name"
                    (get-service -ComputerName $Server -Name $Service.Name).Stop()
                } else {
                    Write-Host "Service: " $Service.Name - "Status: " $Service.Status -f Red
                }
            }
        }
        Write-Host "===================================================" -f Green
        write-host ""
    } else {
        write-host ""
        write-host "Server $Server is OFFLINE" -f Yellow
        write-host ""
    }
}