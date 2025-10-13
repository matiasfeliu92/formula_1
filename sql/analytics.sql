USE Formula1;

SELECT * FROM DimDrivers

--ANALIZAR CUANTAS CARRERAS CORRIO CADA PILOTO

SELECT 
    d.full_name AS piloto,
    d.team_name AS equipo,
	COUNT(m.meeting_key) AS cantidad_carreras
FROM FactCars fc
JOIN DimDrivers d ON fc.driver_number = d.driver_number
JOIN DimMeetings m ON fc.meeting_key = m.meeting_key
GROUP BY d.full_name, d.team_name
ORDER BY COUNT(m.meeting_key) DESC