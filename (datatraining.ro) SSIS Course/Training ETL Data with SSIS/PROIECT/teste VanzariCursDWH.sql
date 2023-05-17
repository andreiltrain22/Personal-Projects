create database VanzariCursDWH
GO
Use VanzariCursDWH;
GO

create table DimDate
(DateKey           INT         NOT NULL PRIMARY KEY,
  [Date]              DATE        NOT NULL,
  [Day]               TINYINT     NOT NULL,
  DaySuffix           CHAR(2)     NOT NULL,
  [Weekday]           TINYINT     NOT NULL,
  WeekDayName         VARCHAR(10) NOT NULL,
  IsWeekend           BIT         NOT NULL,
  IsHoliday           BIT         NOT NULL,
  HolidayText         VARCHAR(64) SPARSE,
  DOWInMonth          TINYINT     NOT NULL,
  [DayOfYear]         SMALLINT    NOT NULL,
  WeekOfMonth         TINYINT     NOT NULL,
  WeekOfYear          TINYINT     NOT NULL,
  ISOWeekOfYear       TINYINT     NOT NULL,
  [Month]             TINYINT     NOT NULL,
  [MonthName]         VARCHAR(10) NOT NULL,
  [Quarter]           TINYINT     NOT NULL,
  QuarterName         VARCHAR(6)  NOT NULL,
  [Year]              INT         NOT NULL,
  MMYYYY              CHAR(6)     NOT NULL,
  MonthYear           CHAR(7)     NOT NULL,
  FirstDayOfMonth     DATE        NOT NULL,
  LastDayOfMonth      DATE        NOT NULL,
  FirstDayOfQuarter   DATE        NOT NULL,
  LastDayOfQuarter    DATE        NOT NULL,
  FirstDayOfYear      DATE        NOT NULL,
  LastDayOfYear       DATE        NOT NULL,
  FirstDayOfNextMonth DATE        NOT NULL,
  FirstDayOfNextYear  DATE        NOT NULL
);
GO

DECLARE @StartDate DATE = '20000101', @NumberOfYears INT = 30;

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals

SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

-- this is just a holding table for intermediate calculations:

CREATE TABLE #dim
(
  [date]       DATE PRIMARY KEY, 
  [day]        AS DATEPART(DAY,      [date]),
  [month]      AS DATEPART(MONTH,    [date]),
  FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
  [MonthName]  AS DATENAME(MONTH,    [date]),
  [week]       AS DATEPART(WEEK,     [date]),
  [ISOweek]    AS DATEPART(ISO_WEEK, [date]),
  [DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
  [quarter]    AS DATEPART(QUARTER,  [date]),
  [year]       AS DATEPART(YEAR,     [date]),
  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
  Style112     AS CONVERT(CHAR(8),   [date], 112),
  Style101     AS CONVERT(CHAR(10),  [date], 101)
);

-- use the catalog views to generate as many rows as we need

INSERT #dim([date]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    -- on my system this would support > 5 million days
    ORDER BY s1.[object_id]
  ) AS x
) AS y;

select year([date])*10000+month([date])*100+day([date]) from #dim


INSERT dbo.DimDate WITH (TABLOCKX)
SELECT
  DateKey     = year([date])*10000+month([date])*100+day([date]),
  [Date]        = [date],
  [Day]         = CONVERT(TINYINT, [day]),
  DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
                  CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
	              WHEN '3' THEN 'rd' ELSE 'th' END END),
  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
  [IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
  [IsHoliday]   = CONVERT(BIT, 0),
  HolidayText   = CONVERT(VARCHAR(64), NULL),
  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
                  (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
                  (PARTITION BY [year], [month] ORDER BY [week])),
  WeekOfYear    = CONVERT(TINYINT, [week]),
  ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
  [Month]       = CONVERT(TINYINT, [month]),
  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
  [Quarter]     = CONVERT(TINYINT, [quarter]),
  QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                  WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
  [Year]        = [year],
  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
  MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
  FirstDayOfMonth     = FirstOfMonth,
  LastDayOfMonth      = MAX([date]) OVER (PARTITION BY [year], [month]),
  FirstDayOfQuarter   = MIN([date]) OVER (PARTITION BY [year], [quarter]),
  LastDayOfQuarter    = MAX([date]) OVER (PARTITION BY [year], [quarter]),
  FirstDayOfYear      = FirstOfYear,
  LastDayOfYear       = MAX([date]) OVER (PARTITION BY [year]),
  FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
  FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
FROM #dim
OPTION (MAXDOP 1);

select * from DimDate

drop table FactFacturi;
drop table DimProduse;
drop table DimFurnizori;
drop table DimClienti;

create table DimFurnizori
(
idfurnizor int,
FurnizorKey int not null identity(1,1) primary key,
DenumireFurnizor nvarchar(255),
Locatie nvarchar(255)
)

create table DimClienti
(
idclient int not null,
ClientKey int not null identity(1,1) primary key,
DenumireClient nvarchar(255),
Locatie nvarchar(255)
)


create table DimProduse
(idprodus int not null,
ProdusKey int not null identity(1,1) primary key,
DenumireProdus nvarchar(255),
stoc decimal(18,0),
perioadaexprirare int,
DenumireCategorie nvarchar(255)
)


create table FactFacturi
(idfactura int not null,
ProdusKey int not null,
ClientKey int not null,
FurnizorKey int not null,
DateKey int not null,
Cantitate decimal(18,0),
Pret decimal(18,0),
Valoare as cantitate*pret)

insert into DimFurnizori (idfurnizor, DenumireFurnizor, Locatie)
select
	idfurnizor,
	denumire,
	locatie
from VanzariCurs.dbo.Furnizori

select * from DimFurnizori

insert into DimClienti (idclient, DenumireClient, Locatie)
select
	idclient,
	nume,
	locatie
from VanzariCurs.dbo.Clienti


insert into DimProduse (idprodus,DenumireProdus,stoc,perioadaexprirare, DenumireCategorie)
select
	p.idprodus,
	p.denumire as DenumireProdus,
	p.stoc,
	p.perioadaexpirare,
	cp.denumire as denumirecategorie
from VanzariCurs.dbo.Produse as p
inner join VanzariCurs.dbo.Categ_Produse as cp on p.categorieprodus=cp.idcategorie


insert into FactFacturi (idfactura, ProdusKey, ClientKey, FurnizorKey, DateKey, Cantitate, pret)
select
	f.idfactura,
	dp.ProdusKey,
	dc.ClientKey,
	df.FurnizorKey,
	dd.DateKey,
	f.cantitate,
	f.pret
from VanzariCurs.dbo.Facturi as f
inner join VanzariCursDWH.dbo.DimClienti as dc on f.idclient=dc.idclient
inner join VanzariCursDWH.dbo.DimProduse as dp on f.idprodus=dp.idprodus
inner join VanzariCurs.dbo.Produse as p on p.idprodus=dp.idprodus
inner join VanzariCursDWH.dbo.DimFurnizori as df on df.idfurnizor=p.idfurnizor
inner join VanzariCursDWH.dbo.DimDate as dd on dd.[Date]=f.datafactura