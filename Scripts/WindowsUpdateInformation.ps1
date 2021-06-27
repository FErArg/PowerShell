function Get-WindowsUpdateInformation()
 {
     param
     (
         [Parameter()]
         [string[]]
         $ComputerName="localhost"
     )


     $Results = Invoke-Command -ScriptBlock  {     
         $result = (New-Object -com "Microsoft.Update.AutoUpdate").Results     
         $UpdateSession = New-Object -ComObject Microsoft.Update.Session     
         $UpdateSearcher = $UpdateSession.CreateupdateSearcher()     
         $Updates = @($UpdateSearcher.Search("IsInstalled=0").Updates)     
         $PendingReboot = $false     
    
         #Checking pending reboot
         if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { $PendingReboot=$true }     
   
         #Framing the result to a list
         New-Object psobject -Property @{         
              LastSearchSuccessDate = $result.LastSearchSuccessDate         
              LastInstallationSuccessDate = $result.LastInstallationSuccessDate         
              NewUpdateCount = $Updates.Title.count         
              PendingReboot = $PendingReboot     
         } 
     } -ComputerName $ComputerName 

     $Results | Select-Object @{Name="ServerName"; Expression={$_.PSComputerName}}, LastSearchSuccessDate, LastInstallationSuccessDate, NewUpdateCount, PendingReboot
 }
 
 Get-WindowsUpdateInformation -ComputerName FErArg-NB