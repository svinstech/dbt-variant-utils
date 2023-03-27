select 
    {{ dbt_variant_utils.as_primitive('integer', "get(extract, 'same_type')", '2') }} cast_same_type,
    {{ dbt_variant_utils.as_primitive('varchar', "get(extract, 'with_null')", '2') }} cast_with_null,
    {{ dbt_variant_utils.as_primitive('boolean', "get(extract, 'different_types')", '2') }} cast_different_types,
    {{ dbt_variant_utils.as_primitive('decimal', "get(extract, 'decimal_number')", '9') }} cast_decimal_number,
    {{ dbt_variant_utils.as_primitive('decimal', "get(extract, 'string_number')", '2', try_casting=True) }} cast_string_number
from {{ ref('stg_as_primitive')}}
