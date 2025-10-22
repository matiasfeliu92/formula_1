INSERT INTO
	[Transformed].[DimCircuits]
	(circuit_key, circuit_short_name, meeting_code, location)
SELECT
	DISTINCT
		CAST(circuit_key AS INT) AS circuit_key,
		circuit_short_name,
		meeting_code,
		location
FROM
	[Staging].[Meetings]
ORDER BY
	CAST(circuit_key AS INT)

INSERT INTO
	[Transformed].[DimCountries]
	(country_key, country_code, country_name)
SELECT
	DISTINCT
		CAST(country_key AS INT) AS country_key,
		country_code,
		country_name
FROM
	[Staging].[Meetings]
WHERE
	country_name NOT LIKE '%Great%'
ORDER BY
	CAST(country_key AS INT)

INSERT INTO 
	[Transformed].[DimMeetings]
	(meeting_key, meeting_name, country_key, circuit_key)
SELECT
	meeting_key,
	meeting_name,
	country_key,
	circuit_key
FROM
	[Staging].Meetings

INSERT INTO 
	[Transformed].[DimSessions]
	(session_key, meeting_key, date_start, date_end, session_type, session_name, country_key, circuit_key)
SELECT
	session_key,
	meeting_key,
	date_start,
	date_end,
	session_type,
	session_name,
	country_key,
	circuit_key
FROM
	[Staging].[Sessions]

WITH datos_pilotos_unicos AS (
    SELECT DISTINCT 
        driver_number,
        broadcast_name,
        full_name,
        CASE
            WHEN full_name LIKE '%BORTOLETO%' OR full_name LIKE '%GOETHE%' THEN 'Trident'
            WHEN full_name LIKE '%FREDERICK%' OR full_name LIKE '%SAUCY%' OR full_name LIKE '%TSOLOV%' OR full_name LIKE '%MARTINS%' THEN 'ART Grand Prix'
            WHEN full_name LIKE '%EDGAR%' THEN 'MP Motorsport'
            WHEN full_name LIKE '%MINI%' THEN 'Hitech Pulse-Eight'
            WHEN full_name LIKE '%COLLET%' OR full_name LIKE '%SMITH%' THEN 'Van Amersfoort Racing'
            WHEN full_name LIKE '%DUNNE%' THEN 'Rodin Motorsport'
            WHEN full_name LIKE '%LINDBLAD%' OR full_name LIKE '%BARTER%' THEN 'Campos Racing'
            WHEN full_name LIKE '%ANTONELLI%' THEN 'Mercedes'
            WHEN full_name LIKE '%FLOERSCH%' OR full_name LIKE '%FARIA%' THEN 'PHM Racing by Charouz'
            WHEN full_name LIKE '%GARCIA%' OR full_name LIKE '%BEDRIN%' THEN 'Jenzer Motorsport'
            WHEN full_name LIKE '%ESTERSON%' THEN 'Rodin Carlin'
            ELSE team_name
        END AS team_name,
        CASE
            WHEN full_name LIKE '%BORTOLETO%' OR full_name LIKE '%COLLET%' OR full_name LIKE '%FARIA%' THEN 'BR'
            WHEN full_name LIKE '%GOETHE%' OR full_name LIKE '%FLOERSCH%' THEN 'DE'
            WHEN full_name LIKE '%FREDERICK%' THEN 'US'
            WHEN full_name LIKE '%SAUCY%' THEN 'CH'
            WHEN full_name LIKE '%TSOLOV%' THEN 'BG'
            WHEN full_name LIKE '%EDGAR%' OR full_name LIKE '%ESTERSON%' OR full_name LIKE '%LINDBLAD%' THEN 'GB'
            WHEN full_name LIKE '%MINI%' OR full_name LIKE '%ANTONELLI%' THEN 'IT'
            WHEN full_name LIKE '%SMITH%' OR full_name LIKE '%BARTER%' THEN 'AU'
            WHEN full_name LIKE '%BEDRIN%' THEN 'RU'
            WHEN full_name LIKE '%GARCIA%' THEN 'MX'
            WHEN full_name LIKE '%DUNNE%' THEN 'IE'
			WHEN full_name LIKE '%BEARMAN%' THEN 'GBR'
			WHEN full_name LIKE '%VESTI%' THEN 'DEN'
			WHEN full_name LIKE '%HIRAKAWA%' THEN 'JPN'
            ELSE country_code
        END AS country_code,
		meeting_key,
		session_key
    FROM [Staging].[Drivers]
)
--INSERT INTO [Transformed].[DimDrivers] (
--    driver_number, broadcast_name, full_name, team_name, country_code
SELECT 
    driver_number,
    STRING_AGG(broadcast_name, ', ') AS broadcast_names,
    STRING_AGG(full_name, ', ') AS full_names,
    STRING_AGG(team_name, ', ') AS team_names,
    STRING_AGG(country_code, ', ') AS country_codes,
	STRING_AGG(meeting_key, ', ') AS meeting_keys,
	STRING_AGG(session_key, ', ') AS session_keys
FROM datos_pilotos_unicos
GROUP BY driver_number;


