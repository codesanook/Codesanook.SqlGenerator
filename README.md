![sql logo](https://github.com/aaronamm/CodeSanook.SqlGenerator.Console/blob/master/sql.png)

## Use case
* You want to reproduce some errors that happened on a production.
* Production database is huge and it is hard to restore from a backup. 
* To copy data from a server database to developer machine is very boring job.
* Most tool I found only support exporting to text file, excel file, or some Wizard UI.   
* You can use this tool (Export-SqlQuery.ps1 or CodeSanook.SqlGenerator.Console.exe) 
to export your SQL query result to a set of insert statement.
* Export-SqlQuery.ps1 use  CodeSanook.SqlGenerator.Console.exe for preparing multiple query and create 
SQL script file  
* You can use "CodeSanook.SqlGenerator.Console.exe" with other programming language/framework e.g. Java,
NodeJS, Python. This is because CodeSanook.SqlGenerator.Console.exe is a console application.
* The program can only use with Windows client now. 

## Use case in Thai language
* ครื่องมือสำหรับ export SQL query to insert statement ครับ 
* สำหรับท่านใดที่ต้องการ export SQL query select statement เพื่อดึงข้อมูลบางส่วนจาก production database
แล้วสร้าง insert statement ให้โดยอัตโนมัติ 
* ตัวอย่างเช่น database ใน production ใหญ่มาก แต่เราต้องการข้อมูลเพียงบางส่วน เช่นเฉพาะ data ที่เกี่ยวข้องกับ user จำนวนหนึ่ง
* เราก็ทำการสร้าง select statment ของข้อมูลที่เกี่ยวข้องทั้งหมด ตัว tool (Export-SqlQuery.ps1 หรือ CodeSanook.SqlGenerator.Console.exe)
ก็จะสร้าง insert statment ให้เราเอาไปใช้งานได้เลยครับ เช่น นำไป execute ใน develop machine 
* github project URL [https://github.com/aaronamm/CodeSanook.SqlGenerator.Console](https://github.com/aaronamm/CodeSanook.SqlGenerator.Console)

## Benefit and motivation
* Work with any target columns order or missing columns
* Create multiple statement into on file and apply once
* Insert to a correct order of dependency, no need to drop constraints
* work with multiple database type, SqlServer, MySQL
* Not require any UI tool, e.g. SSMS

## Program language/Framework used in the tool 
* C# 4.6.1 .NET Standard  
* PowerShell 
* MS Build 
* Git Client [http://gitforwindows.org/](http://gitforwindows.org/)
* NHibernate 
* FluentNHibernate
* SQL Server Express (free edition)

## Requirements
Before we can start, you need to have the following software installed on your computer 
* GIT client, you can down from [http://gitforwindows.org/](http://gitforwindows.org/) and install.
* MS Build 2017, you can install with **vs_BuildTools.exe**.
* PowerShell
* .NET Framework developer package, you can install with  


## How to use Export-SqlQuery.ps1	

## Clone the project (only for the first time) 
Launch PowerShell console with administrator permission.
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
Temporary allow ExecutionPolicy to run PowerShell script in the project 
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```

execute PowerShellFile to build a project
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

Check if you have a script.sql that contains multiple insert statements.  


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
* [x] PowerShell Script for working with multiple SQL Query
* [x] MS Build script for easy deployment
* [ ] option to allow inserting auto increment ID
* [ ] support MySQL
* [ ] Not sure about maximum rows can be exported because everything is in memory now 
* [ ] Make a class library (DLL)
* [ ] SQL parser to automatic detect an exported table from a query
* [ ] Orchard plug in
* [ ] Export create statement with NHibernate Entity class