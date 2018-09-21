using CommandLine;
using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;
using NHibernate;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace CodeSanook.SqlGenerator.Console
{
    public class Program
    {
        private static Regex valueOfColumnNamePattern = new Regex(
            @"(?<prefix>#{1,2}){\s*(?<noWrap>!')?(?<columnName>\w+\*?)\s*}",
            RegexOptions.Compiled
        );

        //https://stackoverflow.com/questions/10704462/how-can-i-have-nhibernate-only-generate-the-sql-without-executing-it
        public static void Main(string[] args)
        {
            Parser.Default
                .ParseArguments<ExportOptions>(args)
                .MapResult(
                    opts => ExportSqlInsert(opts),
                    errs =>
                    {
                        return 1;
                    }
                );
        }

        private static int ExportSqlInsert(ExportOptions options)
        {
            var sessionFactory = CreateSessionFactory(options);
            IList<IDictionary<string, object>> queryResult;
            using (var session = sessionFactory.OpenSession())
            {
                var query = session.CreateSQLQuery(options.Query);
                queryResult = query.Dictionary();
            }

            if (!queryResult.Any()) return 0;
            var templateResult = PrepareTemplatePlaceHolder(options.Template, queryResult[0]);

            var script = new StringBuilder();
            foreach (var row in queryResult)
            {
                var values = row.Select(r => WrapValueWithQuote(r.Value, r.Key, templateResult.NowrapColumns)).ToArray();
                script.AppendFormat(
                    templateResult.Template,
                    values
                );
                script.AppendLine();
            }
            System.Console.WriteLine(script);
            return 0;
        }

        private static (string Template, HashSet<string> NowrapColumns) PrepareTemplatePlaceHolder(string template, IDictionary<string, object> firstRow)
        {
            var columnNames = firstRow.Keys
                .Select(column => $"[{column}]");

            var columnPlaceholderIndexes = firstRow.Keys
                .Select((_, index) => $"{{{index}}}");

            var columnIndexes = firstRow.Keys
                .Select((column, index) => new { Column = column, Index = index })
                .ToDictionary(c => c.Column, c => c.Index);

            var matches = valueOfColumnNamePattern.Matches(template);
            var noWrapColumns = new HashSet<string>();
            foreach (Match match in matches)
            {
                var prefix = match.Groups["prefix"].Value;
                var columnName = match.Groups["columnName"].Value; ;
                if (prefix == "##" && columnName.ToLower() == "col*")
                {
                    //get CSV names of all columns
                    template = template.Replace(match.Value, string.Join(", ", columnNames));
                }
                else if (columnName.ToLower() == "col*")
                {
                    //get CSV values of all columns
                    template = template.Replace(match.Value, string.Join(", ", columnPlaceholderIndexes));
                }
                else
                {
                    //get a value of a given column name

                    if (!columnIndexes.TryGetValue(columnName, out int columnIndex))
                    {
                        throw new InvalidOperationException($"No column {columnName} in select result.");
                    };

                    template = template.Replace(match.Value, $"{{{columnIndex}}}");
                    var noWrap = !string.IsNullOrWhiteSpace(match.Groups["noWrap"]?.Value);
                    if (noWrap)
                    {
                        noWrapColumns.Add(columnName);
                    }
                }
            }

            return (template, noWrapColumns);
        }

        private static string WrapValueWithQuote(object value, string columnName, HashSet<string> noWrapColumn)
        {
            if (value == null) return "NULL";

            switch (Type.GetTypeCode(value?.GetType()))
            {
                case TypeCode.String:
                    return $"{GetWrapValue(value.ToString().Replace("'", "''"), columnName, noWrapColumn)}";//to handle single quote in a string content
                case TypeCode.DateTime:
                    return $"{GetWrapValue($"{value:yyyy-MM-dd HH:mm:ss}", columnName, noWrapColumn)}";
                case TypeCode.Object:
                    return value.GetType() == typeof(Guid) 
                        ? $"{GetWrapValue(value.ToString(), columnName, noWrapColumn)}" 
                        : $"{value}";
                case TypeCode.Boolean:
                    return Convert.ToBoolean(value) 
                        ? "1" 
                        : "0";
                default:
                    return $"{value}";
            }
        }

        private static string GetWrapValue(string value, string columnName, HashSet<string> noWrapColumn)
            => noWrapColumn.Contains(columnName) ? value : $"'{value}'";

        private static ISessionFactory CreateSessionFactory(ExportOptions options)
            => Fluently.Configure()
                .Database(GetDatabaseConfiguration(options))
                .Mappings(m => m.FluentMappings.AddFromAssemblyOf<Program>())
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