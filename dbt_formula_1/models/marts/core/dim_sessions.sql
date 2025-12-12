{{ config(
    materialized='table'
) }}

SELECT
  DISTINCT
    session_key,
    session_name,
    session_type, 
    session_date_start, 
    session_date_end, 
    gmt_offset
FROM
  {{ ref('int_transform_laps_data') }}
ORDER BY
  session_key