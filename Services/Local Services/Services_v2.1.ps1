<#
 Control list of localhost services declared in $Services, check status, if service is stopped, force to start again

 Execute de PS script as Domain Administrator
#>
$LogFile = "Services_v2.1.log"
$Date2 = Get-Date -Format "yyyy-MM-dd_HH.mm.ss"

$Services = ('APS01','ACD01','Trace01')

Add-Content $LogFile -value "$Date2"

ForEach ($Service in $Services){
    $ServiceStatus = (get-service $Service)
    If($ServiceStatus.status -eq "Running"){
        Write-Host "Service: " $ServiceStatus.Name - "Status: " $ServiceStatus.Status -f Green
        Add-Content $LogFile -value "Service: $($ServiceStatus.Name) - Status: $($ServiceStatus.Status)"
        Start-Sleep 1
    } else {
        Write-Host "Service: " $ServiceStatus.Name - "Status: " $ServiceStatus.Status -f Red
        Add-Content $LogFile -value "Service: $($ServiceStatus.Name) - Status: $($ServiceStatus.Status)"
        Write-Host "Force start service" -f Green
        Add-Content $LogFile -value "Force start service"
        Start-Service -Name "$Service"
        Start-Sleep 3
        $ServiceStatus = (get-service $Service)
        Write-Host "Service: " $ServiceStatus.Name - "Status: " $ServiceStatus.Status -ForegroundColor Yellow
        Add-Content $LogFile -value "Service: $($ServiceStatus.Name) - Status: $($ServiceStatus.Status)"
    }
}