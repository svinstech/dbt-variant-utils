{%- macro as_primitive(t, c, try_casting=False) -%}
    {% set query = "
        select
            ifnull(try_parse_json(" ~ c ~ "), " ~ c ~ ") as parsed,
            typeof(parsed) as type, 
            ifnull(len(split(parsed, '.')[1]), 2) as scale 
        from " ~ t ~ " 
        where ifnull(type, 'NULL_VALUE') != 'NULL_VALUE'
        order by type, length(parsed) desc
        limit 1" %}
    {%- set type_query = run_query(query) -%}

    {%- if execute -%}
    {%- set type = type_query.columns[1][0] -%}
    {%- set scale = type_query.columns[2][0] -%}
    {%- else -%}
    {%- set type = none -%}
    {%- set scale = none -%}
    {%- endif -%}

    {%- if type and type|lower not in ['null_value'] -%}
        {%- if try_casting %}
            {%- if type|lower == 'decimal' %}
                try_cast({{ c }}::string as {{ type|lower }}(38, {{ scale }}))
            {%- elif type|lower == 'array' %}
                as_{{ type|lower }}({{ c }})
            {%- else %}
                try_cast({{ c }}::string as {{ type|lower }})
            {%- endif %}
        {%- else %}
            {%- if type|lower == 'decimal' %}
                as_{{ type|lower }}({{ c }}, 38, {{ scale }})
            {%- else %}
                as_{{ type|lower }}({{ c }})
            {%- endif -%}
        {%- endif -%}
    {%- else %}
        null
    {%- endif -%}
{% endmacro %}
