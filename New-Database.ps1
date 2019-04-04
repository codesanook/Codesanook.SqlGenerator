$databaseName = "company"
$query = @"
    IF db_id('$databaseName') IS NOT NULL
    BEGIN
        DROP DATABASE $databaseName
        SELECT 'true' as IsDatabaseExist
    END

    CREATE DATABASE $databaseName
"@

Push-Location $PSScriptRoot
Invoke-Sqlcmd -ServerInstance ".\" -Query $query -Database "master"
"Drop and create database successfully"
Pop-Location
