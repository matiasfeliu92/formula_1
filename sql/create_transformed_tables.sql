-- USE Formula1;

-- Eliminar FK de FactCars
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactCars_Sessions')
    ALTER TABLE Transformed.FactCars DROP CONSTRAINT FK_FactCars_Sessions;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactCars_Drivers')
    ALTER TABLE Transformed.FactCars DROP CONSTRAINT FK_FactCars_Drivers;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactCars_Meetings')
    ALTER TABLE Transformed.FactCars DROP CONSTRAINT FK_FactCars_Meetings;


-- Eliminar FK de FactLaps
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactLaps_Sessions')
    ALTER TABLE Transformed.FactLaps DROP CONSTRAINT FK_FactLaps_Sessions;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactLaps_Drivers')
    ALTER TABLE Transformed.FactLaps DROP CONSTRAINT FK_FactLaps_Drivers;


-- Eliminar FK de DimSessions
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimSessions_Meetings')
    ALTER TABLE Transformed.DimSessions DROP CONSTRAINT FK_DimSessions_Meetings;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimSessions_Circuits')
    ALTER TABLE Transformed.DimSessions DROP CONSTRAINT FK_DimSessions_Circuits;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimSessions_Countries')
    ALTER TABLE Transformed.DimSessions DROP CONSTRAINT FK_DimSessions_Countries;


-- Eliminar FK de DimMeetings
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMeetings_Circuits')
    ALTER TABLE Transformed.DimMeetings DROP CONSTRAINT FK_DimMeetings_Circuits;

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMeetings_Countries')
    ALTER TABLE Transformed.DimMeetings DROP CONSTRAINT FK_DimMeetings_Countries;


--CREACION DE SCHEMA PARA ALMACENAR TABLAS MODELADAS
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Transformed'
)
BEGIN
    EXEC('CREATE SCHEMA Transformed');
END

--CREACION DE LA TABLA DE DIMENSION DimCountries
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'DimCountries'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.DimCountries;
    CREATE TABLE Transformed.DimCountries (
        country_key INT NOT NULL PRIMARY KEY,
		country_code NVARCHAR(MAX),
        country_name NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA DE DIMENSION DimCircuits
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'DimCircuits'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.DimCircuits;
    CREATE TABLE Transformed.DimCircuits (
        circuit_key INT NOT NULL PRIMARY KEY,
        circuit_short_name NVARCHAR(MAX),
		meeting_code NVARCHAR(MAX),
        location NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA DE DIMENSION DimSessions
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'DimSessions'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.DimSessions;
    CREATE TABLE Transformed.DimSessions (
        session_key INT NOT NULL PRIMARY KEY,
        meeting_key INT,
        date_start DATE,
        date_end DATE,
        session_type NVARCHAR(MAX),
        session_name NVARCHAR(MAX),
        country_key INT,
        circuit_key INT
    );
END

--CREACION DE LA TABLA DE DIMENSION DimMeetings
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'DimMeetings'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.DimMeetings;
    CREATE TABLE Transformed.DimMeetings (
        meeting_key INT NOT NULL PRIMARY KEY,
        meeting_name NVARCHAR(MAX),
        country_key INT,
        circuit_key INT
    );
END

--CREACION DE LA TABLA DE DIMENSION DimDrivers
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'DimDrivers'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.DimDrivers;
    CREATE TABLE Transformed.DimDrivers (
        driver_number INT NOT NULL PRIMARY KEY,
        broadcast_name NVARCHAR(MAX),
		full_name NVARCHAR(MAX),
        team_name NVARCHAR(MAX),
        country_code NVARCHAR(MAX),
		meeting_key NVARCHAR(MAX),
		session_key NVARCHAR(MAX)
    );
END

--CREACION DE LA TABLA DE DIMENSION FactLaps
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'FactLaps'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.FactLaps;
    CREATE TABLE Transformed.FactLaps (
        lap_number INT NOT NULL PRIMARY KEY,
        session_key INT,
        driver_number INT,
        date_start DATE,
        lap_duration FLOAT,
        duration_sector_1 FLOAT,
        duration_sector_2 FLOAT,
        duration_sector_3 FLOAT,
        i1_speed INT,
        i2_speed INT,
        is_pit_out_lap BIT,
        segments_sector_1 NVARCHAR(MAX),
        segments_sector_2 NVARCHAR(MAX),
        segments_sector_3 NVARCHAR(MAX),
        st_speed INT
    );
END

--CREACION DE LA TABLA DE DIMENSION FactCars
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Transformed'
      AND TABLE_NAME = 'FactCars'
      AND TABLE_TYPE = 'BASE TABLE'
)
BEGIN
	DROP TABLE IF EXISTS Transformed.FactCars;
    CREATE TABLE Transformed.FactCars (
        id INT NOT NULL PRIMARY KEY,
		date DATE,
		session_key INT,
		meeting_key INT,
		driver_number INT,
		brake INT,
		throttle INT,
		drs INT,
		speed INT,
		rpm INT,
		n_gear INT
    );
END


IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactCars_Sessions'
)
BEGIN
    ALTER TABLE Transformed.FactCars
    ADD CONSTRAINT FK_FactCars_Sessions FOREIGN KEY (session_key) REFERENCES Transformed.DimSessions(session_key);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactCars_Drivers'
)
BEGIN
    ALTER TABLE Transformed.FactCars
    ADD CONSTRAINT FK_FactCars_Drivers FOREIGN KEY (driver_number) REFERENCES Transformed.DimDrivers(driver_number);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactCars_Meetings'
)
BEGIN
    ALTER TABLE Transformed.FactCars
    ADD CONSTRAINT FK_FactCars_Meetings FOREIGN KEY (meeting_key) REFERENCES Transformed.DimMeetings(meeting_key);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactLaps_Sessions'
)
BEGIN
    ALTER TABLE Transformed.FactLaps
    ADD CONSTRAINT FK_FactLaps_Sessions FOREIGN KEY (session_key) REFERENCES Transformed.DimSessions(session_key);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactLaps_Drivers'
)
BEGIN
    ALTER TABLE Transformed.FactLaps
    ADD CONSTRAINT FK_FactLaps_Drivers FOREIGN KEY (driver_number) REFERENCES Transformed.DimDrivers(driver_number);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimSessions_Meetings'
)
BEGIN
    ALTER TABLE Transformed.DimSessions
    ADD CONSTRAINT FK_DimSessions_Meetings FOREIGN KEY (meeting_key) REFERENCES Transformed.DimMeetings(meeting_key);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimSessions_Circuits'
)
BEGIN
    ALTER TABLE Transformed.DimSessions
    ADD CONSTRAINT FK_DimSessions_Circuits FOREIGN KEY (circuit_key) REFERENCES Transformed.DimCircuits(circuit_key);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimSessions_Countries'
)
BEGIN
    ALTER TABLE Transformed.DimSessions
    ADD CONSTRAINT FK_DimSessions_Countries FOREIGN KEY (country_key) REFERENCES Transformed.DimCountries(country_key);
END


IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMeetings_Circuits'
)
BEGIN
    ALTER TABLE Transformed.DimMeetings
    ADD CONSTRAINT FK_DimMeetings_Circuits FOREIGN KEY (circuit_key) REFERENCES Transformed.DimCircuits(circuit_key);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DimMeetings_Countries'
)
BEGIN
    ALTER TABLE Transformed.DimMeetings
    ADD CONSTRAINT FK_DimMeetings_Countries FOREIGN KEY (country_key) REFERENCES Transformed.DimCountries(country_key);
END