--drop Trip table if it exists
BEGIN   
    IF OBJECT_ID('dbo.factTrip') IS NOT NULL
        DROP TABLE factTrip
END    
GO;

--create Trip table structure based on project analytics specifications
CREATE TABLE factTrip (
    TripId varchar(50) NOT NULL,
    StartStationId varchar(50) NOT NULL,
    EndStationId varchar(50) NOT NULL,
    StartDateId int NOT NULL,
    EndDateId int NOT NULL,
    RiderId int NOT NULL,
    RideableType varchar(75),
    TripDurationMinutes int,
    HourOfDay tinyint,
    RiderAgeAtTripTime tinyint
)
GO;

--add primary key constraint
ALTER TABLE factTrip
ADD CONSTRAINT PK_factTrip_TripId PRIMARY KEY NONCLUSTERED (TripId) NOT ENFORCED
GO;

--populate Trip table
INSERT INTO factTrip
SELECT 
    try_convert(varchar(50), t.TripId),                                                          --convert from nvarchar(4000) to varchar(50)
    try_convert(varchar(50), t.StartStationId),                                                  --convert from nvarchar(4000) to varchar(50)
    try_convert(varchar(50), t.EndStationId),                                                    --convert from nvarchar(4000) to varchar(50)                                                    
    try_convert(int, replace(left(t.StartTime, 10), '-', '')),                                   --convert from text to int
    try_convert(int, replace(left(t.EndTime, 10), '-', '')),                                     --convert from text to int
    try_convert(int, t.RiderId),                                                                 --convert from bigint to int
    try_convert(varchar(75), t.RideableType),                                                    --convert from nvarchar(4000) to varchar(75)
    datediff(minute, 
                try_convert(datetime2, t.StartTime), 
                try_convert(datetime2, t.EndTime)
            ),                                                                                   --calculate time delta (in number of minutes) between trip start and trip end
    try_convert(tinyint, 
                datepart(hour, 
                         try_convert(datetime2, t.StartTime)
                         )
                ),                                                                               --extract hour of day from Start Time and convert to int
    datediff(year, 
             r.Birthdate, 
             try_convert(date, 
                        left(t.StartTime, 10)
                        )
            ) as RiderAgeAtTripTime                                                              --compute timedelta (in years) between rider birth date and trip date             
FROM staging_Trip t
    INNER JOIN dimDate d1 ON try_convert(int, replace(left(t.StartTime, 10), '-', '')) = d1.DateId --enforce referential integrity
    INNER JOIN dimDate d2 ON try_convert(int, replace(left(t.EndTime, 10), '-', '')) = d2.DateId   --enforce referential integrity
    INNER JOIN dimRider r ON t.RiderId = r.RiderId                                               --enforce referential integrity
    INNER JOIN dimStation s1 ON t.StartStationId = s1.StationId                                  --enforce referential integrity
    INNER JOIN dimStation s2 ON t.EndStationId = s2.StationId                                  --enforce referential integrity
GO;

SELECT TOP 100 *
FROM factTrip
GO;