{%- macro object_pivot(t, c, primitive=true, include_columns=[], exclude_keys=['null'], force_varchar=[], try_casting=False) -%}
    {%- set query = " 
        select 
            key, 
            regexp_replace(key, '[ .]', '_') as alias_key,
            ifnull(try_parse_json(value), value) as parsed,
            typeof(parsed) as type, 
            ifnull(len(split(parsed, '.')[1]), 2) as scale
        from " ~ t ~ ", lateral flatten(" ~ c ~ ")
        qualify row_number() over(partition by key order by iff(type = 'NULL_VALUE', null, type), length(parsed) desc) = 1" -%}
    {%- set keys_query = run_query(query) -%}
    
    {%- if execute -%}
    {%- set keys = keys_query.columns[0].values() -%}
    {%- set alias_keys = keys_query.columns[1].values() -%}
    {%- set data_types = keys_query.columns[3].values() -%}
    {%- set scales = keys_query.columns[4].values() -%}
    {%- else -%}
    {%- set keys = [] -%}
    {%- set alias_keys = [] -%}
    {%- set data_types = [] -%}
    {%- set scales = [] -%}
    {%- endif -%}

    select
    {%- for ic in include_columns %}
        {{ ic }}{%- if not loop.last -%},{%- endif -%}
    {%- endfor -%}
        {%- if keys|length > 0 -%},{%- endif -%}
    {%- for k in keys -%}
    {%- set alias_key = alias_keys[loop.index0] -%}
    {%- set data_type = data_types[loop.index0] -%}
    {%- set scale = scales[loop.index0] -%}
        {%- if k not in exclude_keys -%}
            {%- if primitive -%}
                {%- if k in force_varchar %}
                    as_varchar(get({{ c }}, '{{ k }}')) as {{ alias_key }}
                {%- else -%}
                    {{ dbt_variant_utils.as_primitive(data_type, "get(" ~ c ~ ", '" ~ k ~ "')", scale, try_casting) }} as {{ alias_key }}
                {%- endif -%}
            {%- else -%}
                get({{ c }}, '{{ k }}') as {{ alias_key }}
            {%- endif -%}
            {%- if not loop.last -%},{%- endif -%}
        {%- endif -%}
    {%- endfor %}
    from {{ t }}
{% endmacro %}
