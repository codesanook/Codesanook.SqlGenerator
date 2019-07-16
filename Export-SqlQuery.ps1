# There are three step to get SQL export
# 1. Create SQL query to get the result of SQL that you want to export
# 2. Create a template of SQL output, it can be INSERT, UPDATE etc.
# 3. Call Export-SqlQuery with your SQL query and template.

# Built-in placeholders are in at template:
# Get values:
# #{columnName} for a VALUE of a given column name from a select statement
# #{col*} for all VALUES in a row as CSV format
# #{!'columnName} for a VALUE of a given column name from a select statement and not wrap quote

# Get column names:
# ##{col*} for all column NAMES in a row as CSV format.
# If you want to have a custom column name, you can specify a custom column name in select statment.

# Example:
# Get all users from the example database.
$query = @"
    SELECT * FROM Users
"@

$template = @"
    INSERT INTO [Users]
        ([Id], [FirstName], [LastName], [DateOfBirth], [Checked], [Money])
    VALUES
        (#{Id}, #{FirstName}, #{LastName}, #{DateOfBirth}, #{Checked}, #{Money})

"@

Import-Module -Name .\Export-SqlQueryModule -Force -Verbose
# Preparing required paramters for Export-Query cmdlet
$database = "SqlGenerationExample"
$server = ".\"
$connectionString = Get-ConnectionString -Server $server -Database $database # Use Trusted Connection
$databaseType = [CodeSanook.SqlGenerator.DatabaseType]::SqlServer

$fileOutputPath = Join-Path -Path $PSScriptRoot -ChildPath "output-script.sql"
Remove-Item -Path $fileOutputPath -Force -ErrorAction Ignore

Export-SqlQuery `
    -ConnectionString $connectionString `
    -DatabaseType $databaseType `
    -Query $query `
    -Template $template `
    -FilePath $fileOutputPath
$fileOutputPath

"Export Successfully"