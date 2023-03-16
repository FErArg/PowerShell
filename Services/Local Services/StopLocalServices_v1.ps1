<#
 1- Select in which kind of server you need to stop services
 2- Get de WMI Object based on service name
 3- Try to stop Service
 3.1- If can stop service GREEN message explain it
 3.2- If can't stop service RED message explain it


 Execute de PS script as Domain Administrator

#>

Clear-Host
Write-Host "================ Menu ================"
Write-Host "1: Press '1' for Stop MIS Server."
Write-Host "2: Press '2' for Stop TOM Server."
Write-Host "3: Press '3' for Stop CNE Server."
Write-Host "0: Press '0' for Stop TEST."
Write-Host "Q: Press 'Q' to quit."
Write-Host ""
$selection = Read-Host "Please make a selection"

switch ($selection){
    '1' {
        Write-Host "Stoping Services: GIS Server"
        $Services = @('RQM RecordingServer','RQM CR Search Server','RQM ROI Service','RQM CSS','RQM2 Server','RQM MM Connect','RQN Service')
    } '2' {
        Write-Host "Stoping Services: COM Server"
        $Services = @('DRM','DRSM','DRT','LCS01','TC01','RQM CR Search Server','RQM CSS','RQN Service')
    } '3' {
        Write-Host "Stoping Services: CXE Server"
        $Services = @('CTV','RQN Service','FCT01','TC01')
    } '0' {
        Write-Host "Stoping Services: TEST Services"
        $Services = @('RpcEptMapper','Audiosrv')    
    } 'q' {
        return
    }
}
ForEach ($Service in $Services){
    $svc_Obj = Get-WmiObject Win32_Service -filter "name='$Service'"
    $StopStatus = $svc_Obj.StopService() 
    If ($StopStatus.ReturnValue -eq "0") {
        Write-host "The service '$Service' Stopped successfully" -f Green
    } Else {
        Write-host "Failed to Stop the service '$Service'. Error code: $($StopStatus.ReturnValue)" -f Red
    }
}