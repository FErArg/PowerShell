$Dcs="ESBCNAD01P","ESBCNZFDC01P","ESDCAD01P","ESLEIDC01P","ESLEIDC02P","ESLEVDC01P","ESMADDC01P","ESMADDC02P","ESMADDC03P","ESMALDC01P","ESSEVDC01P","ESVALDC01P"
$ports="88","135","139","389","636","445","464","3268","3269","53"
$dcsource=hostname
foreach ($Dcdest in $Dcs)
{
    Write-host -ForegroundColor Yellow "$dcsource hacía $Dcdest"
    foreach ($port in $ports)
    {
        $a=C:\TEMP\PortQuery\PortQry.exe -n $Dcdest -e $port -p TCP|? {$_ -match "TCP port"}
        if ($a -notmatch "Sending" -and $a -match "Listening")
        {
            write-host -ForegroundColor green $a
        }
        else
        {
            Write-Host -ForegroundColor red $a
        }
    }
}
