
## Requirements
Before we can start, you need to have the following software installed on your computer 
* GIT client, you can down from [http://gitforwindows.org/](http://gitforwindows.org/) and install.
* MS Build 2017, you can install with **vs_BuildTools.exe**.
* PowerShell
* .NET Framework developer package, you can install with  


## How to use Export-SqlQuery.ps1	

## Clone the project (only for the first time) 
Lanuch PowerShell console with adminsitrator permission.
CD to a folder that you want to store the project files.

use git command
```
git clone https://github.com/aaronamm/CodeSanook.SqlGenerator.Console.git 
```

CD to go inside the folder of project file.
```
cd CodeSanook.SqlGenerator.Console\CodeSanook.SqlGenerator.Console

```

## Build the project (only the first time and when you update source codes)
excute PowerShellFile to build a project
```
.\Build-Project.ps1
```

## Run Export-SqlQuery
Edit Export-SqlQuery.ps1 to have a query that you want to create insert statement script 
and change a connection string to point to your SQL server.      
run
```
.\Export-SqlQuery.ps1
```	

Check if you have a script.sql that constains multiple insert statements.  


# Examples


## Example of a demo table schema  
```
CREATE TABLE [dbo].[Users](
	[Id] [uniqueidentifier] NOT NULL PRIMARY KEY,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[DateOfBirth] [datetime] NULL,
	[Checked] [bit] NULL)
```

## Example of SQL query
```
SELECT * FROM Users
```

## Example of exported insert statement (contents in script.sql)
```
INSERT INTO [Users] ([Id], [FirstName], [LastName], [DateOfBirth], [Checked])
 VALUES 
('efef279a-7633-4ecd-aa30-dbf8f924aac1', 'AAron', 'Amm', '2018-01-20 09:30:00', 1)
```

# TO DO

* [x] support SQL Server
* [ ] option to allow inserting auto increment
* [ ] support MySQL
* [ ] Not sure about maximum rows can be exported because everything is in memory now 
* [ ] Make a class library (DLL)
* [ ] SQL parser to automatic detect an exported table from a query
* [ ] Orchard plug in
* [ ] Export create statement with NHibernate Entity class