using CommandLine;

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
        [Option('d', "database-type", Required = true, HelpText = "database type, can be: SqlServer, MySql")]
        public DatabaseType DatabaseType { get; set; }

        [Option('c', "connection-string", Required = true, HelpText = "database connection string")]
        public string ConnectionString { get; set; }

        [Option('q', "query", Required = true, HelpText = "SQL query (select statement).")]
        public string Query { get; set; }

        [Option(
            't',
            "template",
            Required = true,
            HelpText =
            "SQLstatement and placeholders for create an output template. " +
            "Built-in placeholders are: " +
            "#{columnName} for a value of a given column name from a select statment, "+
            "#{!'columnName} for a value of a given column name from a select statment and not wrap quote, " +
            "#{col*} for CSV of all values in a row, ##{col*} for CSV of all column names in a row.")]
        public string Template { get; set; }
    }
}
