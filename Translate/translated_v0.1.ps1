<#
OnLine text translation using Yandex API
#>
$apiKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx"
$text = "Una vez que has enviado la solicitud, puedes"
$languages = "es-en"
$url = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=$apiKey&text=$text&lang=$languages"
$response = Invoke-RestMethod -Method GET -Uri $url
Write-Host $response.text[0]