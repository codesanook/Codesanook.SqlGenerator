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

            Parser.Default.ParseArguments<ExportOptions>(args)
                .MapResult(
                    (ExportOptions opts) => ExportSqlInsert(opts),
                    errs => 1);

        }

        private static int ExportSqlInsert(ExportOptions options)
        {
            var sessionFactory = CreateSessionFactory(options);
            IList<IDictionary<string, object>> result;
            using (var session = sessionFactory.OpenSession())
            {
                var query = session.CreateSQLQuery(options.Query);
                result = query.Dictionary();
            }

            if (result.Any())
            {
                var template = CreateTemplate(result[0], options.Table);

                var script = new StringBuilder(); 
                foreach(var row in result)
                {

                    var values = row.Values.Select((value) => WrapWithQuote(value));
                    script.AppendFormat(template, string.Join(", ", values)); 
                }

                script.AppendLine();
                System.Console.WriteLine(script);
            }

            return 0;
        }

        private static string CreateTemplate(IDictionary<string, object> row, string tableName)
        {
            var template = new StringBuilder();
            template.AppendFormat("INSERT INTO [{0}] ",tableName);
            template.Append("(");
            var columns = row.Keys.Select(column => $"[{column}]");
            template.Append(string.Join(", ", columns));
            template.Append(")");
            template.Append("\n VALUES \n");
            template.AppendLine("({0})");

            return template.ToString();
        }

        private static string WrapWithQuote(object value)
        {
            if(value == null)
            {
                return "NULL";
            }

            switch (Type.GetTypeCode(value?.GetType()))
            {
                case TypeCode.String:
                    return $"'{value}'";
                case TypeCode.DateTime:
                    return $"'{value:yyyy-MM-dd HH:mm:ss}'";
                case TypeCode.Object:
                    if (value.GetType() == typeof(Guid))
                    {
                        return $"'{value}'";
                    }
                    else
                    {
                        return  $"{value}";
                    }
                case TypeCode.Boolean:
                    return Convert.ToBoolean(value) == true ? "1" : "0";
                default:
                    return $"{value}";
            }
        }

        private static ISessionFactory CreateSessionFactory(ExportOptions options)
        {
            return Fluently.Configure()
              .Database(GetDatabaseConfiguration(options)).Mappings(m => m
                  .FluentMappings.AddFromAssemblyOf<Program>())
              .BuildSessionFactory();
        }


        private static IPersistenceConfigurer GetDatabaseConfiguration(ExportOptions options)
        {

            switch (options.DatabaseType)
            {
                case DatabaseType.SqlServer:
                    return GetSqlServerConfiguration(options.ConnectionString);
                case DatabaseType.MySql:
                    return GetMySqlConfiguration(options.ConnectionString);
                default:
                    throw new InvalidOperationException("Invalid database type.");
            }
        }

        private static IPersistenceConfigurer GetSqlServerConfiguration(string connectionString)
        {
            return MsSqlConfiguration.MsSql2012.ConnectionString(connectionString);
        }


        private static IPersistenceConfigurer GetMySqlConfiguration(string connectionString)
        {
            return MySQLConfiguration.Standard.ConnectionString(connectionString);
        }

    }
}
