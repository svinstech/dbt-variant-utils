select
    parse_json(
    '{
        "same_type": 1,
        "with_null": "foo",
        "different_types": true,
        "decimal_number": 0.567453454,
        "string_number": "1.25"
    }'
    ) as extract
union all
select
    parse_json(
    '{
        "same_type": 2,
        "with_null": null,
        "different_types": 4,
        "decimal_number": 1.05,
        "string_number": 1
    }'
    ) as extract
union all
select
    parse_json(
    '{
        "same_type": 3,
        "with_null": "bar",
        "different_types": false,
        "decimal_number": 0.4532,
        "string_number": 1.5
    }'
    ) as extract
