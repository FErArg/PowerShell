<# 
 Create backup of Company1 and Company0 folders stored in "Program Data" in remote servers

 Check if server is online from a list of
 - Check if server is online 
 - check if origin folder exist -> "\\SERVER\C$\PROGRAM DATA\Company1"
 - check if can create backup folder -> "\\SERVER\C$\PROGRAM DATA\Company1-Backup-01.ago.22"
 - Copy Origin folder content to backup folder
 - Show a Info Green line if the file was copied
 - Show a Info RED line if the file was not copied
 
 Execute de PS script as Domain Administrator

#>

$Servers = @('192.168.51.1','192.168.51.11','192.168.51.12','192.168.51.13')
$Folders = @('Company0','Company1')

# Don't touch -------------------------------------
$Date2 = Get-Date -Format "dd.MMMyy"

ForEach ($Server in $Servers) {
    $PingResponse = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Server -Quiet
    If ($PingResponse -eq "TRUE"){
        Write-Host "Server $Server is ONLINE" -ForegroundColor Green
        ForEach ($Folder in $Folders) {
            $Origin = -join ("\\",$Server,"\C$\Program Files\",$Folder)
            $Backup = -join ("\\",$Server,"\C$\Program Files\",$Folder,"-",$Date2)
            If (Test-Path -Path $Origin) {
                Write-Host "- Folder $Folder EXIST" -ForegroundColor Yellow
                New-Item -ItemType directory -Path $Backup | Out-Null
                Start-Sleep -Seconds 2
                If (Test-Path -Path $Backup) {
                    Write-Host "-- Created backup folder $Backup" -ForegroundColor Green
                    $OriginFiles = Get-ChildItem -Recurse $Origin | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name
                    Foreach ($OriginFile in $OriginFiles){
                        $FileName = $OriginFile.Name
                        $FilePath = $OriginFile.Fullname.Replace($FileName,'')
                        $FilePath = $FilePath.Replace($Origin,'')
                        New-Item -ItemType "directory" -Path $Backup$FilePath -Force | Out-Null
                        Copy-Item $Origin$FilePath$FileName -Destination $Backup$FilePath$FileName -Force | Out-Null
                        if((Test-Path -Path $Backup$FilePath$FileName) -eq 'True'){
                            Write-Host "Backup: "$Backup$FilePath$FileName -ForegroundColor Green
                        } else {
                            Write-Host "Error: "$Backup$FilePath$FileName -ForegroundColor Red
                        }
                    }
                    Start-Sleep -Seconds 1
                } Else {
                    Write-Host "-- Can't create backup folder $Backup" -ForegroundColor Red
                }
            } Else{
                Write-Host "- Folder $Folder DO NOT EXIST" -ForegroundColor Red
            }
        }
    } Else {
        Write-Host "Server $Server is OFFLINE" -ForegroundColor Red
    }
}