{{ config(
    materialized='table'
) }}

SELECT
  DISTINCT
    meeting_key,
    meeting_name,
    meeting_official_name, 
    meeting_code,
    country_name, 
    location, 
    circuit_short_name, 
    meeting_date_start
FROM
  {{ ref('int_transform_laps_data') }}
ORDER BY
  meeting_key