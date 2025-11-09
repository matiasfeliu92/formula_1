--CREACION DE TABLA DE DATOS CRUDOS UNIFICADOS (MEETINGS+SESSIONS+DRIVERS+LAPS)
IF OBJECT_ID('[Staging].[laps_by_drivers_sessions_meetings]', 'U') IS NOT NULL
DROP TABLE [Staging].[laps_by_drivers_sessions_meetings];

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
	TRY_CAST(lap.duration_sector_1 AS DECIMAL(8,2)) AS duration_sector_1,
	TRY_CAST(lap.duration_sector_2 AS DECIMAL(8,2)) AS duration_sector_2,
	TRY_CAST(lap.duration_sector_3 AS DECIMAL(8,2)) AS duration_sector_3,
	TRY_CAST(lap.i1_speed AS DECIMAL(8,2)) AS i1_speed,
	TRY_CAST(lap.i2_speed AS DECIMAL(8,2)) AS i2_speed,
	lap.is_pit_out_lap,
	lap.lap_duration,
	lap.segments_sector_1,
	lap.segments_sector_2,
	lap.segments_sector_3,
	TRY_CAST(lap.st_speed AS DECIMAL(8,2)) AS st_speed
INTO 
	[Staging].[laps_by_drivers_sessions_meetings]
FROM
	[Staging].[Meetings] AS meet
JOIN [Staging].[Sessions] AS sess ON meet.meeting_key = sess.meeting_key
JOIN [Staging].[Drivers] AS driv ON meet.meeting_key = driv.meeting_key AND sess.session_key = driv.session_key
JOIN [Staging].[Laps] AS lap ON meet.meeting_key = lap.meeting_key AND sess.session_key = lap.session_key AND driv.driver_number = lap.driver_number


--CREACION DE TABLA DE DATOS CRUDOS UNIFICADOS (MEETINGS+SESSIONS+DRIVERS+CARS)
IF OBJECT_ID('[Staging].[cars_by_drivers_sessions_meetings]', 'U') IS NOT NULL
DROP TABLE [Staging].[cars_by_drivers_sessions_meetings];

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
	car.date,
	car.brake,
	car.drs,
	car.n_gear,
	car.rpm,
	car.throttle,
	car.speed
INTO 
	[Staging].[cars_by_drivers_sessions_meetings]
FROM
	[Staging].[Meetings] AS meet
JOIN [Staging].[Sessions] AS sess ON meet.meeting_key = sess.meeting_key
JOIN [Staging].[Drivers] AS driv ON meet.meeting_key = driv.meeting_key AND sess.session_key = driv.session_key
JOIN [Staging].[Cars] AS car ON meet.meeting_key = car.meeting_key AND sess.session_key = car.session_key AND driv.driver_number = car.driver_number