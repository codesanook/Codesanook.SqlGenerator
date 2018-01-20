using NHibernate;
using NHibernate.Transform;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeSanook.SqlGenerator.Console
{
    //credit https://adrianphinney.com/post/18900251364/nhibernate-raw-sql-and-dynamic-result-sets
    class NhTransformers
    {
        public static readonly IResultTransformer ExpandoObject;

        static NhTransformers()
        {
            ExpandoObject = new ExpandoObjectResultSetTransformer();
        }

        private class ExpandoObjectResultSetTransformer : IResultTransformer
        {
            public IList TransformList(IList collection)
            {
                return collection;
            }

            public object TransformTuple(object[] tuple, string[] aliases)
            {
                var dictionary = new Dictionary<string, object>();
                for (int i = 0; i < tuple.Length; i++)
                {
                    string alias = aliases[i];
                    if (alias != null)
                    {
                        dictionary[alias] = tuple[i];
                    }
                }
                return dictionary;
            }
        }
    }

    public static class NHibernateExtensions
    {
        public static IList<IDictionary<string,object>> Dictionary(this IQuery query)
        {
            return query.SetResultTransformer(NhTransformers.ExpandoObject)
                        .List<IDictionary<string,object>>();
        }

    }
}
