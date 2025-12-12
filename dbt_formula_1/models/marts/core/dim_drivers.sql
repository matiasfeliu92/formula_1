{{ config(
    materialized='table'
) }}

SELECT 
  DISTINCT
    CAST(CONCAT(driver_number, session_key) AS INTEGER) AS driver_key,
    driver_number,
    first_name, 
    last_name,
    full_name,
    broadcast_name, 
    -- driver_country_code, 
    team_name
FROM 
  {{ ref('int_transform_laps_data') }}
ORDER BY
  driver_key