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
        public string Template { get; set; }
        public Stream Stream { get; set; }
    }
}