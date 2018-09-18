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


if ($Password) {
    #decrypt input password
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $databaseUserPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    # To do, change your configuration and query
    $connectionString = "Server=$server;Database=$database;User Id=sa; Password=$databaseUserPassword;"
}
else {
    #Trusted Connection Windows user login
    $connectionString = "Server=$server;Database=$database;Trusted_Connection=True";
}


#Begin of using a script

$databaseType = "SqlServer" 
$database = "User"
$server = ".\"

$fileOutputPath = "./script.sql" 
Remove-Item -Path $filePath -Force -ErrorAction Ignore

$query = "SELECT * FROM Users"
$exportTable = "Users"
# export from query 1

Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -ExportTable $exportTable -FilePath $fileOutputPath
"successfully"