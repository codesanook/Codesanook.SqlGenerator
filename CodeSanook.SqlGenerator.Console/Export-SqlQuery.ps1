param(
	[Parameter(Mandatory=$True)] [SecureString] $password 
)

function Export-SqlQuery {
	param(
		[Parameter(Mandatory=$True)] [string] $ConnectionString, 
		[Parameter(Mandatory=$True)] [string] $DatabaseType, 
		[Parameter(Mandatory=$True)] [string] $Query, 
		[Parameter(Mandatory=$True)] [string] $ExportTable,
		[Parameter(Mandatory=$True)] [string] $filePath
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

#decrypt input password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$databaseUserPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# To do, change your configuration and query
$connectionString = "Server=localhost;Database=CodeSanook;User Id=sa; Password=$databaseUserPassword;"
$databaseType = "SqlServer" 
$filePath = "./script.sql" 
Remove-Item -Path $filePath -Force 

$query = "SELECT * FROM Users"
$exportTable = "Users"

# export from query 1
Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -ExportTable $exportTable -FilePath $filePath

# support alias select and projection, password parameter from a PowerShell variable 
$userId = "efef279a-7633-4ecd-aa30-dbf8f924aac1"
$query = "SELECT Id AS UserId FROM Users WHERE Id = '$userId'"
$exportTable = "Member"

# export from query 2
Export-SqlQuery -ConnectionString $connectionString -DatabaseType $databaseType -Query $query -ExportTable $exportTable -FilePath $filePath

"successful"