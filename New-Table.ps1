# Create sample table
$createTableQuery = @"
    CREATE TABLE [dbo].[Users] (
        [Id] [uniqueidentifier] NOT NULL PRIMARY KEY,
        [FirstName] [nvarchar](50) NOT NULL,
        [LastName] [nvarchar](50) NOT NULL,
        [DateOfBirth] [datetime] NULL,
        [Checked] [bit] NULL,
        [Money] [decimal](18, 4) NULL
    )
"@
$databaseName = "SqlGenerationExample"
Push-Location $PSScriptRoot
Invoke-Sqlcmd -ServerInstance ".\" -Query $createTableQuery -Database $databaseName
"Create table successfully"
Pop-Location


# Insert sample record
$insertQuery = @"
    INSERT INTO [Users]
        ([Id], [FirstName], [LastName], [DateOfBirth], [Checked], [Money]) 
    VALUES 
        ('efef279a-7633-4ecd-aa30-dbf8f924aac1', 'Aaron', 'Amm', '2018-01-20 09:30:00', 1, NULL)
"@

Push-Location $PSScriptRoot
Invoke-Sqlcmd -ServerInstance ".\" -Query $insertQuery -Database $databaseName
"Insert new record successfully"
Pop-Location
