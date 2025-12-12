WITH duration_sector_1_group AS (
  SELECT
    full_name,
    session_name,
    AVG(
      NULLIF(duration_sector_1, '') :: double precision
    ) AS duration_sector_1_mean
  FROM
    {{ ref('stg_laps_by_drivers_sessions_meetings') }}
  GROUP BY
    full_name,
    session_name
),
duration_sector_2_group AS (
  SELECT
    full_name,
    session_name,
    AVG(
      NULLIF(duration_sector_2, '') :: double precision
    ) AS duration_sector_2_mean
  FROM
    {{ ref('stg_laps_by_drivers_sessions_meetings') }}
  GROUP BY
    full_name,
    session_name
),
duration_sector_3_group AS (
  SELECT
    full_name,
    session_name,
    AVG(
      NULLIF(duration_sector_3, '') :: double precision
    ) AS duration_sector_3_mean
  FROM
    {{ ref('stg_laps_by_drivers_sessions_meetings') }}
  GROUP BY
    full_name,
    session_name
),
i1_speed_group AS (
  SELECT
    full_name,
    session_name,
    percentile_cont(0.5) within group (
      order by
        i1_speed :: double precision
    ) as i1_speed_median
  FROM
    {{ ref('stg_laps_by_drivers_sessions_meetings') }}
  GROUP BY
    full_name,
    session_name
),
i2_speed_group AS (
  SELECT
    full_name,
    session_name,
    percentile_cont(0.5) within group (
      order by
        i2_speed :: double precision
    ) as i2_speed_median
  FROM
    {{ ref('stg_laps_by_drivers_sessions_meetings') }}
  GROUP BY
    full_name,
    session_name
),
st_speed_group AS (
  SELECT
    full_name,
    session_name,
    percentile_cont(0.5) within group (
      order by
        st_speed :: double precision
    ) as st_speed_median
  FROM
    {{ ref('stg_laps_by_drivers_sessions_meetings') }}
  GROUP BY
    full_name,
    session_name
)
SELECT
  stg_laps.meeting_key::integer,
  stg_laps.circuit_key::integer,
  stg_laps.country_key,
  stg_laps.meeting_name,
  stg_laps.meeting_official_name,
  stg_laps.meeting_code,
  stg_laps.session_key::integer,
  stg_laps.session_name,
  stg_laps.session_type,
  stg_laps.circuit_short_name,
  stg_laps.meeting_country_code,
  stg_laps.country_name,
  stg_laps.location,
  stg_laps.meeting_date_start::timestamp with time zone,
  stg_laps.session_date_start::timestamp with time zone,
  stg_laps.session_date_end::timestamp with time zone,
  stg_laps.gmt_offset,
  stg_laps.driver_number::integer,
  stg_laps.first_name,
  stg_laps.last_name,
  stg_laps.full_name,
  stg_laps.broadcast_name,
  stg_laps.driver_country_code,
  stg_laps.team_name,
  stg_laps.lap_number::integer,
  stg_laps.lap_date_start::timestamp with time zone,
  {{ safe_cast_int_values('stg_laps.duration_sector_1', 'd_s_1_g.duration_sector_1_mean') }} AS duration_sector_1,
  {{ safe_cast_int_values('stg_laps.duration_sector_2', 'd_s_2_g.duration_sector_2_mean') }} AS duration_sector_2,
  {{ safe_cast_int_values('stg_laps.duration_sector_3', 'd_s_3_g.duration_sector_3_mean') }} AS duration_sector_3,
  {{ safe_cast_int_values('stg_laps.i1_speed', 'i1_s_g.i1_speed_median') }} AS i1_speed,
  {{ safe_cast_int_values('stg_laps.i2_speed', 'i2_s_g.i2_speed_median') }} AS i2_speed,
  stg_laps.is_pit_out_lap,
  CASE
    WHEN stg_laps.lap_duration IN ('', 'None', 'null', 'NaN', 'nan') OR stg_laps.lap_duration IS NULL THEN
      COALESCE(
        {{ safe_cast_int_values('stg_laps.duration_sector_1', '0') }} +
        {{ safe_cast_int_values('stg_laps.duration_sector_2', '0') }} +
        {{ safe_cast_int_values('stg_laps.duration_sector_3', '0') }}
      )
    ELSE stg_laps.lap_duration::double precision
  END AS lap_duration,
  {{ safe_cast_array_values('stg_laps.segments_sector_1') }},
  {{ safe_cast_array_values('stg_laps.segments_sector_2') }},
  {{ safe_cast_array_values('stg_laps.segments_sector_3') }},
  {{ safe_cast_int_values('stg_laps.st_speed', '0') }}
FROM
  {{ ref('stg_laps_by_drivers_sessions_meetings') }} AS stg_laps
  LEFT JOIN duration_sector_1_group d_s_1_g ON stg_laps.full_name = d_s_1_g.full_name
  AND stg_laps.session_name = d_s_1_g.session_name
  LEFT JOIN duration_sector_2_group d_s_2_g ON stg_laps.full_name = d_s_2_g.full_name
  AND stg_laps.session_name = d_s_2_g.session_name
  LEFT JOIN duration_sector_3_group d_s_3_g ON stg_laps.full_name = d_s_3_g.full_name
  AND stg_laps.session_name = d_s_3_g.session_name
  LEFT JOIN i1_speed_group i1_s_g ON stg_laps.full_name = i1_s_g.full_name
  AND stg_laps.session_name = i1_s_g.session_name
  LEFT JOIN i2_speed_group i2_s_g ON stg_laps.full_name = i2_s_g.full_name
  AND stg_laps.session_name = i2_s_g.session_name
  LEFT JOIN st_speed_group st_sp_g ON stg_laps.full_name = st_sp_g.full_name
  AND stg_laps.session_name = st_sp_g.session_name