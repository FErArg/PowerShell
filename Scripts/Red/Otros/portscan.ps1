$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$coleccion=@{
 TS=3389
    vCenter=9443
    IIS=80,443
    AD=53,88,135,137,139,138,389,445,464,593,636,3268,3269,5722,9389,123
 DHCP=67,2535
    }

$maquinas=read-host "computers?"
 if ($maquinas -eq "")
 {
 $maquinas=get-content "$scriptPath\computers.txt"|?{$_}
 write-host "Loading computers from computers.txt" -fore cyan
 $maquinas
 }
$coleccion
$choice=read-host "`nPorts to scan?"

 try
 {
 [int]$choice|out-null
 $puertos=$choice -split ","
 }
 Catch{$puertos=$coleccion.$choice}
#create an object to gather all the results and add them to a logfile at the end
$objects=@()
foreach($maquina in $maquinas){
$object=New-Object PSObject
$object|Add-Member -MemberType NoteProperty -Name maquina -Value $maquina.TOUPPER()
write-host "$($maquina.TOUPPER())`t" -nonewline
 foreach ($puerto in $puertos)
 { 
 $socket=New-Object system.net.Sockets.TcpClient
 $connect = $socket.BeginConnect($maquina,$puerto,$null,$null)
 #Configure a timeout before quitting - time in milliseconds 
 $wait = $connect.AsyncWaitHandle.WaitOne(2000,$false) 
  If (-Not $Wait)
  {
  #timeout
  Write-Host "$puerto " -ForegroundColor darkgray -nonewline
  $object|Add-Member -MemberType NoteProperty -Name $puerto -Value "timeout"
  } 
  Else
  {
   try
   {
   $socket.EndConnect($connect)
   #open
   write-Host "$puerto " -ForegroundColor Green -nonewline
   $object|Add-Member -MemberType NoteProperty -Name $puerto -Value "open"
   }
   Catch [system.exception]{
   #closed
   Write-Host "$puerto " -ForegroundColor red -nonewline
   $object|Add-Member -MemberType NoteProperty -Name $puerto -Value "closed"
   }
  }
 }#fin foreach puerto
write-host ""
$objects+=$object
}#fin foreach maquina

$objects|out-file "$scriptPath\portscan.log" -append
"-" * 60|out-file "$scriptPath\portscan.log" -append
