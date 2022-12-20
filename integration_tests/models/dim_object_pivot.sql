{{ dbt_variant_utils.object_pivot(
    ref('stg_object_pivot'),
    'parsed_input',
    exclude_keys=['excluded_key'],
    include_columns=['idx'],
    force_varchar=['zip'],
    try_casting=True
) }}
