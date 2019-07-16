using NHibernate;
using System.Collections.Generic;

namespace CodeSanook.SqlGenerator
{
    public static class NHibernateExtensions
    {
        public static IList<IDictionary<string, object>> Dictionary(this IQuery query)
            => query
                .SetResultTransformer(NhTransformers.ExpandoObject)
                .List<IDictionary<string, object>>();
    }
}