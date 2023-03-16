<#
Parse XML file and convert content in an object
#>
$fileXml = ".\DataBase.xml"

foreach($lineXml in [System.IO.File]::ReadLines($fileXml)){
    $xmlDocument = [xml]$lineXml
    $dbColumnText = Select-Xml -Xml $xmlDocument -XPath "//DBColumnText"
    #$defaultValue = $dbColumnText.Node.DefaultValue
    $defaultValue = $dbColumnText.Node.DefaultValue.Split("|")
    $translatedValue = $dbColumnText.Node.TranslatedValue
    $columnMaxLength = $dbColumnText.Node.ColumnMaxLength

    Write-Host "CT" $dbColumnText
    Write-Host "DV" $defaultValue[1]

    Write-Host "TV" $translatedValue
    Write-Host "CML" $columnMaxLength
}