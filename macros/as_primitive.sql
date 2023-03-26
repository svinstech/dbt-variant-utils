{%- macro as_primitive(type, c, scale, try_casting=False) -%}
    {%- if type and type|lower not in ['null_value'] -%}
        {%- if try_casting %}
            {%- if type|lower == 'decimal' %}
                try_cast({{ c }}::string as {{ type|lower }}(38, {{ scale }}))
            {%- elif type|lower in ['array', 'object'] %}
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
