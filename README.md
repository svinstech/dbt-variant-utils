# dbt-variant-utils

Various [dbt](https://www.getdbt.com/) utilities for working with semi-structured `variant` data in Snowflake (including `object`s and `array`s).

## Macros

### as_primitive ([source](macros/as_primitive.sql))

Converts a `variant` to a primitive type using Snowflake's built-in [`typeof`](https://docs.snowflake.com/en/sql-reference/functions/typeof.html) function.
Returns `null` if the value cannot be cast to a primitive type.
The argument `try_casting` can be set to true if the data contains strings that are really some other type, e.g. decimal that is a string in the raw data. If this is set to true, the compiled SQL will look like this `try_cast(get(extract, 'value')::string as decimal(38, 13)) as value` and the string value will be converted to the assigned datatype where possible, otherwise `null` will be returned.

Usage:

```sql
select
    {{ dbt_variant_utils.as_primitive(ref('table'), 'column') }} as primitive_column
from {{ ref('table') }}
```

### object_pivot ([source](macros/object_pivot.sql))

Pivots a column of `object` types into a table with each column representing a key and each row representing a value.
If a key is missing from the input, its value will be `null` in the output table.
If there are certain columns that should be `varchar`, but may get cast as some other type (e.g. zip code), you can give the `force_varchar` argument a list of fields to always cast as varchar.
The argument `try_casting` can be set to true if the data contains strings that are really some other type, e.g. decimal that is a string in the raw data. If this argument is set to true, the compiled SQL will look like this `try_cast(get(extract, 'value')::string as decimal(38, 13)) as value` and the string value will be converted to the assigned datatype where possible, otherwise `null` will be returned.

```sql
with pivot_table as (
    {{ dbt_variant_utils.object_pivot(ref('table'), 'column') }}
)

select * from pivot_table
```

Configuration:
1. `primitive` – Returns primitive types if `true` else returns variants. Defaults to `true`.
2. `include_columns` – Additional columns to include from the source table, useful for including primary keys. Defaults to `[]`.
3. `exclude_keys` – Keys to exclude while flattening the object. Defaults to `['null']`.
