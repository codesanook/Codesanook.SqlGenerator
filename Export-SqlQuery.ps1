param(
    [Parameter] [SecureString] $Password 
)
Import-Module -Name "./Export-SqlQueryModule" -Verbose -Force
#*********************Begin of using a script*********************

$database = "testdb"
$server = ".\"
$connectionString = Get-ConnectionString -Server $server -Database $database
$databaseType = [CodeSanook.SqlGenerator.DatabaseType]::SqlServer

$fileOutputPath = Join-Path -Path $PSScriptRoot -ChildPath "output-script.sql" 
Remove-Item -Path $fileOutputPath -Force -ErrorAction Ignore

#Get Users items
$query = @"
    SELECT * FROM Users
"@

# Built-in placeholders are 
# #{columnName} for a value of a given column name from a select statement
# #{!'columnName} for a value of a given column name from a select statement and not wrap quote
# #{col*} for CSV of all values in a row
# ##{col*} for CSV of all column names in a row
$template = @"
    INSERT INTO [Users]
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