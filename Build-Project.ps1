
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
./nuget restore "./CodeSanook.SqlGenerator.sln"
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

$dllPath = [IO.Path]::Combine($projectRoot, $outputPath, "$projectName.dll")
$dllPath

Remove-Item -Path "./dist" -Recurse -Force -ErrorAction Ignore

$libPath = "./dist/lib/net461"
$contentPath = "./dist/content"
New-Item -Path $libPath -ItemType "directory" -Force
New-Item -Path $contentPath -ItemType "directory" -Force

Copy-Item $dllPath -Destination "$libPath" -Force
Copy-Item "./Export-SqlQuery.ps1" -Destination "$contentPath" -Force

Push-Location -Path "./dist"
Get-Location

../nuget.exe spec $projectName -Force
[Reflection.Assembly]::Load("System.Xml.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") | Out-Null

#push location does not work with calling .NET type
$xDoc = [System.Xml.Linq.XDocument]::Load("./dist/$projectName.nuspec")
#$endpoints = $xDoc.Descendants("client") | foreach { $_.DescendantNodes()}               
#$comments = $endpoints | Where-Object { $_.NodeType -eq [System.Xml.XmlNodeType]::Comment -and $_.Value -match "net.tcp://localhost:9876/RaceDayService" }        
#$comments | foreach { $_.ReplaceWith([System.Xml.Linq.XElement]::Parse($_.Value)) }

$author = $xDoc.Descendants("authors") | Select -First 1
$author.Value = "AaronAmm"

$owner = $xDoc.Descendants("owners") | Select -First 1
$owner.Value = "codesanook.com"

<#
    <dependencies>
      <dependency id="SampleDependency" version="1.0" />
    </dependencies>
#>

$xDoc.Save("./dist/$projectName.nuspec")
../nuget.exe pack "$projectName.nuspec"

Pop-Location
Get-Location
