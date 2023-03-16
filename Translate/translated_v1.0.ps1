<#
- Parse XML and convent in an Object
- Online translation usin Yandex API -> english text to spanish
- Split variable content -> "|"
- re cretae XML
#>
$apiKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx"
$languages = "en-es"
$fileXml = ".\DataBase.xml"
$fileXmlTranslated = ".\DataBase-Translated.xml"

New-Item -ItemType File -Path $fileXmlTranslated | Out-Null

foreach($lineXml in [System.IO.File]::ReadLines($fileXml)){
    $xmlDocument = [xml]$lineXml
    $dbColumnText = Select-Xml -Xml $xmlDocument -XPath "//DBColumnText"
    $defaultValue = $dbColumnText.Node.DefaultValue.Split("|")
    $translatedValue = $dbColumnText.Node.TranslatedValue
    $columnMaxLength = $dbColumnText.Node.ColumnMaxLength

    $text = $defaultValue[1]
    $url = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=$apiKey&text=$text&lang=$languages"
    $response = Invoke-RestMethod -Method GET -Uri $url
    
    $textToTranslate = $defaultValue[1]
    $textTranslated = $response.text[0]
    $nroCharTTT = $textToTranslate.length
    
    Write-Host $nroCharTTT

    [int]$nroCharTTTint = $nroCharTTT
    $nroCharTTT = ""
    $nroCharTTT = $nroCharTTTint + 3
    $nroCharTT = $textTranslated.length
        
    Write-Host $nroCharTTT
    Write-Host $nroCharTT

    If ( $nroCharTT -ge $nroCharTTT ) {
        $textTranslatedSplited = $textTranslated.Substring(0,$nroCharTTT)
    } else {
        $textTranslatedSplited = $textTranslated
    }

    Write-Host "------------------------------------------------"
    Write-Host "ValorOriginal  " $textToTranslate
    Write-Host "ValorTraducido " $textTranslated
    Write-Host ""

    $lineXmlNew = -join ('    <DBColumnText DefaultValue="',$defaultValue[0],'|',$textToTranslate,'" TranslatedValue="',$textTranslatedSplited,'" ColumnMaxLength="',$columnMaxLength,'" />')
    
    Write-host $lineXml -ForegroundColor Yellow
    Write-host $lineXmlNew -ForegroundColor Green
    
    Add-Content $fileXmlTranslated -value $lineXmlNew  | Out-Null

    Write-Host ""

    #Clean variables
    $xmlDocument = ""
    $dbColumnText = ""
    $defaultValue = ""
    $translatedValue = ""
    $columnMaxLength = ""
    $text = ""
    $url = ""
    $response = ""
    $textToTranslate = ""
    $textTranslated = ""
    $nroCharTTT = ""
    $nroCharTT = ""
    $textTranslatedSplited = ""
    $lineXmlNew = ""
}