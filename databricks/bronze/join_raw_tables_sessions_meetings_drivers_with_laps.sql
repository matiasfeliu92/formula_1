CREATE OR REPLACE TABLE formula_1.STG_laps_by_drivers_sessions_meetings AS 
SELECT
	meet.meeting_name,
	meet.meeting_official_name,
	meet.meeting_code,
	sess.session_name,
	sess.session_type,
	meet.circuit_short_name,
	meet.country_code AS meeting_country_code,
	meet.country_name,
	meet.location,
	meet.date_start as meeting_date_start,
	sess.date_start as session_date_start,
	sess.date_end as session_date_end,
	sess.gmt_offset,
	driv.first_name,
	driv.last_name,
	driv.full_name,
	driv.broadcast_name,
	driv.country_code AS driver_country_code,
	driv.team_name,
	lap.lap_number,
	lap.date_start as lap_date_start,
	CAST(lap.duration_sector_1 AS DECIMAL(8,2)) AS duration_sector_1,
	CAST(lap.duration_sector_2 AS DECIMAL(8,2)) AS duration_sector_2,
	CAST(lap.duration_sector_3 AS DECIMAL(8,2)) AS duration_sector_3,
	CAST(lap.i1_speed AS DECIMAL(8,2)) AS i1_speed,
	CAST(lap.i2_speed AS DECIMAL(8,2)) AS i2_speed,
	lap.is_pit_out_lap,
	lap.lap_duration,
	lap.segments_sector_1,
	lap.segments_sector_2,
	lap.segments_sector_3,
	CAST(lap.st_speed AS DECIMAL(8,2)) AS st_speed
FROM
	formula_1.raw_meetings AS meet
JOIN formula_1.raw_sessions AS sess ON meet.meeting_key = sess.meeting_key
JOIN formula_1.raw_drivers AS driv ON meet.meeting_key = driv.meeting_key AND sess.session_key = driv.session_key
JOIN formula_1.raw_laps AS lap ON meet.meeting_key = lap.meeting_key AND sess.session_key = lap.session_key AND driv.driver_number = lap.driver_number;