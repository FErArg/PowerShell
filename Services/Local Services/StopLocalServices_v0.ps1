<#

 Execute de PS script as Domain Administrator

#>

Clear-Host
Write-Host "================ Menu ================"
Write-Host "1: Press '1' for Stop MIS Services."
Write-Host "2: Press '2' for Stop SMTP Services."
Write-Host "0: Press '0' for Stop TEST Services."
Write-Host "Q: Press 'Q' to quit."

$selection = Read-Host "Please make a selection"
#If(Is-Numeric($selection) -eq "True"){
If(($selection -match '^[0-9]+$') -eq "True"){
    switch ($selection) {
        '1' {
            Write-Host "Stoping Services: MIS Services"
            $Services = @('RQM Recording','RQM Route Search Server','RQM Search Server','RQM2 Server','RQM MM Connect','RQN Service')
        } '2' {
            Write-Host "Stoping Services: SMTP Services"
            $Services = @('Cxe01','RQN Service','DRM','DRSM','DRT','LCS01','TC','RQM Route Search Server','RQM Common','RQN Service')
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
} else{
    Write-Host "not number"
}