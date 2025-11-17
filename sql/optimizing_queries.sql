SELECT COUNT(*) FROM [Staging].[cars_by_drivers_sessions_meetings]

SELECT COUNT(*) FROM [Staging].[laps_by_drivers_sessions_meetings]

EXEC sp_helpindex '[Staging].[cars_by_drivers_sessions_meetings]';

SELECT DISTINCT [meeting_name] FROM [Staging].[cars_by_drivers_sessions_meetings];

ALTER TABLE [Staging].[cars_by_drivers_sessions_meetings]
ALTER COLUMN meeting_name NVARCHAR(100) NOT NULL

CREATE CLUSTERED INDEX idx_meeting_name
ON [Staging].[cars_by_drivers_sessions_meetings] (meeting_name)

SET STATISTICS TIME ON;

SELECT 
	* 
FROM 
	[Staging].[cars_by_drivers_sessions_meetings];

-----------------------------------------------------------------------------------------------
--1) Filtrar por país y sesión (creamos un indice compuesto usando las columnas meeting_country_code y session_name
-----------------------------------------------------------------------------------------------
ALTER TABLE [Staging].[cars_by_drivers_sessions_meetings]
ALTER COLUMN meeting_country_code CHAR(8) NOT NULL;

ALTER TABLE [Staging].[cars_by_drivers_sessions_meetings]
ALTER COLUMN session_name NVARCHAR(50) NOT NULL;

CREATE NONCLUSTERED INDEX idx_country_session
ON [Staging].[cars_by_drivers_sessions_meetings] (meeting_country_code, session_name);

SELECT
	*
FROM 
	[Formula1].[Staging].[cars_by_drivers_sessions_meetings]
WHERE
	country_name = 'Mexico'
	AND
	session_name = 'Race'


-----------------------------------------------------------------------------------------------
--2) Agrupacion por piloto y equipo (creamos un indice compuesto usando las columnas full_name y team_name)
-----------------------------------------------------------------------------------------------
ALTER TABLE [Staging].[cars_by_drivers_sessions_meetings]
ALTER COLUMN full_name NVARCHAR(50) NOT NULL;

ALTER TABLE [Staging].[cars_by_drivers_sessions_meetings]
ALTER COLUMN team_name NVARCHAR(50) NOT NULL;

CREATE NONCLUSTERED INDEX idx_driver_team
ON [Formula1].[Staging].[cars_by_drivers_sessions_meetings] (full_name, team_name);

SELECT 
	full_name, 
	team_name, 
	COUNT(*) AS total_sessions
FROM 
	[Formula1].[Staging].[cars_by_drivers_sessions_meetings]
GROUP BY 
	full_name, 
	team_name
ORDER BY
	COUNT(*) DESC
;

-----------------------------------------------------------------------------------------------
--3) Filtrar por fecha de sesión (creamos un indice usando la columna session_date_start)
-----------------------------------------------------------------------------------------------

ALTER TABLE [Staging].[cars_by_drivers_sessions_meetings]
ALTER COLUMN session_date_start NVARCHAR(50) NOT NULL;

CREATE NONCLUSTERED INDEX idx_session_date
ON [Formula1].[Staging].[cars_by_drivers_sessions_meetings] (session_date_start);

SELECT
	*
FROM
	[Staging].[cars_by_drivers_sessions_meetings]
WHERE
	[session_date_start] BETWEEN '2025-01-01' AND TRY_CAST(DATEADD(day, -1, GETDATE()) AS NVARCHAR(50))
ORDER BY
	[session_date_start];


CREATE NONCLUSTERED INDEX idx_session_driver
ON [Formula1].[Staging].[cars_by_drivers_sessions_meetings] (session_name, full_name)
INCLUDE (speed, rpm);


SELECT 
	full_name, 
	AVG(TRY_CAST(speed AS DECIMAL(8,2))) AS avg_speed,
	MAX(rpm) AS max_rpm
FROM 
	[Formula1].[Staging].[cars_by_drivers_sessions_meetings]
WHERE 
	session_name = 'Qualifying'
GROUP BY 
	full_name;