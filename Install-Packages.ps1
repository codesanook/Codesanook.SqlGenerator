
function GetLatestVersionFilePath($FileName, $Framework) {
    $pattern = if ($framework) { ".*packages.*$Framework.*$FileName" } else { ".*packages.*$FileName" }
    $allDllPaths = Get-ChildItem -Path "./packages" -Recurse -File
    $allDllPaths | Where-Object {
        $_.FullName -match $pattern
    } | Select-Object -ExpandProperty "FullName" | Sort-Object -Descending | Select-Object -First 1
}

$nugetPath = "./nuget.exe"
$libraryName = "CodeSanook.SqlGenerator"
& $nugetPath Install $libraryName -DependencyVersion Lowest -OutputDirectory "./packages"

#copy all file a to target folder
$outputFolder = "./bin/release"
Remove-Item $outputFolder -Recurse -Force -ErrorAction Ignore
New-Item -Path $outputFolder -ItemType Directory -Force

$assemblyPath = GetLatestVersionFilePath -FileName "$libraryName.dll"
"assembly path $assemblyPath"
$assembly = [Reflection.Assembly]::LoadFrom($assemblyPath)
$attribute = $assembly.GetCustomAttributes([System.Runtime.Versioning.TargetFrameworkAttribute])

$pattern = "version=v(?<version>[\w\.]+)"
$option = [Text.RegularExpressions.RegexOptions]::IgnoreCase
$match = [Regex]::Match($attribute.FrameworkName, $pattern, $option);
$framework = $match.Groups["version"].value -replace "\.", ""
"framework $framework"

@(
    GetLatestVersionFilePath -FileName  "$libraryName.dll" -Framework $framework
    GetLatestVersionFilePath -FileName "System.ValueTuple.dll" -Framework $framework
) | Copy-Item -Destination $outputFolder

GetLatestVersionFilePath -FileName "Export-SqlQuery.ps1" | Copy-Item -Destination "."
"Install successfully"
