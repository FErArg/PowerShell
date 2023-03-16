<# 
 Copy from local folder content to remote server folder
 Check if server is online from a list of
 - Check if server is online 
 - check if Local folder exist -> "\\SERVER\C$\INSTALL"
 - check if can create remote folder -> "\\SERVER\C$\INSTALL\company_21.04"
 - Copy local folder content to remote folder
 
  Execute de PS script as Domain Administrator

#>

# Personalize PATH, Server List, Version & LocalFolder
$Servers = @('192.168.1.1','192.168.1.2','192.168.1.3','192.168.1.24')
#$Folder = "INSTALL"
$Version = "21.12"
$Origin = "C:\INSTALL\company\21.12"

If (Test-Path -Path $Origin) {
    Write-Host "- Local Folder $Origin EXIST" -ForegroundColor Green
    ForEach ($Server in $Servers) {
        Write-Host "Server: $Server" -ForegroundColor Yellow
        $PingResponse = Test-Connection -BufferSize 32 -Count 1 -ComputerName $Server -Quiet
        If ($PingResponse -eq "TRUE"){
            Write-Host "- Server $Server is ONLINE" -ForegroundColor Green
            $RemoteFolder = -join ("\\",$Server,'\C$\Install\company\',$Version)
            If (Test-Path -Path $RemoteFolder) {
                Write-Host "-- Remote folder exist $RemoteFolder" -ForegroundColor Green
            } Else {
                New-Item -ItemType directory -Path $RemoteFolder | Out-Null
                Write-Host "-- Created remote folder $RemoteFolder" -ForegroundColor Green
            }
            Start-Sleep -Seconds 1
            If (Test-Path -Path $RemoteFolder) {
                $OriginFiles = Get-ChildItem -Recurse $Origin | Where-Object {! $_.PSIsContainer } | Select-Object Fullname,Name
                Foreach ($OriginFile in $OriginFiles){
                    $FileName = $OriginFile.Name
                    $FilePath = $OriginFile.Fullname.Replace($FileName,'')
                    $FilePath = $FilePath.Replace($Origin,'')
                    New-Item -ItemType "directory" -Path $RemoteFolder$FilePath -Force | Out-Null
                    Copy-Item $Origin$FilePath$FileName -Destination $RemoteFolder$FilePath$FileName -Force | Out-Null
                    If((Test-Path -Path $RemoteFolder$FilePath$FileName) -eq 'True'){
                        Write-Host "Copied: $RemoteFolder$FilePath$FileName" -ForegroundColor Green
                    } Else {
                        Write-Host "Copy Error: $RemoteFolder$FilePath$FileName" -ForegroundColor Red
                    }
                }
                Start-Sleep -Seconds 1
                Write-Host "--- Copied content from $Origin to $RemoteFolder" -ForegroundColor Green
            } Else {
                Write-Host "-- Can't create remote folder $RemoteFolder" -ForegroundColor Red
            }
        } Else {
            Write-Host "- Server $Server is OFFLINE" -ForegroundColor Yellow
        }
    }
} Else {
    Write-Host "----- Local $LocalFolder folder NOT EXIST, (can't copy local files to remote server) -----" -ForegroundColor Red
}