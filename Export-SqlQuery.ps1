param(
    [Parameter] [SecureString] $Password 
)

$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "CodeSanook.SqlGenerator/bin/Release";
$assemblyPath = Join-Path -Path $outputDir -ChildPath "CodeSanook.SqlGenerator.dll"

#LoadFrom() look for the depepent DLLs in the same directory
$assembly = [Reflection.Assembly]::LoadFrom($assemblyPath)   

function Export-SqlQuery {
    param(
        [Parameter(Mandatory = $True)] [string] $ConnectionString, 
        [Parameter(Mandatory = $True)]
        [CodeSanook.SqlGenerator.DatabaseType] $DatabaseType, 
        [Parameter(Mandatory = $True)] [string] $Query, 
        [Parameter(Mandatory = $True)] [string] $Template,
        [Parameter(Mandatory = $True)] [string] $FilePath
    )

    #prepare parameters object
    $options = New-Object CodeSanook.SqlGenerator.ExportOptions
    $options.DatabaseType = $DatabaseType 
    $options.ConnectionString = $ConnectionString 
    $options.Query = $Query
    $options.Template = $Template

    $fileStream = New-Object `
        -TypeName System.IO.FileStream `
        -ArgumentList @($FilePath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
    $options.Stream = $fileStream 

    # export SQL query and pipe to a file
    $tool = New-Object CodeSanook.SqlGenerator.SqlExportTool
    $tool.Export($options)
    $fileStream.Close()
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