SELECT
  *
FROM
  formula_1.stg_laps_by_drivers_sessions_meetings
WHERE
  country_name ='Brazil';

SELECT
  *
FROM
  formula_1.stg_laps_by_drivers_sessions_meetings
WHERE
  lap_duration IS NULL;


  ---------------------------------------------------------------------------


SELECT
  *
FROM
  formula_1.int_transform_laps_data;