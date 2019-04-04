$projectName = "CodeSanook.SqlGenerator"
$apiKeyFilePath = "./nuget-server-api-key.txt"

$properties = @{
    configuration = "Release"
    author        = "AaronAmm"
}

if (Test-Path ($apiKeyFilePath)) {
    "./nuget-server-api-key.txt exists"
}
else {
    New-Item $apiKeyFilePath -ItemType "file" | Out-Null
    "./nuget-server-api-key.txt created"
}

$propertiesValue = $properties.Keys | Foreach-Object {
    "$_=$($properties[$_])"
}

nuget restore "./$projectName.sln"

Get-ChildItem -Path "*.nupkg" | ForEach-Object {
    Remove-Item $_
}

nuget pack "./$projectName/$projectName.csproj" -Build -Properties ($propertiesValue -join ";")

$apiKey = Get-Content -Path $apiKeyFilePath
if ([string]::IsNullOrEmpty($apiKey)) {
    throw "Please add your nuget.org API key to nuget-server-api-key.txt file"
}

$apiKey = $apiKey.Trim();
$package =  Get-ChildItem -Path "*.nupkg" | Select-Object -First 1
nuget push $package -ApiKey $apiKey -Source "https://api.nuget.org/v3/index.json"