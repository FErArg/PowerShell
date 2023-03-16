<# 
 Create backup of Company1 and Company0 folders stored in "Program Data" in remote servers

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
 - check if origin folder exist -> "\\SERVER\C$\PROGRAM DATA\Company1"
 - check if can create backup folder -> "\\SERVER\C$\PROGRAM DATA\Company1-2022-08-01_20.50.00"
 - Copy Origin folder content to backup folder
 
 Save logs in local folder Ex. "C:\Install\Log\2022-08-01\2022-08-01.20.50.00-bkp.log"

 Execute de PS script as Domain Administrator
#>

$Servers = (Import-Csv -Path C:\Install\Servers.csv).IPAddress
# $Servers = @('192.168.51.1','192.168.51.11','192.168.51.12','192.168.51.13')
$Folders = @('Company0','Company1')
$Date1 = Get-Date -Format "yyyy-MM-dd"
$Date2 = Get-Date -Format "yyyy-MM-dd_hh.mm.ss"
$Log = -join ($Date2,"-bkp.log")
$LogDir = -join ("C:\Install\Log\",$Date1)
$LogFile = -join ($LogDir,"\",$Log)

If (Test-Path -Path $LogDir) {
    New-Item -ItemType file -Path $LogDir -Name $Log
} Else {
    New-Item -ItemType directory -Path $LogDir
    New-Item -ItemType file -Path $LogDir -Name $Log
}

ForEach ($Server in $Servers) {
    $PingResponse = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Server -Quiet
    If ($PingResponse -eq "TRUE"){
        Add-Content $LogFile -value "Server $Server is ONLINE"
        Add-Content $LogFile -value ""
        ForEach ($Folder in $Folders) {
            $Origin = -join ("\\",$Server,"\C$\","Program Files","\",$Folder)
            $Backup = -join ("\\",$Server,"\C$\",'Program Files',"\",$Folder,"-",$Date2)
            If (Test-Path -Path $Origin) {
                Add-Content $LogFile -value "- Folder $Folder EXIST"
                New-Item -ItemType directory -Path $Backup
                Start-Sleep -Seconds 2
                If (Test-Path -Path $Backup) {
                    Add-Content $LogFile -value "-- Created backup folder $Backup"
                    Copy-Item $Origin/* -Destination $Backup/ -Recurse
                    Start-Sleep -Seconds 1
                    Add-Content $LogFile -value "--- Copy from $Origin to $Backup"
                    Add-Content $LogFile -value ""
                } Else {
                    Add-Content $LogFile -value "-- Can't create backup folder $Backup"
                    Add-Content $LogFile -value ""
                }
            } Else{
                Add-Content $LogFile -value "- Folder $Folder DO NOT EXIST"
                Add-Content $LogFile -value ""
            }
        }
    } Else {
        Add-Content $LogFile -value "Server $Server is OFFLINE"
        Add-Content $LogFile -value ""
    }
}