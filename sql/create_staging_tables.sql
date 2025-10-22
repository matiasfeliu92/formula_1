--CREACION DE SCHEMA PARA ALMACENAR TABLAS CON DATA SIN PROCESAR
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Staging'
)
BEGIN
    EXEC('CREATE SCHEMA Staging');
END

--CREACION DE LA TABLA STAGING Meetings
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Staging'
      AND TABLE_NAME = 'Meetings'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [Staging].[Meetings];
    CREATE TABLE Staging.Meetings (
        meeting_key NVARCHAR(MAX),
		circuit_key NVARCHAR(MAX),
        circuit_short_name NVARCHAR(MAX),
		meeting_code NVARCHAR(MAX),
		location NVARCHAR(MAX),
		country_key NVARCHAR(MAX),
		country_code NVARCHAR(MAX),
		country_name NVARCHAR(MAX),
		meeting_name NVARCHAR(MAX),
		meeting_official_name NVARCHAR(MAX),
		gmt_offset NVARCHAR(MAX),
		date_start NVARCHAR(MAX),
		year NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA STAGING Sessions
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Staging'
      AND TABLE_NAME = 'Sessions'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [Staging].[Sessions];
    CREATE TABLE Staging.Sessions (
        meeting_key NVARCHAR(MAX),
		session_key NVARCHAR(MAX),
		location NVARCHAR(MAX),
		date_start NVARCHAR(MAX),
		date_end NVARCHAR(MAX),
		session_type NVARCHAR(MAX),
		session_name NVARCHAR(MAX),
		country_key NVARCHAR(MAX),
		country_code NVARCHAR(MAX),
		country_name NVARCHAR(MAX),
		circuit_key NVARCHAR(MAX),
		circuit_short_name NVARCHAR(MAX),
		gmt_offset NVARCHAR(MAX),
		year NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA STAGING Drivers
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Staging'
      AND TABLE_NAME = 'Drivers'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [Staging].[Drivers];
    CREATE TABLE Staging.Drivers (
		meeting_key NVARCHAR(MAX),
		session_key NVARCHAR(MAX),
		driver_number NVARCHAR(MAX),
		broadcast_name NVARCHAR(MAX),
		full_name NVARCHAR(MAX),
		name_acronym NVARCHAR(MAX),
		team_name NVARCHAR(MAX),
		team_colour NVARCHAR(MAX),
		first_name NVARCHAR(MAX),
		last_name NVARCHAR(MAX),
		headshot_url NVARCHAR(MAX),
		country_code NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA STAGING Laps
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Staging'
      AND TABLE_NAME = 'Laps'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [Staging].[Laps];
    CREATE TABLE Staging.Laps (
		meeting_key NVARCHAR(MAX),
		session_key NVARCHAR(MAX),
		driver_number NVARCHAR(MAX),
		lap_number NVARCHAR(MAX),
		date_start NVARCHAR(MAX),
		duration_sector_1 NVARCHAR(MAX),
		duration_sector_2 NVARCHAR(MAX),
		duration_sector_3 NVARCHAR(MAX),
		i1_speed NVARCHAR(MAX),
		i2_speed NVARCHAR(MAX),
		is_pit_out_lap NVARCHAR(MAX),
		lap_duration NVARCHAR(MAX),
		segments_sector_1 NVARCHAR(MAX),
		segments_sector_2 NVARCHAR(MAX),
		segments_sector_3 NVARCHAR(MAX),
		st_speed NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA STAGING Laps
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Staging'
      AND TABLE_NAME = 'Cars'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS [Staging].[Cars];
    CREATE TABLE [Staging].[Cars] (
		date NVARCHAR(MAX),
		session_key NVARCHAR(MAX),
		brake NVARCHAR(MAX),
		n_gear NVARCHAR(MAX),
		meeting_key NVARCHAR(MAX),
		driver_number NVARCHAR(MAX),
		drs NVARCHAR(MAX),
		throttle NVARCHAR(MAX),
		speed NVARCHAR(MAX),
		rpm NVARCHAR(MAX)
    );
END