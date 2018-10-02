using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;
using NHibernate;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace CodeSanook.SqlGenerator
{
    public class SqlExportTool
    {
        private static Regex valueOfColumnNamePattern = new Regex(
            @"(?<prefix>#{1,2}){\s*(?<noWrap>!')?(?<columnName>\w+\*?)\s*}",
            RegexOptions.Compiled
        );

        //https://stackoverflow.com/questions/10704462/how-can-i-have-nhibernate-only-generate-the-sql-without-executing-it
        public void Export(ExportOptions options)
        {
            var sessionFactory = CreateSessionFactory(options);
            var script = new StringBuilder();
            using (var session = sessionFactory.OpenStatelessSession())
            {
                var connection = (SqlConnection)session.Connection;
                var command = connection.CreateCommand();
                command.CommandText = options.Query;
                using (var reader = command.ExecuteReader())
                {
                    //first row create template and get data
                    string template = null;
                    ColumnMetaData[] columnMetaDatas = null;
                    if (reader.Read())
                    {
                        columnMetaDatas = GetColumnMetaDatas(reader);
                        template = PrepareTemplatePlaceHolder(options.Template, columnMetaDatas);
                        AppendScriptValues(reader, columnMetaDatas, template, script);
                    }

                    //next row get data only
                    while (reader.Read())
                    {
                        AppendScriptValues(reader, columnMetaDatas, template, script);
                    }
                }

                // convert string to stream
                var byteArray = Encoding.UTF8.GetBytes(script.ToString());
                var inputStream = new MemoryStream(byteArray);
                byte[] buffer = new byte[8 * 1024];
                int length;
                while ((length = inputStream.Read(buffer, 0, buffer.Length)) > 0)
                {
                    options.Stream.Write(buffer, 0, length);
                }
            }
        }

        private static ColumnMetaData[] GetColumnMetaDatas(SqlDataReader reader)
        {
            //https://stackoverflow.com/a/27200892/1872200
            //https://ayende.com/blog/4548/nhibernate-streaming-large-result-sets
            return Enumerable.Range(0, reader.FieldCount)
                .Select(columnIndex =>
                new ColumnMetaData(
                    reader.GetName(columnIndex),
                    reader.GetFieldType(columnIndex),
                    reader.GetDataTypeName(columnIndex),
                    columnIndex
                )).ToArray();
        }

        private static void AppendScriptValues(SqlDataReader reader, ColumnMetaData[] columnMetaDatas, string template, StringBuilder script)
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
                    //get CSV names of all columns
                    var columnNames = columns.Select(column => $"[{column.Name}]");
                    template = template.Replace(match.Value, string.Join(", ", columnNames));
                }
                else if (columnName.ToLower() == "col*")
                {
                    //get CSV values of all columns

                    var columnPlaceholderIndexes = columns.Select(column => $"{{{column.Index}}}");
                    template = template.Replace(match.Value, string.Join(", ", columnPlaceholderIndexes));
                }
                else
                {
                    //get a value of a given column name
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

        private static ISessionFactory CreateSessionFactory(ExportOptions options)
            => Fluently.Configure()
                .Database(GetDatabaseConfiguration(options))
                .Mappings(m => m.FluentMappings.AddFromAssemblyOf<SqlExportTool>())
                .BuildSessionFactory();

        private static IPersistenceConfigurer GetDatabaseConfiguration(ExportOptions options)
        {
            switch (options.DatabaseType)
            {
                case DatabaseType.SqlServer:
                    return GetSqlServerConfiguration(options.ConnectionString);
                default:
                    throw new InvalidOperationException("Invalid database type.");
            }
        }

        private static IPersistenceConfigurer GetSqlServerConfiguration(string connectionString)
            => MsSqlConfiguration.MsSql2012.ConnectionString(connectionString);

        private static IPersistenceConfigurer GetMySqlConfiguration(string connectionString)
            => MySQLConfiguration.Standard.ConnectionString(connectionString);
    }
}