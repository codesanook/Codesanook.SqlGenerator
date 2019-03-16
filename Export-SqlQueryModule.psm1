$libraryName = "CodeSanook.SqlGenerator"

<#
./nuget Install $libraryName -DependencyVersion Lowest -OutputDirectory "./package"

$outputDir = Join-Path -Path $PSScriptRoot -ChildPath "$libraryName/bin/Release"
$assemblyPath = Join-Path -Path $outputDir -ChildPath "$libraryName.dll"
#>

$outputDir = Join-Path $PSScriptRoot -ChildPath "CodeSanook.SqlGenerator/bin/Release/"
$assemblyPath = Join-Path -Path $outputDir -ChildPath "$libraryName.dll"

#LoadFrom() look for the dependent DLLs in the same directory
$assembly = [Reflection.Assembly]::LoadFrom($assemblyPath)   
$assembly

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
        [Parameter(Mandatory = $True)] [string] $Database,
        [Parameter(Mandatory = $False)] [string] $Username,
        [Parameter(Mandatory = $False)] [string] $Password
    )

    if ($Password) {
        #decrypt input password
        #$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        #$decryptedPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        $connectionString = "Server=$Server;Database=$Database;User Id=$Username; Password=$Password;"
    }
    else {
        #Trusted Connection Windows user login
        $connectionString = "Server=$Server;Database=$Database;Trusted_Connection=True";
    }

    $connectionString
}

Export-ModuleMember -Function "Export-SqlQuery"
Export-ModuleMember -Function "Get-ConnectionString"
