{% macro safe_cast_array_values(field, fallback='ARRAY[0]::integer[]') %}
  CASE
    WHEN {{ field }} IN ('', 'None', 'null', 'NaN', 'nan') OR {{ field }} IS NULL THEN {{ fallback }}
    WHEN {{ field }} !~ '^\{[0-9, ]*\}$' THEN {{ fallback }}  -- validación de formato array
    ELSE {{ field }}::integer[]
  END
{% endmacro %}