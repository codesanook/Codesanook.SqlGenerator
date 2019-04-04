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
	
	"$command"
	& $command #use call operator
}

#restore nuget
./nuget restore "./CodeSanook.SqlGenerator.sln"
##TODO use VSwhere
$exePath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\amd64\MSBuild.exe"

$projectRoot = "./CodeSanook.SqlGenerator"
$projectName = "CodeSanook.SqlGenerator"
$projectFile = "$projectRoot/$projectName.csproj"

$configuration = "Release"
$outputPath = "bin/$configuration"

$target ="clean"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target

$target ="build"
Invoke-MsBuild -ExePath $exePath -ProjectFile $projectFile -OutputPath $outputPath -Configuration $configuration -Target $target