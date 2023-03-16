#$Results = @()
$i = 1

$logs = Get-WinEvent -LogName Security| Where-Object {$_.ID -eq 4634 -or $_.ID -eq 4624}

Write-Host "1"
ForEach ($log in $logs) {
    Write-Host "2"
    if ($log.Id -eq 4634){
        Write-Host "3"
        $type=”SessionStop”
        $username=$log.Properties[1].Value
    } Else {
        Write-Host "4"
        $type=”SessionStart”
        $username=$log.Properties[5].Value
    }
    Write-Host "5"
    if ($username -ne “”) {
        Write-Host "6"
        #$Results += New-Object PSObject -Property @{“Time” = $log.TimeCreated; “Event” = $type; “User” = $username};
        $Results2 = New-Object PSObject -Property @{“Time” = $log.TimeCreated; “Event” = $type; “User” = $username};
        Write-host $Results2
    }
    Write-Host "7"
    Write-Host $i
    $i++

}
#Write-Host @Results