function Invoke-MsBuild {
	param(
		[Parameter(Mandatory=$True)] [string] $ExePath,
		[Parameter(Mandatory=$True)] [string] $ProjectFile, 
		[Parameter(Mandatory=$True)] [string] $OutputPath, 
		[Parameter(Mandatory=$True)] [string] $Configuration, 
		[Parameter(Mandatory=$True)] [string] $Target 
	)
	
	& $ExePath "$projectFile" /t:"$Target" /p:OutputPath="$OutputPath" /p:Configuration="$Configuration"
	#use call operator
}

#restore nuget
./nuget restore "./CodeSanook.SqlGenerator.sln"

$buildToolPath = vswhere -Latest -products * -Requires Microsoft.Component.MSBuild -Property InstallationPath
$exePath = "$buildToolPath\MSBuild\15.0\Bin\MSBuild.exe"

$projectRoot = "./CodeSanook.SqlGenerator"
$projectName = "CodeSanook.SqlGenerator"
$projectFile = "$projectRoot/$projectName.csproj"

$configuration = "Release"
$outputPath = "bin/$configuration"

# Clean the project
$target ="clean"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target

# Build the project
$target ="build"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target