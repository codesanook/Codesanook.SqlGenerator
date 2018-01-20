
function Invoke-MsBuild {
	param(
		[Parameter(Mandatory=$True)] [string] $ExePath,
		[Parameter(Mandatory=$True)] [string] $ProjectFile, 
		[Parameter(Mandatory=$True)] [string] $OutputPath, 
		[Parameter(Mandatory=$True)] [string] $Configuration, 
		[Parameter(Mandatory=$True)] [string] $Target 
	)

	$command = `
		'& "{0}" "{1}" /t:{2} /p:OutputPath="{3}" /p:Configuration={4}'`
		-f `
		$ExePath, `
		$ProjectFile, `
		$Target, `
		$OutputPath, `
		$Configuration
	
	Write-Host $command
	Invoke-Expression $command
}


#restore nuget
..\nuget restore "..\CodeSanook.SqlGenerator.Console.sln"


#$exePath = "C:\Program Files (x86)\MSBuild\14.0\Bin\amd64\MSBuild.exe" 
$exePath = "C:\Windows\Microsoft.Net\Framework64\v4.0.30319\MSBuild.exe"
$projectFile = "CodeSanook.SqlGenerator.Console.csproj"
$configuration = "Debug"
$outputPath = "./bin/debug"
$target ="clean"

Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target


$target ="build"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target