using System.IO;

namespace CodeSanook.SqlGenerator
{
    public enum DatabaseType
    {
        SqlServer,
        MySql
    }

    public class ExportOptions
    {
        public DatabaseType DatabaseType { get; set; }
        public string ConnectionString { get; set; }
        public string Query { get; set; }

        // Built-in placeholders are: 
        // #{columnName} for a value of a given column name from a select statement
        // #{!'columnName} for a value of a given column name from a select statement without wrap quote
        // #{col*} for CSV of all values in a row
        // #{col*} for CSV of all column names in a row
        public string Template { get; set; }

        public Stream Stream { get; set; }
    }
}