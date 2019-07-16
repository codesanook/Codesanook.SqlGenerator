using NHibernate.Transform;
using System.Collections;
using System.Collections.Generic;

namespace CodeSanook.SqlGenerator
{
    //credit https://adrianphinney.com/post/18900251364/nhibernate-raw-sql-and-dynamic-result-sets
    // https://stackoverflow.com/questions/10704462/how-can-i-have-nhibernate-only-generate-the-sql-without-executing-it
    public class NhTransformers
    {
        public static readonly IResultTransformer ExpandoObject;
        static NhTransformers() => ExpandoObject = new ExpandoObjectResultSetTransformer();

        private class ExpandoObjectResultSetTransformer : IResultTransformer
        {
            public IList TransformList(IList collection) => collection;

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
}