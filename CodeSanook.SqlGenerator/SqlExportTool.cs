using NHibernate;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using NHibernate.Cfg;
using NHibernate.Dialect;
using NHibernate.Driver;

namespace CodeSanook.SqlGenerator
{
    public class SqlExportTool
    {
        private static Regex valueOfColumnNamePattern = new Regex(
            @"(?<prefix>#{1,2}){\s*(?<noWrap>!')?(?<columnName>\w+\*?)\s*}",
            RegexOptions.Compiled
        );

        public void Export(ExportOptions options)
        {
            using (var sessionFactory = CreateSessionFactory(options))
            using (var session = sessionFactory.OpenSession())
            {
                Export(session, options);
            }
        }

        /// <summary>
        /// If two methods require two arguments to determine which method is being called and the first parameter of both is the same type.
        /// There is no way to tell which method is being called when the second missing argument is required to choose the matching method.
        /// Changing the first parameter on the two methods to be of different types and it works as expected. 
        /// </summary>
        public void Export(ISession newSession, ExportOptions options)
        {
            using (var streamWriter = new StreamWriter(options.Stream))
            {
                var command = newSession.Connection.CreateCommand();
                command.CommandText = options.Query;
                using (var reader = command.ExecuteReader())
                {
                    // First row create template and get data
                    var script = new StringBuilder();
                    string template = null;
                    ColumnMetaData[] columnMetaDatas = null;
                    if (reader.Read())
                    {
                        columnMetaDatas = GetColumnMetaDatas(reader);
                        template = PrepareTemplatePlaceHolder(options.Template, columnMetaDatas);
                        AppendScriptValues(reader, columnMetaDatas, template, script);
                    }

                    // Next row get data only
                    while (reader.Read())
                    {
                        AppendScriptValues(reader, columnMetaDatas, template, script);
                    }
                    streamWriter.Write(script.ToString());
                }
            }
        }

        private static ColumnMetaData[] GetColumnMetaDatas(IDataReader reader)
        {
            // https://stackoverflow.com/a/27200892/1872200
            // https://ayende.com/blog/4548/nhibernate-streaming-large-result-sets
            return Enumerable.Range(0, reader.FieldCount)
                .Select(columnIndex =>
                new ColumnMetaData(
                    reader.GetName(columnIndex),
                    reader.GetFieldType(columnIndex),
                    reader.GetDataTypeName(columnIndex),
                    columnIndex
                )).ToArray();
        }

        private static void AppendScriptValues(IDataReader reader, ColumnMetaData[] columnMetaDatas, string template, StringBuilder script)
        {
            var columnValues = new object[columnMetaDatas.Length];
            reader.GetValues(columnValues);

            var csvValues = columnValues
                .Select((value, index) => columnMetaDatas[index].Format(value, reader.IsDBNull(index)))
                .ToArray();

            script.AppendFormat(template, csvValues);
            script.AppendLine();
        }

        private static string PrepareTemplatePlaceHolder(string template, ColumnMetaData[] columns)
        {
            var matches = valueOfColumnNamePattern.Matches(template);
            var noWrapColumns = new HashSet<string>();
            foreach (Match match in matches)
            {
                var prefix = match.Groups["prefix"].Value;
                var columnName = match.Groups["columnName"].Value; ;
                if (prefix == "##" && columnName.ToLower() == "col*")
                {
                    // Get CSV names of all columns
                    var columnNames = columns.Select(column => $"[{column.Name}]");
                    template = template.Replace(match.Value, string.Join(", ", columnNames));
                }
                else if (columnName.ToLower() == "col*")
                {
                    // Get CSV values of all columns
                    var columnPlaceholderIndexes = columns.Select(column => $"{{{column.Index}}}");
                    template = template.Replace(match.Value, string.Join(", ", columnPlaceholderIndexes));
                }
                else
                {
                    // Get a value of a given column name
                    var selectedColumn = columns.SingleOrDefault(column => column.Name == columnName);
                    if (selectedColumn == null)
                    {
                        throw new InvalidOperationException($@"No column name ""{columnName}"" in select result.");
                    };

                    selectedColumn.NoWrap = !string.IsNullOrWhiteSpace(match.Groups["noWrap"]?.Value);
                    template = template.Replace(match.Value, $"{{{selectedColumn.Index}}}");
                }
            }
            return template;
        }

        private ISessionFactory CreateSessionFactory(ExportOptions options)
        {
            switch (options.DatabaseType)
            {
                case DatabaseType.SqlServer:
                    return CreateSessionFactory<MsSql2008Dialect, SqlClientDriver>(options.ConnectionString);
                case DatabaseType.MySql:
                    return CreateSessionFactory<MySQL55Dialect, MySqlDataDriver>(options.ConnectionString);
                case DatabaseType.SQLite:
                    return CreateSessionFactory<SQLiteDialect, SQLite20Driver>(options.ConnectionString);
                case DatabaseType.Oracle:
                    return CreateSessionFactory<Oracle10gDialect, OracleDataClientDriver>(options.ConnectionString);
                default:
                    throw new InvalidOperationException("No valid database type option");
            }
        }

        private ISessionFactory CreateSessionFactory<TDialect, TDriver>(string connectionString)
            where TDialect : Dialect
            where TDriver : DriverBase
        {
            Configuration cfg = new Configuration();
            cfg.Properties.Add(NHibernate.Cfg.Environment.ConnectionProvider, typeof(NHibernate.Connection.DriverConnectionProvider).AssemblyQualifiedName);
            cfg.Properties.Add(NHibernate.Cfg.Environment.ConnectionString, connectionString);

            cfg.Properties.Add(NHibernate.Cfg.Environment.Dialect, typeof(TDialect).AssemblyQualifiedName);
            cfg.Properties.Add(NHibernate.Cfg.Environment.ConnectionDriver, typeof(TDriver).AssemblyQualifiedName);

            return cfg.BuildSessionFactory();
        }
    }
}