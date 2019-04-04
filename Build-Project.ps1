function Invoke-MsBuild {
    param(
        [Parameter(Mandatory = $True)] [string] $ExePath,
        [Parameter(Mandatory = $True)] [string] $ProjectFile, 
        [Parameter(Mandatory = $True)] [string] $OutputPath, 
        [Parameter(Mandatory = $True)] [string] $Configuration, 
        [Parameter(Mandatory = $True)] [string] $Target 
    )
	
    & $ExePath "$projectFile" "/t:$Target" "/p:OutputPath=$OutputPath" "/p:Configuration=$Configuration"
    #use call operator
}

#restore nuget
nuget restore "./CodeSanook.SqlGenerator.sln"

$buildToolPath = vswhere.exe -Latest -products * -Requires Microsoft.Component.MSBuild -Property InstallationPath
vswhere.exe -Latest -products * -Requires Microsoft.Component.MSBuild -Property InstallationPath

$exePath = Get-ChildItem -Path "$buildToolPath" -Include "MSBuild.exe" -Recurse  -File `
	| Select-Object -ExpandProperty "FullName" -First 1

$projectRoot = "./CodeSanook.SqlGenerator"
$projectName = "CodeSanook.SqlGenerator"
$projectFile = "$projectRoot/$projectName.csproj"

$configuration = "Release"
$outputPath = "bin/$configuration"

# Clean the project
$target = "clean"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target

# Build the project
$target = "build"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target