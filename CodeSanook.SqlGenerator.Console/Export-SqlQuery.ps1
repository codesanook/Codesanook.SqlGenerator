param(
    [Parameter] [SecureString] $Password 
)

function Export-SqlQuery {
    param(
        [Parameter(Mandatory = $True)] [string] $ConnectionString, 
        [Parameter(Mandatory = $True)] [string] $DatabaseType, 
        [Parameter(Mandatory = $True)] [string] $Query, 
        [Parameter(Mandatory = $True)] [string] $Template,
        [Parameter(Mandatory = $True)] [string] $FilePath
    )

    $exePath = "./bin/debug/CodeSanook.SqlGenerator.Console.exe"
    $commandTemplate = 
        '& "{0}" export `
		--connection-string "{1}" `
		--database-type "{2}" `
		--query "{3}" `
		--template "{4}"'

    $command = 
        $commandTemplate `
        -f `
        $ExePath, `
        $ConnectionString, `
        $DatabaseType, `
        $Query, `
        $Template

    # export SQL query to a file  
    Invoke-Expression $command | Out-File -FilePath $FilePath -Append
}

function Get-ConnectionString{
    param(
        [Parameter(Mandatory = $True)] [string] $Server,
        [Parameter(Mandatory = $True)] [string] $Database
    )

    if ($Password) {
        #decrypt input password
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $databaseUserPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        $connectionString = "Server=$Server;Database=$Database;User Id=sa; Password=$databaseUserPassword;"
    }
    else {
        #Trusted Connection Windows user login
        $connectionString = "Server=$Server;Database=$Database;Trusted_Connection=True";
    }

    $connectionString
}

#Begin of using a script
$database = "testdb"
$server = ".\"
$connectionString = Get-ConnectionString -Server $server -Database $database
$databaseType = "SqlServer" 

$fileOutputPath = "./script.sql" 
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