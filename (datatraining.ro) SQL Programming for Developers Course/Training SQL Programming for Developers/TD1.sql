--1. Det. nr de clienti din fiecare tara

select country as TaraClient, count(distinct custid) as NrClienti
from [Sales].[Customers]
group by country
order by country

--2. Det. nr de comenzi livrate si suma costului de transport la nivel de tara client

select country as TaraClient, count(distinct orderid) as NrComenziLivrate, sum(freight) as CostTransport
from sales.Customers a
inner join sales.Orders b on b.custid = a.custid
where shippeddate is not null
group by country
order by NrComenziLivrate desc, CostTransport desc

/*
3. Raport la nivel de tara client: 
-nr. de clienti unici
-nr. de comenzi unice livrate
-suma incasarilor
*/

select a.country as TaraClient, 
	   count(distinct a.custid) as NrClienti,
	   count(distinct b.orderid) as NrComenziLivrate, 
	   sum(c.qty * c.unitprice) as SumaIncasari
from sales.Customers a
inner join sales.Orders b on b.custid = a.custid
inner join sales.OrderDetails c on c.orderid = b.orderid
where shippeddate is not null
group by country
order by SumaIncasari desc

/*
Afisati doar tarile unde suma incasarilor > 5000 si nr de clienti unici > 3
Luati in considerare doar comenzile livrate in anii 2007 si 2008
*/

select a.country as TaraClient, 
	   count(distinct a.custid) as NrClienti,
	   count(distinct b.orderid) as NrComenziLivrate, 
	   sum(c.qty * c.unitprice) as SumaIncasari
from sales.Customers a
inner join sales.Orders b on b.custid = a.custid
inner join sales.OrderDetails c on c.orderid = b.orderid
where year(shippeddate) in (2007, 2008)
group by country
having sum(c.qty * c.unitprice) > 5000 
and count(distinct a.custid) > 3

/*
5. Definiti un view cu select-ul de mai sus
*/

CREATE VIEW VwRaportTari 
--with schemabinding
AS

select a.country as TaraClient, 
	   count(distinct a.custid) as NrClienti,
	   count(distinct b.orderid) as NrComenziLivrate, 
	   sum(c.qty * c.unitprice) as SumaIncasari
from sales.Customers a
inner join sales.Orders b on b.custid = a.custid
inner join sales.OrderDetails c on c.orderid = b.orderid
where year(shippeddate) in (2007, 2008)
group by country
having sum(c.qty * c.unitprice) > 5000 
and count(distinct a.custid) > 3

select * from [dbo].[VwRaportTari]

-----Proceduri stocate
--Obiecte care incapsuleaza cod SQL.

--1. Sa se afiseze nr de comezi ale clientului 37, din anul 2007

select c.custid, c.companyname, count(orderid)
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where o.orderdate between '2007-01-01' and '2007-12-31'
and c.custid = 37
group by c.custid, c.companyname

if exists (select object_id from sys.all_objects where name = 'sp_GetOrders') --is not null
drop procedure sp_GetOrders
GO

create procedure sp_GetOrders (@idclient int, @startdate date, @enddate date)
as

--begin

select c.custid, c.companyname, count(orderid) as NumOrders
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where o.orderdate between @startdate and @enddate
and c.custid = @idclient
group by c.custid, c.companyname

--end

exec sp_GetOrders 37, '2007-01-01', '2007-12-31'

select * from sys.all_objects a
where a.type = 'P'
order by create_date desc

if OBJECT_ID('sp_GetOrders', 'P') is not null
drop procedure sp_GetOrders
GO

create procedure sp_GetOrders (@idclient int, @startdate date, @enddate date)
as

--begin

select c.custid, c.companyname, count(orderid) as NumOrders
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where o.orderdate between @startdate and @enddate
and c.custid = @idclient
group by c.custid, c.companyname

--end

if object_id('sp_GetOrders', 'P') is not null
drop procedure sp_GetOrders
GO

create procedure sp_GetOrders (@idclient int, @startdate date, @enddate date)
as

SET NOCOUNT ON

select c.custid, c.companyname, o.orderid, o.orderdate
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where o.orderdate between @startdate and @enddate
and c.custid = @idclient

exec sp_GetOrders @idclient = 37, @startdate = '2007-01-01', @enddate = '2007-12-31'
GO

alter procedure sp_GetOrders (@idclient int, @startdate date, @enddate date)
as

SET NOCOUNT ON

select c.custid, c.companyname, o.orderid, o.orderdate, o.freight
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where o.orderdate between @startdate and @enddate
and c.custid = @idclient
GO

