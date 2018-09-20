param(
    [Parameter] [SecureString] $Password 
)

function Export-SqlQuery {
    param(
        [Parameter(Mandatory = $True)] [string] $ConnectionString, 
        [Parameter(Mandatory = $True)] [string] $DatabaseType, 
        [Parameter(Mandatory = $True)] [string] $Query, 
        [Parameter(Mandatory = $false)] [string] $ExportTable = "",
        [Parameter(Mandatory = $false)] [string] $Template = "",
        [Parameter(Mandatory = $True)] [string] $filePath
    )

    $exePath = "./bin/debug/CodeSanook.SqlGenerator.Console.exe"
    $commandTemplate = 
        '& "{0}" export `
		--connection-string "{1}" `
		--database-type "{2}" `
		--query "{3}" ' 

    if($ExportTable){
        $commandTemplate += ' --table "{4}" '
        $optionalValue = $ExportTable
    }
    if($Template){
        $commandTemplate +=  ' --template "{4}" '
        $optionalValue = $template
    }

    $command = 
        $commandTemplate `
        -f `
        $ExePath, `
        $ConnectionString, `
        $DatabaseType, `
        $Query, `
        $optionalValue

    # export SQL query to a file  
    Invoke-Expression $command | Out-File -FilePath $filePath -Append
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
$exportTable = "Users"
Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -ExportTable $exportTable -FilePath $fileOutputPath

 # Alter Users table 
$query = @"
    SELECT 
    'Users' AS TableName,  --c0, v0
    Money  --c1, v1
    FROM Users
"@
# template support these placeholder
# c0, c1, c2, ... for column index start at index 0
# v0, v1, v2, ... for column value start at index 0
$template = @"
    ALTER TABLE [v0] 
    ALTER COLUMN [c1] DECIMAL(18, 4)
"@
Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -Template $template -FilePath $fileOutputPath 
"Successfully"