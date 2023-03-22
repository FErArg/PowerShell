HostName = Read-Host "Enter a computer name"
Write-Host "Confirming that computer is online..." -ForegroundColor Green
$HostUp = Test-Connection -ComputerName $HostName -Count 1 -ErrorAction SilentlyContinue
if (-not $HostUp)
{
    Write-Host "Remote computer not available.  Terminating." -ForegroundColor Red
    exit 1
}
else
{
    Write-Host "Remote computer was pinged successfully." -ForegroundColor Green
}