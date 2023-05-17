--drop calendar table if it exists
BEGIN   
    IF OBJECT_ID('dbo.dimDate') IS NOT NULL
        DROP TABLE dimDate
END    
GO;

--create calendar table structure based on project analytics specifications
CREATE TABLE dimDate (
    [DateId] int NOT NULL,
    [Date] date NOT NULL,
    [MonthId] tinyint NOT NULL,
    [MonthName] varchar(10) NOT NULL,
    [Year] smallint NOT NULL,
    [Quarter] tinyint NOT NULL,
    [DayOfWeek] char(3) NOT NULL
)
GO;

--add primary key constraint
ALTER TABLE dimDate
ADD CONSTRAINT PK_dimDate_DateId PRIMARY KEY NONCLUSTERED (DateId) NOT ENFORCED
GO;

-- create a temporary table for the dates we need
CREATE TABLE #TmpStageDate (DateVal DATE NOT NULL) 

--create dynamic start date variable to reference the minimum payment date 
DECLARE @StartDate date = (
                            select min(
                                        try_convert(date, 
                                                    left([Date], 10)
                                                    )
                                        )
                            from staging_payment
                            )

--create dynamic end date variable and set it to 10 years in the future from maximum payment date
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 10, (select max(
                                                                            try_convert(date, 
                                                                                        left([Date], 10)
                                                                                        )   
                                                                        )
                                                                from staging_payment
                                                                )
                                                    )
                                )

--declare and set a variable to iterate over range of dates (StartDate through CutoffDate)
DECLARE @LoopDate DATE = @StartDate
--start iterating
WHILE   @LoopDate     <= @CutoffDate
BEGIN
    INSERT INTO #TmpStageDate VALUES
    (
        @LoopDate  --insert date values into temp table as long as they are in the requested date range.
    ) 
    SET @LoopDate = DATEADD(dd, 1, @LoopDate) --at the end of each iteration increment date by 1 day.
END
GO;

INSERT INTO dimDate 
SELECT  CAST(
            CONVERT(VARCHAR(8), 
                    DateVal, 
                    112
                    ) AS int
            ) , -- date key
        DateVal, -- date alt key
        DATEPART(MONTH,   DateVal), -- month number of year
        DATENAME(MONTH,   DateVal), -- month name
        DATEPART(YEAR,    DateVal),  --calendar year
        DATEPART(Quarter, DateVal), -- calendar quarter
        FORMAT(DateVal, 'ddd')  --day of week
FROM #TmpStageDate
GO;

SELECT TOP 1000 * 
FROM dimDate
GO;