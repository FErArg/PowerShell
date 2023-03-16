<#
 Control list of localhost services declared in $Services, check status, if service is stopped, force to start again

 Execute de PS script as Domain Administrator
#>

$Services = ('APS01','ACD01','Trace01')
ForEach ($Service in $Services){
    $ServiceStatus = (get-service $Service)
    If($ServiceStatus.status -eq "Running"){
        Write-Host "Service: " $ServiceStatus.Name - "Status: " $ServiceStatus.Status -f Green
        Start-Sleep 1
    } else {
        Write-Host "Service: " $ServiceStatus.Name - "Status: " $ServiceStatus.Status -f Red
        Write-Host "Force start service" -f Green
        Start-Service -Name "$Service"
        Start-Sleep 3
        $ServiceStatus = (get-service $Service)
        Write-Host "Service: " $ServiceStatus.Name - "Status: " $ServiceStatus.Status -ForegroundColor Yellow
    }
}