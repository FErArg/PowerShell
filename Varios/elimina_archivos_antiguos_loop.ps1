$limit = (Get-Date).AddDays(-15)
$path1 = "D:\Datos\escaner_sedes\30082\Garantias"
$path2 = ""
$path3 = ""
$path4 = ""
$path5 = ""

paths = @($path1, $path2, $path3, $path4, $path5)

foreach ($path in $paths){
    # Delete files older than the $limit.
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

    # Delete any empty directories left behind after deleting the old files.
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
}