param(
    [Parameter] [SecureString] $Password 
)

$libraryName = "CodeSanook.SqlGenerator"
./nuget Install $libraryName -DependencyVersion Lowest -OutputDirectory "./package"

$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "$libraryName/bin/Release"
$assemblyPath = Join-Path -Path $outputDir -ChildPath "$libraryName.dll"

#LoadFrom() look for the depepent DLLs in the same directory
$assembly = [Reflection.Assembly]::LoadFrom($assemblyPath)   

#*********************Begin of using a script*********************

$database = "testdb"
$server = ".\"
$connectionString = Get-ConnectionString -Server $server -Database $database
$databaseType = [CodeSanook.SqlGenerator.DatabaseType]::SqlServer
$fileOutputPath = "./output-script.sql" 
Remove-Item -Path $fileOutputPath -Force -ErrorAction Ignore

#Get Users items
$query = @"
    SELECT * FROM Users
"@

# Built-in placeholders are 
# #{columnName} for a value of a given column name from a select statment
# #{!'columnName} for a value of a given column name from a select statment and not wrap quote
# #{col*} for CSV of all values in a row
# ##{col*} for CSV of all column names in a row
$template = @"
    INSERT INTO [Users]
        (##{col*}) 
    VALUES 
        (#{col*})

"@

Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -Template $template -FilePath $fileOutputPath

 # Alter Users table 
$query = @"
    SELECT 
        'Users' AS TableName,
        'Money' AS ColumnName
    FROM Users
"@
$template = @"
    ALTER TABLE [#{!'TableName}]
    ALTER COLUMN [#{!'ColumnName}] DECIMAL(18, 4)

"@

Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -Template $template -FilePath $fileOutputPath
"Successfully"