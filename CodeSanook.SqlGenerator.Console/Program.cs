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

            var firstResult = queryResult[0];
            var template = !string.IsNullOrWhiteSpace(options.Template)
                ? PrepareTemplatePlaceHolder(options.Template, firstResult)
                : CreateInsertStatementTemplate(firstResult, options.Table);

            Func<object, object> WrapQuoteIfTableExport;
            if (!string.IsNullOrEmpty(options.Table))
            {
                WrapQuoteIfTableExport = (input) => WrapWithQuote(input);
            }
            else
            {
                WrapQuoteIfTableExport = (input) => input;
            }

            var script = new StringBuilder();
            foreach (var row in queryResult)
            {
                var values = row.Values.Select((value) => WrapQuoteIfTableExport(value));
                script.AppendFormat(template, values.ToArray());
            }

            script.AppendLine();
            System.Console.WriteLine(script);
            return 0;
        }

        private static string PrepareTemplatePlaceHolder(string template, IDictionary<string, object> firstRow)
        {
            var columns = firstRow.Keys
                .Select((c, index) => new { key = $"c{index}", value = c })
                .ToDictionary(c => c.key, c => c.value);

            foreach (var column in columns)
            {
                template = template.Replace(column.Key, $"{column.Value}");
            }

            var matches = Regex.Matches(template, @"v(\d+)");
            foreach (Match match in matches)
            {
                var valueIndex = match.Groups[1];
                template = template.Replace(match.Value, $"{{{valueIndex}}}");
            }

            return template;
        }

        private static string CreateInsertStatementTemplate(IDictionary<string, object> row, string tableName)
        {
            var template = new StringBuilder();
            var columns = row.Keys.Select(column => $"[{column}]").ToArray();

            template.Append($"INSERT INTO [{tableName}]\n");
            template.Append($"({CreateColumnNames(columns)})\n");
            template.Append("VALUES\n");
            template.Append($"({CreateValueIndexes(columns)})");

            return template.ToString();
        }

        private static string CreateColumnNames(string[] columns)
            => string.Join(", ", columns);

        private static string CreateValueIndexes(string[] columns)
            => string.Join(", ", columns.Select((_, index) => $"{{{index}}}"));

        private static string WrapWithQuote(object value)
        {
            if (value == null) return "NULL";

            switch (Type.GetTypeCode(value?.GetType()))
            {
                case TypeCode.String:
                    return $"'{value.ToString().Replace("'", "''")}'";//to handle single quote in a string content
                case TypeCode.DateTime:
                    return $"'{value:yyyy-MM-dd HH:mm:ss}'";
                case TypeCode.Object:
                    return value.GetType() == typeof(Guid) ? $"'{value}'" : $"{value}";
                case TypeCode.Boolean:
                    return Convert.ToBoolean(value) ? "1" : "0";
                default:
                    return $"{value}";
            }
        }

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