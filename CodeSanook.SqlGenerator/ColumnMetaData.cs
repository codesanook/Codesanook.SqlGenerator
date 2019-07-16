using System;

namespace CodeSanook.SqlGenerator
{
    public class ColumnMetaData
    {
        public ColumnMetaData(string name, Type dotNetType, string sqlType, int index)
        {
            Name = name;
            DotNetType = dotNetType;
            SqlType = sqlType;
            Index = index;
            ValuePlaceHolder = new Lazy<string>(() =>
            {
                //switch type
                //https://stackoverflow.com/a/299001/1872200
                switch (dotNetType.Name)
                {
                    case nameof(String):
                    case nameof(Guid):
                    case nameof(DateTime):
                        return WrapQuote($"{{{0}}}");//'{0}' or {0}
                    default:
                        return $"{{{0}}}";//{0}
                }
            });
        }

        public string Name { get; }
        public Type DotNetType { get; }
        public string SqlType { get; }
        public int Index { get; }
        public bool NoWrap { get; set; }
        private Lazy<string> ValuePlaceHolder { get; }
        private string NullValuePlaceHolder { get; } = "NULL";
        private string WrapQuote(string format) => NoWrap ? format : $"'{format}'";

        public string Format(object value, bool isDBNull)
        {
            if (isDBNull) return NullValuePlaceHolder;

            switch (DotNetType.Name)
            {
                case nameof(String):
                    // Replace content that contains ' (single quote) to '' (double quote)
                    return string.Format(ValuePlaceHolder.Value, value.ToString().Replace("'", "''"));
                case nameof(DateTime):
                    return string.Format(ValuePlaceHolder.Value, ((DateTime)value).ToString("yyyy-MM-dd HH:mm:ss"));
                case nameof(Boolean):
                    return string.Format(ValuePlaceHolder.Value, (bool)value ? "1" : "0");
                default:
                    return string.Format(ValuePlaceHolder.Value, value);
            }
        }
    }
}