param(
    [Parameter] [SecureString] $Password 
)

function Export-SqlQuery {
    param(
        [Parameter(Mandatory = $True)] [string] $ConnectionString, 
        [Parameter(Mandatory = $True)] [string] $DatabaseType, 
        [Parameter(Mandatory = $True)] [string] $Query, 
        [Parameter(Mandatory = $True)] [string] $ExportTable,
        [Parameter(Mandatory = $True)] [string] $filePath
    )

    $exePath = "./bin/debug/CodeSanook.SqlGenerator.Console.exe"
    $command = '& "{0}" export `
		--connection-string "{1}" `
		--database-type "{2}" `
		--query "{3}" `
		--table "{4}" '`
        -f `
        $ExePath, `
        $ConnectionString, `
        $DatabaseType, `
        $Query, `
        $ExportTable

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

 # Get booing result items
$query = @"
    SELECT * FROM Users
"@
$exportTable = "Users"
Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -ExportTable $exportTable -FilePath $fileOutputPath

"Successfully"