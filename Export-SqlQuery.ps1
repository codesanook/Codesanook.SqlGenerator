
Import-Module -Name "./Export-SqlQueryModule" -Verbose -Force
#*********************Begin of using a script*********************

$server = ".\"
$database = "JetabroadOperation"
$connectionString = Get-ConnectionString -Server $server -Database $database
$databaseType = [CodeSanook.SqlGenerator.DatabaseType]::SqlServer

$fileOutputPath = Join-Path -Path $PSScriptRoot -ChildPath "output-script.sql" 
Remove-Item -Path $fileOutputPath -Force -ErrorAction Ignore

$query = @"
    SELECT * FROM SabreAlternateOfficeAirlinePreference
    WHERE SabreParameterAlternateOfficeFk = '869981F6-AD70-48A0-9CC5-630B4DD218B1'
"@

$template = @"
    INSERT INTO [SabreAlternateOfficeAirlinePreference]
        (##{col*}) 
    VALUES 
        (#{col*})

"@

Export-SqlQuery `
	-ConnectionString $connectionString `
	-DatabaseType $databaseType `
	-Query $query `
	-Template $template `
	-FilePath $fileOutputPath

"Exported SQL to $fileOutputPath Successfully"