# Delete all Files in C:\temp older than 30 day(s)
$Path = "C:\temp"
$Daysback = "-30"
 
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path -Recurse ( | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
