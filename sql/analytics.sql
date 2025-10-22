USE Formula1;

SELECT 'Staging.Sessions' AS table_name, COUNT(*) AS count_rows FROM [Staging].[Sessions]
UNION ALL
SELECT 'Staging.Meetings' AS table_name, COUNT(*) AS count_rows FROM [Staging].[Meetings]
UNION ALL
SELECT 'Staging.Drivers' AS table_name, COUNT(*) AS count_rows FROM [Staging].[Drivers]
UNION ALL
SELECT 'Staging.Laps' AS table_name, COUNT(*) AS count_rows FROM [Staging].[Laps]
UNION ALL
SELECT 'Staging.Cars' AS table_name, COUNT(*) AS count_rows FROM [Staging].[Cars]
union all
SELECT 'Transformed.DimSessions' AS table_name, COUNT(*) AS count_rows FROM [Transformed].[DimSessions]
UNION ALL
SELECT 'Transformed.DimMeetings' AS table_name, COUNT(*) AS count_rows FROM [Transformed].[DimMeetings]
UNION ALL
SELECT 'Transformed.DimDrivers' AS table_name, COUNT(*) AS count_rows FROM [Transformed].[DimDrivers]
UNION ALL
SELECT 'Transformed.FactLaps' AS table_name, COUNT(*) AS count_rows FROM [Transformed].[FactLaps]
UNION ALL
SELECT 'Transformed.FactCars' AS table_name, COUNT(*) AS count_rows FROM [Transformed].[FactCars]

SELECT * FROM [Staging].[Drivers]

SELECT
	DISTINCT
		CAST(MAX([driver_number]) AS INT) AS driver_number,
		[broadcast_name],
		[full_name],
		CASE
			WHEN full_name LIKE '%BORTOLETO%' 
				OR 
				full_name LIKE '%GOETHE%' 
				THEN 'Trident'
			WHEN full_name LIKE '%FREDERICK%' 
				OR 
				full_name LIKE '%SAUCY%' 
				OR 
				full_name LIKE '%TSOLOV%'
				OR 
				full_name LIKE '%MARTINS%' 
				THEN 'ART Grand Prix'
			WHEN full_name LIKE '%EDGAR%'
				THEN 'MP Motorsport'
			WHEN full_name LIKE '%MINI%'
				THEN 'Hitech Pulse-Eight'
			WHEN full_name LIKE '%COLLET%'
				OR
				full_name LIKE '%SMITH%'
				THEN 'Van Amersfoort Racing'
			WHEN full_name LIKE '%DUNNE%'
				THEN 'Rodin Motorsport'
			WHEN full_name LIKE '%LINDBLAD%'
				OR
				full_name LIKE '%BARTER%'
				THEN 'Campos Racing'
			WHEN full_name LIKE '%ANTONELLI%'
				THEN 'Mercedes'
			WHEN full_name LIKE '%FLOERSCH%'
				OR
				full_name LIKE '%FARIA%'
				THEN 'PHM Racing by Charouz'
			WHEN full_name LIKE '%GARCIA%'
				OR
				full_name LIKE '%BEDRIN%'
				THEN 'Jenzer Motorsport'
			WHEN full_name LIKE '%ESTERSON%'
				THEN 'Rodin Carlin'
			ELSE team_name
		END AS team_name,
		CASE
			WHEN full_name LIKE '%BORTOLETO%' 
				OR 
				full_name LIKE '%COLLET%' 
				OR 
				full_name LIKE '%FARIA%' 
				OR 
				full_name LIKE '%FARIA%' 
				THEN 'BR'
			WHEN full_name LIKE '%GOETHE%' 
				OR 
				full_name LIKE '%FLOERSCH%'
				THEN 'DE'
			WHEN full_name LIKE '%FREDERICK%'
				THEN 'US'
			WHEN full_name LIKE '%SAUCY%'
				THEN 'CH'
			WHEN full_name LIKE '%TSOLOV%'
				THEN 'BG'
			WHEN full_name LIKE '%EDGAR%'
				OR
				full_name LIKE '%ESTERSON%'
				OR
				full_name LIKE '%LINDBLAD%'
				THEN 'GB'
			WHEN full_name LIKE '%MINI%'
				OR
				full_name LIKE '%ANTONELLI%'
				THEN 'IT'
			WHEN full_name LIKE '%SMITH%'
				OR
				full_name LIKE '%BARTER%'
				THEN 'AU'
			WHEN full_name LIKE '%BEDRIN%'
				THEN 'RU'
			WHEN full_name LIKE '%GARCIA%'
				THEN 'MX'
			WHEN full_name LIKE '%DUNNE%'
				THEN 'IE'
			ELSE country_code
		END AS country_code,
		meeting_key,
		session_key
FROM
	[Staging].[Drivers]
GROUP BY
	[broadcast_name],
	[full_name],
	team_name,
	[country_code],
	meeting_key,
	session_key
ORDER BY
	CAST(MAX([driver_number]) AS INT)

SELECT
	DISTINCT
		CAST([driver_number] AS INT) AS driver_number,
		[broadcast_name],
		[full_name],
		[team_name],
		[country_code]
FROM
	[Staging].[Drivers]
ORDER BY
	CAST([driver_number] AS INT)






WITH datos_unicos AS (
    SELECT DISTINCT driver_number, broadcast_name, full_name, team_name, country_code
    FROM [Staging].[Drivers]
)
SELECT 
    driver_number,
    STRING_AGG(broadcast_name, ', ') AS broadcast_names,
    STRING_AGG(full_name, ', ') AS full_names,
    STRING_AGG(team_name, ', ') AS team_names,
    STRING_AGG(country_code, ', ') AS country_codes
FROM datos_unicos
GROUP BY driver_number;


SELECT * FROM DimDrivers
SELECT * FROM FactLaps

--ANALIZAR CUANTAS CARRERAS CORRIO CADA PILOTO

--SELECT 
--    d.full_name AS piloto,
--    d.team_name AS equipo,
--	COUNT(m.meeting_key) AS cantidad_carreras
--FROM FactCars fc
--JOIN DimDrivers d ON fc.driver_number = d.driver_number
--JOIN DimMeetings m ON fc.meeting_key = m.meeting_key
--GROUP BY d.full_name, d.team_name
--ORDER BY COUNT(m.meeting_key) DESC