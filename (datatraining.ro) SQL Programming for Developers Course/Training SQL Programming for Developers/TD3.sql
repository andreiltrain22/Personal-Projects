--Tema Functii
/*
Sa se construiasca o functie care va returna suma totala a incasarilor 
pentru o perioada de timp definita de utilizator prin start_date si end_date
*/

use Training
go

create function udf_SumaIncasari(@startdate date, @enddate date) 
returns decimal(18, 2)
as

begin

	return (
			select sum(od.qty * od.unitprice) 
			from sales.OrderDetails od
			inner join sales.Orders o on o.orderid = od.orderid  
			where o.orderdate between @startdate and @enddate
			)
end
GO

select dbo.udf_SumaIncasari('2006-10-01', '2006-12-31') as Sales

select min(orderdate), max(orderdate)
from sales.Orders

/*
Sa se defineasca o functie care va determina pentru un anumit client : 
-suma cantitatilor
-suma incasarilor 
pentru o anumita perioada de timp definita de utilizator prin start_date si end_date.
*/

create function udf_SalesQty(@custid int, @startdate date, @enddate date)
returns table
as

return 
(
select sum(od.qty) as Qty, sum(od.qty * od.unitprice) as Sales
from sales.OrderDetails od
inner join sales.Orders o on o.orderid = od.orderid
where o.custid = @custid
and o.orderdate between @startdate and @enddate
)
GO

select * from dbo.udf_SalesQty(37, '2006-10-01', '2006-12-31')

/*Sa se defineasca o functie care va determina la nivel de o anumita tara, definita de utilizator:
-numarul de clienti distincti, 
-numarul de comenzi, 
-suma incasarilor 
pe o anumita perioada definita de utilizator prin start_date si end_date.
*/

create function udf_ClientsOrdersSales(@country varchar(30), @startdate date, @enddate date)
returns table
as

return

(
select count(distinct c.custid) as Clients, count(distinct o.orderid) as Orders, sum(od.qty * od.unitprice) as Sales
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where c.country = @country
and o.orderdate between @startdate and @enddate 
)
GO

select * from udf_ClientsOrdersSales('Argentina', '2007-10-01', '2007-12-31')

select min(orderdate), max(orderdate)
from sales.Orders o
inner join sales.Customers c on c.custid = o.custid
where c.country = 'Argentina'

/*
Sa se creeze o functie care va determina la nivel de oras: 
-numarul de clienti distincti, 
-numarul de facturi si 
-suma cantitatilor 
pe o anumita perioada definita de utilizator prin start_date si end_date.
*/

create function udf_ClientsOrdersQtybyCity(@startdate date, @enddate date)
returns @ClientsOrdersQtyByCity table
(
city varchar(50),
clients int,
orders int,
sales decimal(18, 2)
)
as

begin

insert into @ClientsOrdersQtyByCity(city, clients, orders, sales)
select c.city, count(distinct c.custid) as Clients, count(distinct o.orderid) as Orders, sum(od.qty) as Qty
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by c.city

return

end
GO

select * from dbo.udf_ClientsOrdersQtyByCity('2006-06-01', '2006-12-31') 
order by city

/*
Sa se construiasca o functie care va determina pentru fiecare firma de livrare:
-numarul de clienti distincti si 
-cantitatile totale livrate 
pe o anumita perioada definite de utilizator prin start_date si end_date.
*/

create function udf_ClientsQtyByShipper(@startdate date, @enddate date)
returns @ClientsQtyByShipper table
(
shippername varchar(50),
clients int,
qty int
)

as

begin

insert into @ClientsQtyByShipper (shippername, clients, qty)
select s.companyname as shipper, count(distinct o.custid) as Clients, sum(qty) as Qty 
from sales.Shippers s
inner join sales.Orders o on o.shipperid = s.shipperid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by s.companyname

return

end
GO

select * from dbo.udf_ClientsQtyByShipper('2006-06-01', '2006-12-31')
order by qty desc

select shipname from sales.orders order by shipname
select companyname from sales.Shippers order by companyname
select top 10 qty from sales.OrderDetails

