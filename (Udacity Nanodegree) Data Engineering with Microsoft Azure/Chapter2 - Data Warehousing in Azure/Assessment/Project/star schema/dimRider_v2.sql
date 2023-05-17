--drop Rider table if it exists
BEGIN   
    IF OBJECT_ID('dbo.dimRider') IS NOT NULL
        DROP TABLE dimRider
END    
GO;

--create Rider table structure based on project analytics specifications
CREATE TABLE dimRider (
    RiderId int NOT NULL,
    FirstName varchar(50),
    LastName varchar(50),
    Address varchar(100),
    Birthdate date,
    IsMember bit NOT NULL,
    AccountStartDate date,
    AccountEndDate date,
    RiderAgeAtAccStart tinyint
)
GO;

--add primary key constraint
ALTER TABLE dimRider
ADD CONSTRAINT PK_dimRider_RiderId PRIMARY KEY NONCLUSTERED (RiderId) NOT ENFORCED
GO;

--populate Rider table
INSERT INTO dimRider
SELECT 
    try_convert(int, RiderId),                      --convert from bigint in stg table to int
    try_convert(varchar(50), FirstName),            --convert from nvarchar(4000) to varchar(50)
    try_convert(varchar(50), LastName),             --convert from nvarchar(4000) to varchar(50)  
    try_convert(varchar(100), Address),             --convert from nvarchar(4000) to varchar(100)
    try_convert(date, left(Birthdate, 10)),         --convert from text to date
    IsMember,
    try_convert(date, left(AccountStartDate, 10)),  --convert to date format
    try_convert(date, left(AccountEndDate, 10)),    --convert to date format
    datediff(year, 
            try_convert(date, left(Birthdate, 10)),
            try_convert(date, left(AccountStartDate, 10))
            )                                       --compute time delta (in years) between rider birth date and rider membership start date
FROM staging_rider
GO;

SELECT TOP 100 *
FROM dimRider
GO;
