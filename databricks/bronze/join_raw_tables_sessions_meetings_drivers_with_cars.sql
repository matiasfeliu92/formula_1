--CREACION DE TABLA DE DATOS CRUDOS UNIFICADOS (MEETINGS+SESSIONS+DRIVERS+CARS)
CREATE OR REPLACE TABLE formula_1.STG_cars_by_drivers_sessions_meetings AS
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
FROM
	formula_1.raw_meetings AS meet
JOIN formula_1.raw_sessions AS sess ON meet.meeting_key = sess.meeting_key
JOIN formula_1.raw_drivers AS driv ON meet.meeting_key = driv.meeting_key AND sess.session_key = driv.session_key
JOIN formula_1.raw_cars_data AS car ON meet.meeting_key = car.meeting_key AND sess.session_key = car.session_key AND driv.driver_number = car.driver_number;