/*
PROIECT PROCEDURI & FUNCTII:
Cerinta de business:
Se doreste un raport la nivel de cu vanzarea la nivel de tara client astfel:
- O coloana country
- O coloana cu vanzarile pe primul semestru dintr-un an denumita Sales Previous Sem
- O coloana cu vanzarile pe al doilea semestru dintr-un an denumita Sales Current Sem
Business-ul doreste stocarea informatiilor intr-o tabela permanenta.
In plus, de fiecare data cand este rulat raportul se va goli mai intai tabela pentru a se insera noile date.
*/

--Pas1: creare tabel
create table Sales.Report_Sem
(
[Country] nvarchar(100),
[Sales_First_Sem] decimal(19,4),
[Sales_Second_Sem] decimal(19,4)
)

--Pas2: pregatire select de populare tabel, pt. anul 2007
select c.country 
, sum(case when o.orderdate >= '2007-01-01' and o.orderdate <= '2007-06-30' then od.qty * od.unitprice else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > '2007-06-30' and o.orderdate <= '2007-12-31' then od.qty * od.unitprice else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between '2007-01-01' and '2007-12-31'
group by c.country

--Pas3: inserare date in tabel Report_SEM pt prima data
insert into sales.Report_Sem (country, [Sales_First_Sem], [Sales_Second_Sem])
select c.country 
, sum(case when o.orderdate >= '2007-01-01' and o.orderdate <= '2007-06-30' then od.qty * od.unitprice else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > '2007-06-30' and o.orderdate <= '2007-12-31' then od.qty * od.unitprice else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between '2007-01-01' and '2007-12-31'
group by c.country

select * from sales.Report_Sem

--Pas4: parametrizare select
declare @startdate date,
		@middate date, 
		@enddate date

set @startdate = '2007-01-01'
set @middate = EOMONTH(@startdate, 5)
set @enddate = EOMONTH(@startdate, 11)

truncate table sales.Report_Sem

insert into sales.Report_Sem (country, [Sales_First_Sem], [Sales_Second_Sem])
select c.country 
, sum(case when o.orderdate >= @startdate and o.orderdate <= @middate then od.qty * od.unitprice else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > @middate and o.orderdate <= @enddate then od.qty * od.unitprice else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by c.country

--Pas5: Transformare script in procedura stocata

create procedure sp_ReportSEM(@startdate date)
as

begin

set nocount on

declare --@startdate date,
		@middate date, 
		@enddate date

--set @startdate = '2007-01-01'
set @middate = EOMONTH(@startdate, 5)
set @enddate = EOMONTH(@startdate, 11)

truncate table sales.Report_Sem

insert into sales.Report_Sem (country, [Sales_First_Sem], [Sales_Second_Sem])
select c.country 
, sum(case when o.orderdate >= @startdate and o.orderdate <= @middate then od.qty * od.unitprice else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > @middate and o.orderdate <= @enddate then od.qty * od.unitprice else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by c.country

end

--Pas6: Functie scalara care sa returneze vanzarile

create function udf_SalesReportSEM(@qty int, @price decimal(19, 4))
returns decimal(19, 4)
as

begin

return
(@qty * @price)

end

--Pas7: Modificare procedura stocata, pt a apela functia creata la pasul 6
alter procedure sp_ReportSEM(@startdate date)
as

begin

set nocount on

declare --@startdate date,
		@middate date, 
		@enddate date

--set @startdate = '2007-01-01'
set @middate = EOMONTH(@startdate, 5)
set @enddate = EOMONTH(@startdate, 11)

truncate table sales.Report_Sem

insert into sales.Report_Sem (country, [Sales_First_Sem], [Sales_Second_Sem])
select c.country 
, sum(case when o.orderdate >= @startdate and o.orderdate <= @middate then dbo.udf_SalesReportSEM(od.qty, od.unitprice) else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > @middate and o.orderdate <= @enddate then dbo.udf_SalesReportSEM(od.qty, od.unitprice) else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by c.country

end

--Pas8: executie procedura pt o anumita data
exec sp_ReportSEM '2007-01-01'
go

select * from sales.Report_Sem

--Pas9: Testare Raport
declare @startdate date,
		@middate date, 
		@enddate date

set @startdate = '2007-01-01'
set @middate = EOMONTH(@startdate, 5)
set @enddate = EOMONTH(@startdate, 11)

select c.country 
, sum(case when o.orderdate >= @startdate and o.orderdate <= @middate then dbo.udf_SalesReportSEM(od.qty, od.unitprice) else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > @middate and o.orderdate <= @enddate then dbo.udf_SalesReportSEM(od.qty, od.unitprice) else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
and country in ('Norway', 'Poland', 'Portugal')
group by c.country

--Pas9: Creare pachet deploy

use Training
GO

if object_id('Sales.Report_Sem', 'u') is not null
	drop table Sales.Report_Sem
GO

create table Sales.Report_Sem
(
[Country] nvarchar(100),
[Sales_First_Sem] decimal(19,4),
[Sales_Second_Sem] decimal(19,4)
)
GO

if object_id('Sales.udf_SalesReportSEM', 'fn') is not null
	drop function Sales.udf_SalesReportSEM
GO

create function Sales.udf_SalesReportSEM(@qty int, @price decimal(19, 4))
returns decimal(19, 4)
as

begin

return
(@qty * @price)

end
GO

if object_id('sp_ReportSEM', 'p') is not null
	drop procedure sp_ReportSEM
GO

create procedure sp_ReportSEM(@startdate date)
as

begin

set nocount on

declare @middate date, 
		@enddate date

set @middate = EOMONTH(@startdate, 5)
set @enddate = EOMONTH(@startdate, 11)

truncate table sales.Report_Sem

insert into sales.Report_Sem (country, [Sales_First_Sem], [Sales_Second_Sem])
select c.country 
, sum(case when o.orderdate >= @startdate and o.orderdate <= @middate then dbo.udf_SalesReportSEM(od.qty, od.unitprice) else 0 end) as Sales_First_Sem
, sum(case when o.orderdate > @middate and o.orderdate <= @enddate then dbo.udf_SalesReportSEM(od.qty, od.unitprice) else 0 end) as Sales_Second_Sem
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by c.country

end

/*
Blocuri de control cod: if/else, while
*/

/*
Sa se creeze o procedura stocata (sp_ReportCustomersYesterday) care va extrage la nivel de fiecare client:
o Numarul de comenzi plasate ieri
o Valoarea incasarilor pentru comenzile plasate ieri
- Daca numarul de clienti care au plasat comenzi ieri este diferit de NULL (adica sunt clienti care au plasat comenzi) 
atunci sa se execute procedura sp_ReportCustomersYesterday.
*/



alter procedure sp_ReportCustomersYesterday(@reportdate date)
as

begin

select c.companyname as Company, count(distinct o.orderid) Orders, sum(od.qty * od.unitprice) as Sales
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate = dateadd(dd, -1, cast(@reportdate as date))
group by c.companyname

end
GO

if (
	select count(custid) 
	from sales.Orders 
	where orderdate = '2007-10-09'
	) > 0

	exec sp_ReportCustomersYesterday '2007-10-10'
else print 'No Orders Yesterday'

/*
WHILE
Se presupune ca business-ul a solicitat un raport lunar cu incasarile la nivel de tara client. 
Raportul este nou si se doreste a fi extras si din urma, pentru 2007.
Raportul va fi incarcat intr-o tabela din baza de date pentru fiecare luna incheiata.
Tabela are 3 coloane: country, month_id, sales.
- Se va creea o procedura stocata cu incasarile per luna (luna data de utilizator ca parametru, de tipul yyyymm)
- Procedura stocata va fi rulata pornind din ianuarie 2007 pana in decembrie 2007 utilizand control flow-ul while.
*/

if object_id('sales.SalesByCountry', 'u') is not null
	drop table sales.SalesByCountry
GO

create table sales.SalesByCountry
(
country varchar(20), 
monthid int, --yyyymm
sales money
)
GO

if object_id('sp_monthlysales', 'p') is not null
	drop procedure sp_monthlysales
GO

create procedure sp_monthlysales(@reporting_month int)
as

begin

	insert into Sales.SalesByCountry (country, monthid, sales)
	select c.country, @reporting_month as monthid, sum(od.qty * od.unitprice) as Sales
	from sales.Customers c
	inner join sales.Orders o on o.custid = c.custid
	inner join sales.OrderDetails od on od.orderid = o.orderid
	where year(o.orderdate) * 100 + month(o.orderdate) = @reporting_month
	group by c.country

end
GO

declare @reporting_month_start int,
		@reporting_month_end int

set @reporting_month_start = 200701
set @reporting_month_end = 200712

while @reporting_month_start <= @reporting_month_end

begin

	exec sp_monthlysales @reporting_month_start
	set @reporting_month_start = @reporting_month_start + 1

end
GO

select * from Sales.SalesByCountry
order by monthid

/*
WHILE IMBRICAT
Se presupune ca business-ul a solicitat un raport lunar cu incasarile la nivel de tara client. 
Raportul este nou si se doreste a fi extras si din urma, pentru 2007 si 2008.
Raportul va fi incarcat intr-o tabela din baza de date pentru fiecare luna incheiata.
- Se va creea o procedura stocata cu incasarile per luna (luna data de utilizator ca parametru)
- Procedura stocata va fi rulata pornind din ianuarie 2007 pana in decembrie 2008 utilizand control flow-ul while.
*/

truncate table sales.SalesByCountry

declare @reporting_year_start smallint, 
		@reporting_year_end smallint, 
		@reporting_month_start smallint, 
		@reporting_month_end smallint

set @reporting_year_start = 2007
set @reporting_year_end = 2008
set @reporting_month_start = 1
set @reporting_month_end = 12

while @reporting_year_start <= @reporting_year_end

begin

	while @reporting_month_start <= @reporting_month_end

	begin

		declare @reporting_month int --yyyymm
		set @reporting_month = @reporting_year_start * 100 + @reporting_month_start

		exec sp_monthlysales @reporting_month
		set @reporting_month_start = @reporting_month_start + 1

	end

	set @reporting_year_start = @reporting_year_start + 1
	set @reporting_month_start = 1

end
GO

select * from sales.SalesByCountry 
order by monthid

/*
--Merge Statement:

MERGE INTO target as t
USING source as s ON s.primary_key = t.primary_key
WHEN MATCHED (AND conditii)
	THEN UPDATE/DELETE
WHEN NOT MATCHED BY TARGET (AND conditii)
	THEN INSERT 
WHEN NOT MATCHED BY SOURCE (AND conditii)
	THEN UPDATE/DELETE


-source = tabel fizic/temporar , CTE sau select
*/

/*
Se considera tabela Sales.Orders careia: 
-i se face o copie cu numele Sales.OrdersTGT fara a avea date si 
-inca o copie cu numele Sales.OrdersSRC cu date. 
In fiecare zi, in tabela Sales.OrdersSRC se intampla modificari:
- Randuri noi cu comenzi noi
- Modificate comenzile anterioare
- Sterse comenzi
Tabela Sales.OrdersTGT trebuie mentinuta in mod identic cu tabela Sales.OrdersSRC.
*/

--Pas1: creare tabele sursa + destinatie
select orderid, empid, freight, shippeddate
into Sales.OrdersTGT
from Sales.Orders
where 1 = 2

alter table Sales.OrdersTGT add constraint pk_orderstgt PRIMARY KEY (orderid)

select top 10 orderid, empid, freight, shippeddate
into Sales.OrdersSRC
from Sales.Orders
GO

alter table Sales.OrdersSRC add constraint pk_ordersrc PRIMARY KEY (orderid)

--Pas2: Merge Statement

SET IDENTITY_INSERT sales.orderstgt ON

MERGE INTO Sales.OrdersTGT as t
USING Sales.OrdersSRC as s on t.orderid = s.orderid
WHEN MATCHED AND 
				(
				t.empid <> s.empid 
				 OR t.freight <> s.freight 
				 OR t.shippeddate <> s.shippeddate
				 )
	THEN UPDATE 
				SET t.empid = s.empid, 
					t.freight = s.freight, 
					t.shippeddate = s.shippeddate
WHEN NOT MATCHED BY TARGET
		THEN INSERT (orderid, empid, freight, shippeddate)
		VALUES (s.orderid, s.empid, s.freight, s.shippeddate) 
WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

SET IDENTITY_INSERT sales.orderstgt OFF

select * from sales.OrdersSRC
select * from sales.OrdersTGT

--Insert into source
SET IDENTITY_INSERT sales.OrdersSRC ON

insert into sales.OrdersSRC(orderid, empid, freight, shippeddate)
values (1000, 5, 100, '2020-10-10')

SET IDENTITY_INSERT sales.OrdersSRC OFF

SET IDENTITY_INSERT sales.orderstgt ON

MERGE INTO Sales.OrdersTGT as t
USING Sales.OrdersSRC as s on t.orderid = s.orderid
WHEN MATCHED AND 
				(
				t.empid <> s.empid 
				 OR t.freight <> s.freight 
				 OR t.shippeddate <> s.shippeddate
				 )
	THEN UPDATE 
				SET t.empid = s.empid, 
					t.freight = s.freight, 
					t.shippeddate = s.shippeddate
WHEN NOT MATCHED BY TARGET
		THEN INSERT (orderid, empid, freight, shippeddate)
		VALUES (s.orderid, s.empid, s.freight, s.shippeddate) 
WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

SET IDENTITY_INSERT sales.orderstgt OFF

--Modify source
update sales.OrdersSRC
set empid = 6
where orderid = 1000

SET IDENTITY_INSERT sales.orderstgt ON

MERGE INTO Sales.OrdersTGT as t
USING Sales.OrdersSRC as s on t.orderid = s.orderid
WHEN MATCHED AND 
				(
				 t.empid <> s.empid 
				 OR t.freight <> s.freight 
				 OR t.shippeddate <> s.shippeddate
				 )
	THEN UPDATE 
				SET t.empid = s.empid, 
					t.freight = s.freight, 
					t.shippeddate = s.shippeddate
WHEN NOT MATCHED BY TARGET
		THEN INSERT (orderid, empid, freight, shippeddate)
		VALUES (s.orderid, s.empid, s.freight, s.shippeddate) 
WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

SET IDENTITY_INSERT sales.orderstgt OFF

select * from sales.orderstgt

--Delete from source
delete from sales.OrdersSRC where orderid = 1000

SET IDENTITY_INSERT sales.orderstgt ON

MERGE INTO Sales.OrdersTGT as t
USING Sales.OrdersSRC as s on t.orderid = s.orderid
WHEN MATCHED AND 
				(
				 t.empid <> s.empid 
				 OR t.freight <> s.freight 
				 OR t.shippeddate <> s.shippeddate
				 )
	THEN UPDATE 
				SET t.empid = s.empid, 
					t.freight = s.freight, 
					t.shippeddate = s.shippeddate
WHEN NOT MATCHED BY TARGET
		THEN INSERT (orderid, empid, freight, shippeddate)
		VALUES (s.orderid, s.empid, s.freight, s.shippeddate) 
WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

SET IDENTITY_INSERT sales.orderstgt OFF
GO


--Incapsulare Merge in procedura stocata

create procedure sp_mergeorders
as

begin

SET IDENTITY_INSERT sales.orderstgt ON

MERGE INTO Sales.OrdersTGT as t
USING Sales.OrdersSRC as s on t.orderid = s.orderid
WHEN MATCHED AND 
				(
				 t.empid <> s.empid 
				 OR t.freight <> s.freight 
				 OR t.shippeddate <> s.shippeddate
				 )
	THEN UPDATE 
				SET t.empid = s.empid, 
					t.freight = s.freight, 
					t.shippeddate = s.shippeddate
WHEN NOT MATCHED BY TARGET
		THEN INSERT (orderid, empid, freight, shippeddate)
		VALUES (s.orderid, s.empid, s.freight, s.shippeddate) 
WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

SET IDENTITY_INSERT sales.orderstgt OFF

end
GO

truncate table sales.orderstgt
exec dbo.sp_mergeorders