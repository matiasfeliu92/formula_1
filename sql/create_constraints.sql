ALTER TABLE FactCars DROP CONSTRAINT FK_FactCars_Sessions;
ALTER TABLE FactLaps DROP CONSTRAINT FK_FactLaps_Sessions;
ALTER TABLE DimSessions DROP CONSTRAINT FK_DimSessions_Meetings;
ALTER TABLE DimSessions DROP CONSTRAINT FK_DimSessions_Circuits;
ALTER TABLE DimSessions DROP CONSTRAINT FK_DimSessions_Countries;



-- DimSessions
ALTER TABLE DimSessions
ALTER COLUMN session_key INT NOT NULL;
ALTER TABLE DimSessions
ADD CONSTRAINT PK_DimSessions PRIMARY KEY (session_key);

-- DimMeetings
ALTER TABLE DimMeetings
ALTER COLUMN meeting_key INT NOT NULL;
ALTER TABLE DimMeetings
ADD CONSTRAINT PK_DimMeetings PRIMARY KEY (meeting_key);

-- DimCountries
ALTER TABLE DimCountries
ALTER COLUMN country_key INT NOT NULL;
ALTER TABLE DimCountries
ADD CONSTRAINT PK_DimCountries PRIMARY KEY (country_key);

-- DimCircuits
ALTER TABLE DimCircuits
ALTER COLUMN circuit_key INT NOT NULL;
ALTER TABLE DimCircuits
ADD CONSTRAINT PK_DimCircuits PRIMARY KEY (circuit_key);

-- DimDrivers
ALTER TABLE DimDrivers
ALTER COLUMN driver_number INT NOT NULL;
ALTER TABLE DimDrivers
ADD CONSTRAINT PK_DimDrivers PRIMARY KEY (driver_number);




-- FactCars
ALTER TABLE FactCars
ALTER COLUMN session_key INT;
ALTER TABLE FactCars
ALTER COLUMN meeting_key INT;
ALTER TABLE FactCars
ALTER COLUMN driver_number INT;
ALTER TABLE FactCars
ADD CONSTRAINT FK_FactCars_Sessions FOREIGN KEY (session_key) REFERENCES DimSessions(session_key);
ALTER TABLE FactCars
ADD CONSTRAINT FK_FactCars_Drivers FOREIGN KEY (driver_number) REFERENCES DimDrivers(driver_number);
ALTER TABLE FactCars
ADD CONSTRAINT FK_FactCars_Meetings FOREIGN KEY (meeting_key) REFERENCES DimMeetings(meeting_key);

-- FactLaps
ALTER TABLE FactLaps
ALTER COLUMN session_key INT;
ALTER TABLE FactLaps
ALTER COLUMN driver_number INT;
ALTER TABLE FactLaps
ADD CONSTRAINT FK_FactLaps_Sessions FOREIGN KEY (session_key) REFERENCES DimSessions(session_key);
ALTER TABLE FactLaps
ADD CONSTRAINT FK_FactLaps_Drivers FOREIGN KEY (driver_number) REFERENCES DimDrivers(driver_number);

-- DimSessions
ALTER TABLE DimSessions
ALTER COLUMN meeting_key INT;
ALTER TABLE DimSessions
ALTER COLUMN country_key INT;
ALTER TABLE DimSessions
ALTER COLUMN circuit_key INT;
ALTER TABLE DimSessions
ADD CONSTRAINT FK_DimSessions_Meetings FOREIGN KEY (meeting_key) REFERENCES DimMeetings(meeting_key);
ALTER TABLE DimSessions
ADD CONSTRAINT FK_DimSessions_Circuits FOREIGN KEY (circuit_key) REFERENCES DimCircuits(circuit_key);
ALTER TABLE DimSessions
ADD CONSTRAINT FK_DimSessions_Countries FOREIGN KEY (country_key) REFERENCES DimCountries(country_key);

-- DimMeetings
ALTER TABLE DimMeetings
ALTER COLUMN circuit_key INT;
ALTER TABLE DimMeetings
ALTER COLUMN country_key INT;
ALTER TABLE DimMeetings
ADD CONSTRAINT FK_DimMeetings_Circuits FOREIGN KEY (circuit_key) REFERENCES DimCircuits(circuit_key);
ALTER TABLE DimMeetings
ADD CONSTRAINT FK_DimMeetings_Countries FOREIGN KEY (country_key) REFERENCES DimCountries(country_key);