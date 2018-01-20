using CommandLine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeSanook.SqlGenerator.Console
{
    public enum DatabaseType
    {
        SqlServer,
        MySql
    }

    [Verb("export", HelpText = "Export SQL insert statement from given SQL query")]
    public class ExportOptions
    {
        [Option('c', "connection-string", Required = true, HelpText = "database connection string")]
        public string ConnectionString { get; set; }

        [Option('d', "database-type", Required = true, HelpText = "database type, can be: SqlServer, MySql")]
        public  DatabaseType DatabaseType { get; set; }

        [Option('q', "query", Required = true, HelpText = "SQL query (select statement).")]
        public string Query { get; set; }

        [Option('t', "table", Required = true, HelpText = "a table name to export")]
        public string Table { get; set; }
    }
}
