{{ config(
    materialized='table'
) }}

SELECT
  DISTINCT
    meet.meeting_key,
    ses.session_key,
    driv.driver_key,
    lap_number,
    ses.session_date_start AS lap_date_start,
    duration_sector_1,
    duration_sector_2,
    duration_sector_3,
    i1_speed,
    i2_speed,
    is_pit_out_lap,
    lap_duration,
    segments_sector_1,
    segments_sector_2,
    segments_sector_3,
    st_speed
FROM 
  {{ ref('int_transform_laps_data') }} as laps
JOIN
  {{ ref('dim_meetings') }} as meet ON laps.meeting_key = meet.meeting_key
JOIN
  {{ ref('dim_sessions') }} as ses ON laps.session_key = ses.session_key
JOIN
  {{ ref('dim_drivers') }} as driv ON laps.driver_number = driv.driver_number AND CAST(CONCAT(driv.driver_number, ses.session_key) AS INTEGER) = driv.driver_key