using CommandLine;
using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;
using NHibernate;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CodeSanook.SqlGenerator.Console
{
    public class Program
    {
        //https://stackoverflow.com/questions/10704462/how-can-i-have-nhibernate-only-generate-the-sql-without-executing-it
        public static void Main(string[] args)
        {
            Parser.Default
                .ParseArguments<ExportOptions>(args)
                .MapResult(opts => ExportSqlInsert(opts), errs => 1);
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

            if (queryResult.Any())
            {
                var insertTemplate = CreateInsertStatementTemplate(queryResult[0], options.Table);
                var script = new StringBuilder();
                foreach (var row in queryResult)
                {
                    var values = row.Values.Select((value) => WrapWithQuote(value));
                    script.AppendFormat(insertTemplate, string.Join(", ", values));
                }

                script.AppendLine();
                System.Console.WriteLine(script);
            }

            return 0;
        }

        private static string CreateInsertStatementTemplate(IDictionary<string, object> row, string tableName)
        {
            var template = new StringBuilder();
            template.AppendFormat("INSERT INTO [{0}]\n", tableName);
            template.Append("(");

            var columns = row.Keys.Select(column => $"[{column}]");
            template.Append(string.Join(", ", columns));
            template.Append(")");
            template.Append("\nVALUES\n");
            template.AppendLine("({0})");
            return template.ToString();
        }

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