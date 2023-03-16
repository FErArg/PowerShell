<# 
 Copy from local folder content to remote server folder

 Use external file with server list, CSV file, can use Server IP or Server Name
 Ex. Servers.csv content: (one column) with header "IPAddress":
 IPAddress,
 192.168.1.1,
 192.168.1.2,
 192.168.1.3,
 VAW10011,
 192.168.1.24,

 Check if server is online from a list of
 - Check if server is online 
 - check if Local folder exist -> "\\SERVER\C$\INSTALL"
 - check if can create remote folder -> "\\SERVER\C$\INSTALL\company_21.04_2022-08-01_20.50.00"
 - Copy local folder content to remote folder
 
 Save logs in local folder Ex. "C:\Install\Log\2022-08-01\2022-08-01_20.50.00-copy-soft.log"

 Execute de PS script as Domain Administrator

#>

# Personalize PATH, Server List, Version & LocalFolder
$Servers = (Import-Csv -Path C:\Install\Servers.csv).IPAddress
# $Servers = @('192.168.1.1','192.168.1.2','192.168.1.3','192.168.1.24')

$Folder = "INSTALL"
$Version = "21.04"
$LocalFolder = "C:\INSTALL\NewVersion"

# Change if you know
$Date1 = Get-Date -Format "yyyy-MM-dd"
$Date2 = Get-Date -Format "yyyy-MM-dd_hh.mm.ss"
$Log = -join ($Date2,"-copy-soft.log")
$LogDir = -join ("C:\Install\Log\",$Date1)
$LogFile = -join ($LogDir,"\",$Log)


If (Test-Path -Path $LogDir) {
    New-Item -ItemType file -Path $LogDir -Name $Log
} Else {
    New-Item -ItemType directory -Path $LogDir
    New-Item -ItemType file -Path $LogDir -Name $Log
}

If (Test-Path -Path $LocalFolder) {
    Add-Content $LogFile -value "- Local Folder $LocalFolder EXIST"
    Add-Content $LogFile -value ""
    ForEach ($Server in $Servers) {
        Write-Host "Server: $Server"
        $PingResponse = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Server -Quiet
        If ($PingResponse -eq "TRUE"){
            Write-Host "- Server $Server is ONLINE"
            Add-Content $LogFile -value "Server $Server is ONLINE"
            $RemoteFolder = -join ("\\",$Server,'\C$\',$Folder,"\company\company_",$Version,'_',$Date2)
            New-Item -ItemType directory -Path $RemoteFolder
            Start-Sleep -Seconds 1
            If (Test-Path -Path $RemoteFolder) {
                Write-Host "-- Created remote folder $RemoteFolder"
                Add-Content $LogFile -value "-- Created remote folder $RemoteFolder"
                Copy-Item $LocalFolder/* -Destination $RemoteFolder/
                Start-Sleep -Seconds 2
                Write-Host "--- Copied content from $LocalFolder to $RemoteFolder"
                Add-Content $LogFile -value "--- Copied content from $LocalFolder to $RemoteFolder"
                Add-Content $LogFile -value ""
            } Else {
                Write-Host "-- Can't create remote folder $RemoteFolder"
                Add-Content $LogFile -value "-- Can't create remote folder $RemoteFolder"
                Add-Content $LogFile -value ""
            }
        } Else {
            Write-Host "- Server $Server is OFFLINE"
            Add-Content $LogFile -value "Server $Server is OFFLINE"
            Add-Content $LogFile -value ""
        }
    }
} Else {
    Write-Host "----- Local $LocalFolder folder NOT EXIST, (can't copy local files to remote server -----"
    Add-Content $LogFile -value "----- Local $LocalFolder folder NOT EXIST, (can't copy local files to remote server -----"
    Add-Content $LogFile -value ""
}