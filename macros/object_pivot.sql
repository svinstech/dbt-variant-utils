{%- macro object_pivot(t, c, primitive=true, include_columns=[], exclude_keys=['null'], force_varchar=[], try_casting=False) -%}
    {%- set query = "select distinct key, regexp_replace(key, '[ .]', '_') as alias_key from " ~ t ~ ", lateral flatten(" ~ c ~ ")" -%}
    {%- set keys_query = run_query(query) -%}
    
    {%- if execute -%}
    {%- set keys = keys_query.columns[0].values() -%}
    {%- set alias_keys = keys_query.columns[1].values() -%}
    {%- else -%}
    {%- set keys = [] -%}
    {%- set alias_keys = [] -%}
    {%- endif -%}

    select
    {%- for ic in include_columns %}
        {{ ic }}{%- if not loop.last -%},{%- endif -%}
    {%- endfor -%}
        {%- if keys|length > 0 -%},{%- endif -%}
    {%- for k in keys -%}
    {%- set alias_key = alias_keys[loop.index0] -%}
        {%- if k not in exclude_keys -%}
            {%- if primitive -%}
                {%- if k in force_varchar %}
                    as_varchar(get({{ c }}, '{{ k }}')) as {{ alias_key }}
                {%- else -%}
                    {{ dbt_variant_utils.as_primitive(t, "get(" ~ c ~ ", '" ~ k ~ "')", try_casting) }} as {{ alias_key }}
                {%- endif -%}
            {%- else -%}
                get({{ c }}, '{{ k }}') as {{ alias_key }}
            {%- endif -%}
            {%- if not loop.last -%},{%- endif -%}
        {%- endif -%}
    {%- endfor %}
    from {{ t }}
{% endmacro %}