exec sp_GetOrders @idclient = 37, @startdate = '2007-01-01', @enddate = '2007-12-31'

/*
Procedura stocata -> raport la nivel tara client: nr comenzi unice, suma cantitatilor vandute, suma incasari
*/

alter procedure sp_CountryReport as

SET NOCOUNT ON

select c.country, count(distinct o.orderid) as numorders, sum(od.qty) as qty, sum(od.qty * od.unitprice) as TotalAmt
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
group by c.country
order by totalamt desc
GO

exec sp_CountryReport

--Parametrii optionali

/*
Procedura stocata pt a det. lista de comenzi plasate pt un anumit client.
In cazul in care se omite perioada (se doreste afisarea tuturor comenzilor clientului), nu va mai fi obligatorie introducerea parametrilor de data.
*/

if object_id('sp_GetOrders', 'P') is not null
drop procedure sp_GetOrders
GO

create procedure sp_GetOrders (@idclient int, @startdate date = '1900-01-01', @enddate date = '2999-12-31')
as

select c.companyname, o.orderid, o.orderdate
from sales.Orders o
inner join sales.Customers c on c.custid = o.custid
where c.custid = @idclient
and o.orderdate between @startdate and @enddate

exec sp_GetOrders 37

exec sp_GetOrders @idclient = 37, @enddate = '2007-12-31'


/*
Procedura stocata -> raport la nivel de client: nr comenzi, suma cantitati, suma incasari
*/

if object_id('sp_CustReport', 'p') is not null
drop proc sp_CustReport
GO

create procedure sp_CustReport (@startdate date = '1900-01-01', @enddate date = '2999-12-31')
as 

begin 
set nocount on

select c.companyname, count(distinct o.orderid) as NumOrders, sum(od.qty) as TotalQty, sum(od.qty * od.unitprice) as TotalOrderAmt
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by c.companyname
--order by TotalOrderAmt desc

end

GO

exec sp_CustReport @enddate = '2008-10-01'

/*
Sa se modifice procedura, incat sa afiseze si tara, precum sa si poata exista filtrare pe tara
*/

alter procedure sp_CustReport (@startdate date = '1900-01-01', @enddate date = '2999-12-31', @country varchar(30))
as 

begin 

set nocount on

select c.companyname, c.country, count(distinct o.orderid) as NumOrders, sum(od.qty) as TotalQty, sum(od.qty * od.unitprice) as TotalOrderAmt
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
and c.country = @country
group by c.companyname, c.country
--order by TotalOrderAmt desc

end

GO

exec sp_CustReport @country = 'Argentina'

/*
Proceduri stocate cu parametri de output -> pt un client, sa se afiseze pe o perioada de timp toate comenzile. 
sa se afiseze nr total de comenzi, ca si output
*/

if object_id('sp_GetOrders', 'p') is not null
drop proc sp_GetOrders

GO

create procedure sp_GetOrders (@idclient int, @startdate date = '1900-01-01', @enddate date = '2999-12-31', @no_rows int = 0 out)
as

begin

set nocount on

select c.companyname, o.orderid, o.orderdate
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where orderdate between @startdate and @enddate
and c.custid = @idclient

set @no_rows = @@ROWCOUNT

end

GO

declare @vNoOrders as int

exec sp_GetOrders @idclient = 37, @no_rows = @vNoOrders OUTPUT

select @vNoOrders as NoOrders

GO

declare @vNoOrders as int

exec sp_GetOrders @idclient = 37, @vNoOrders = @no_rows OUTPUT

select @vNoOrders as NoOrders


/*Ex. 1 -> Proc stocata care va det pt fiecare tara client, luand in considerare (filtru) tara specificata:
-numar comenzi
-numar comenzi livrate
-cost transport
-valoarea vanzarilor
 */

 if object_id('sp_GetCountryReport', 'p') is not null
 drop proc sp_GetCountryReport
 GO

 create procedure sp_GetCountryReport (@country varchar(30))
 as

 begin

 set nocount on

 select c.country, 
 count(distinct o.orderid) as NoOrders, 
 count(distinct case when o.shippeddate is not null then o.orderid end) as NoShippedOrders,
 --sum(o.freight) as FreightAmt,
 sum(od.qty * od.unitprice) as TotalAmt
 from sales.Customers c
 inner join sales.Orders o on o.custid = c.custid
 inner join sales.OrderDetails od on od.orderid = o.orderid
 where c.country = @country
 group by c.country

 end
 
 GO

 exec sp_GetCountryReport 'USA'