{% macro safe_cast_int_values(field, fallback=0) %}
  CASE
    WHEN {{ field }} IN ('', 'None', 'null', 'NaN', 'nan') OR {{ field }} IS NULL THEN {{ fallback }}
    ELSE {{ field }}::double precision
  END
{% endmacro %}