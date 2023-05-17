--drop Station table if it exists
BEGIN   
    IF OBJECT_ID('dbo.dimStation') IS NOT NULL
        DROP TABLE dimStation
END    
GO;

--create Station table structure based on project analytics specifications
CREATE TABLE dimStation (
    StationId varchar(50) NOT NULL,
    StationName varchar(75),
    Latitude float,
    Longitude float
)
GO;

--add primary key constraint
ALTER TABLE dimStation
ADD CONSTRAINT PK_dimStation_StationId PRIMARY KEY NONCLUSTERED (StationId) NOT ENFORCED
GO;

--populate Station table
INSERT INTO dimStation
SELECT 
    try_convert(varchar(50), StationId),
    try_convert(varchar(75), StationName),
    Latitude,
    Longitude
FROM staging_station
GO;

SELECT TOP 100 *
FROM dimStation
GO;