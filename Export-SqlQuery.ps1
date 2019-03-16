<#
username and password parameters are optional.
If you run in the same machine of SQL server, you can ignore these parameter 
and use Windows authentication
#>
param(
	[Parameter(Mandatory = $False)] [string] $Username,
	[Parameter(Mandatory = $False)] [string] $Password
)

Import-Module -Name "./Export-SqlQueryModule" -Verbose -Force
#*********************Begin of using a script*********************

$database = "testdb"
$server = ".\"

$connectionString = Get-ConnectionString -Server $server -Database $database -Username $Username -Password $Password
$databaseType = [CodeSanook.SqlGenerator.DatabaseType]::SqlServer

$fileOutputPath = Join-Path -Path $PSScriptRoot -ChildPath "output-script.sql" 
Remove-Item -Path $fileOutputPath -Force -ErrorAction Ignore

#Get Users items
$query = @"
    SELECT * FROM Users
"@

# Built-in placeholders are: 
# #{columnName} for a value of a given column name from a select statement
# #{!'columnName} for a value of a given column name from a select statement without wrap quote
# #{col*} for CSV of all values in a row
# ##{col*} for CSV of all column names in a row

# Get all columns
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

# Get specific columns
$template = @"
    INSERT INTO [Users]
        (Id, FullName) 
    VALUES 
        (#{Id}, '#{!'FirstName} #{!'LastName}')
"@

Export-SqlQuery `
	-ConnectionString $connectionString `
	-DatabaseType $databaseType `
	-Query $query `
	-Template $template `
	-FilePath $fileOutputPath

"Exported SQL to $fileOutputPath Successfully"