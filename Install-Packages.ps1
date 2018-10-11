function GetLatestVersionFilePath($fileName){
    $allDllPaths = Get-ChildItem -Path "./packages/*" -Include "$fileName" -Recurse
    $latestVersionOfDllPath = ($allDllPaths | Sort-Object -Property "FullName" -Descending | Select-Object -First 1)
    $latestVersionOfDllPath
}

$libraryName = "CodeSanook.SqlGenerator"

$nugetPath = GetLatestVersionFilePath("nuget.exe")
$nugetPath
Invoke-Expression -Command "$nugetPath Install $libraryName -DependencyVersion Lowest -OutputDirectory './packages'"

#copy all file  to targ folder
$outputFolder = "./bin/release"
New-Item -Path $outputFolder -ItemType Directory -Force

 $dllsToCopied = @(
     GetLatestVersionFilePath("CodeSanook.SqlGenerator.dll")

     GetLatestVersionFilePath("FluentNHibernate.dll")
     GetLatestVersionFilePath("Iesi.Collections.dll")
     GetLatestVersionFilePath("NHibernate.dll")
    "./packages/System.ValueTuple.4.5.0/lib/net461/System.ValueTuple.dll"
 )

 $dllsToCopied | Copy-Item -Destination $outputFolder

$exportSqlQueryPath =GetLatestVersionFilePath("Export-SqlQuery.ps1")
$exportSqlQueryPath
Copy-Item -Path $exportSqlQueryPath  -Destination "./"
"Install done"
