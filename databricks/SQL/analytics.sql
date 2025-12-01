---------------------------------------------------------------------------------------------------
-----------------------------------------VALIDACION DE DATOS-----------------------------------------
---------------------------------------------------------------------------------------------------

SELECT
  *
FROM
  formula_1.int_transform_laps_data
LIMIT 10;

SELECT
  *
FROM
  formula_1.int_transform_laps_data
WHERE
  country_name = 'Brazil'
  AND session_key BETWEEN 9859 AND 9869

SELECT
  COUNT(*)
FROM
  formula_1.raw_drivers;

SELECT
  MAX(date_start)
FROM
  formula_1.raw_sessions

SELECT
  MAX(date_start)
FROM
  formula_1.raw_meetings

SELECT
  DISTINCT
    TRY_CAST(CONCAT(driver_number, session_key) AS BIGINT) AS driver_key,
    driver_number,
    first_name,
    last_name,
    full_name,
    broadcast_name,
    driver_country_code,
    team_name
FROM
  formula_1.int_transform_laps_data;


---------------------------------------------------------------------------------------------------
-----------------------------------------MODELADO DE DATOS-----------------------------------------
---------------------------------------------------------------------------------------------------

-----------------DIM MEETINGS-----------------
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
  formula_1.int_transform_laps_data
ORDER BY
  meeting_key;

-----------------DIM DRIVERS-----------------
SELECT 
  DISTINCT
    TRY_CAST(CONCAT(driver_number, session_key) AS BIGINT) AS driver_key,
    driver_number,
    first_name, 
    last_name,
    full_name,
    broadcast_name, 
    driver_country_code, 
    team_name
FROM 
  formula_1.int_transform_laps_data
ORDER BY
  driver_key;

-----------------DIM SESSIONS-----------------
SELECT
  DISTINCT
    session_key,
    session_name,
    session_type, 
    session_date_start, 
    session_date_end, 
    gmt_offset
FROM
  formula_1.int_transform_laps_data
ORDER BY
  session_key;


-----------------FACT LAP_PERFORMANCE-----------------

SELECT
  DISTINCT
  meet.meeting_key,
  ses.session_key,
  driv.driver_key,
  lap_number,
  lap_date_start,
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
  formula_1.int_transform_laps_data as laps
JOIN
  formula_1.dim_meetings as meet ON laps.meeting_key = meet.meeting_key
JOIN
  formula_1.dim_sessions as ses ON laps.session_key = ses.session_key
JOIN
  formula_1.dim_drivers as driv ON laps.driver_number = driv.driver_number AND TRY_CAST(CONCAT(driv.driver_number, ses.session_key) AS BIGINT) = driv.driver_key;


---------------------------------------------------------------------------------------------------
-----------------------------------------PREGUNTAS A ANALIZAR-----------------------------------------
---------------------------------------------------------------------------------------------------

--¿Cuál es la vuelta ideal de un piloto (sumando el mejor Sector 1, Sector 2 y Sector 3 de una sesión) y cuánto se desvía su mejor vuelta real de este ideal?--

WITH ideal_lap_time AS (
  SELECT
    driver_key,
    session_key,
    MIN(duration_sector_1) AS ideal_sector_1,
    MIN(duration_sector_2) AS ideal_sector_2,
    MIN(duration_sector_3) AS ideal_sector_3,
    ROUND(MIN(duration_sector_1) + MIN(duration_sector_2) + MIN(duration_sector_3), 2) AS ideal_lap
  FROM
    formula_1.fact_laps_performance
  GROUP BY
    driver_key,
    session_key
),
best_lap AS (
  SELECT
    driver_key,
    session_key,
    lap_duration AS best_real_lap,
    RANK() OVER(PARTITION BY driver_key, session_key ORDER BY lap_duration ASC) as best_lap_rank
  FROM
    formula_1.fact_laps_performance
)
SELECT
  driv.full_name,
  ses.session_name,
  ILT.ideal_lap,
  BL.best_real_lap,
  ROUND(ILT.ideal_lap - BL.best_real_lap, 2) AS lap_difference,
  ILT.ideal_sector_1,
  ILT.ideal_sector_2,
  ILT.ideal_sector_3
FROM
  ideal_lap_time ILT
JOIN
  formula_1.dim_drivers driv ON ILT.driver_key = driv.driver_key
JOIN
  formula_1.dim_sessions ses ON ILT.session_key = ses.session_key
JOIN
  best_lap BL ON ILT.driver_key = BL.driver_key
WHERE
  BL.best_lap_rank = 1 AND driv.full_name LIKE '%COLAPINTO%'