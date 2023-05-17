/*
Ex2. Sa se creeze o procedura stocata care va avea parametrii de perioada optionali. Ea va determina pentru fiecare angajat valoarea vanzarilor. 
Totodata, procedura stocata va returna si valoarea totala a vanzarilor pentru toti angajatii.
*/

use Training
GO

if object_id('sp_GetSalesEmp', 'p') is not null
drop proc sp_GetSalesEmp
GO

create procedure sp_GetSalesEmp (@startdate date = '1900-01-01', @enddate date = '2999-12-31', @totalsales decimal(18, 2) = 0 OUTPUT)
as

begin

set nocount on

select e.titleofcourtesy + ' ' + e.firstname + ' ' + e.lastname as FullName, sum(od.qty * od.unitprice) as Sales
from hr.Employees e
inner join sales.Orders o on o.empid = e.empid
inner join sales.OrderDetails od on od.orderid = o.orderid
where o.orderdate between @startdate and @enddate
group by e.titleofcourtesy + ' ' + e.firstname + ' ' + e.lastname

set @totalsales = (
				    select sum(od.qty * od.unitprice) as Sales
					from hr.Employees e
					inner join sales.Orders o on o.empid = e.empid
					inner join sales.OrderDetails od on od.orderid = o.orderid
					where o.orderdate between @startdate and @enddate
					)

end

GO

declare @Sales as decimal(18, 2)

exec sp_GetSalesEmp @startdate = '2007-01-01', @enddate = '2007-12-31', 
					@totalsales = @Sales OUTPUT

select @Sales as TotalSales

/*
Ex3. Sa se creeze o procedura stocata ca va retura valoarea primei comenzi livrate a fiecarui client si valoarea totala a vanzarilor pentru 
fiecare client.
*/

if object_id('sp_GetFirstOrder') is not null
drop proc sp_GetFirstOrder
GO

create procedure sp_GetFirstOrder
as

begin

if object_id('tempdb.dbo.#firstorder', 'u') is not null
drop table #firstorder

select custid, companyname, orderdate, SalesValue as FirstSaleValue
into #firstorder
from 
	(
	 select c.custid, c.companyname, o.orderdate, sum(od.qty * od.unitprice) as SalesValue, 
	 row_number() over(partition by c.custid order by o.orderdate) as rn
	 from sales.Customers c 
	 inner join sales.Orders o on o.custid = c.custid
	 inner join sales.OrderDetails od on od.orderid = o.orderid
	 group by c.custid, c.companyname, o.orderdate
	) as a
where rn = 1 

if object_id('tempdb.dbo.#totalsales', 'u') is not null
drop table #totalsales

select c.custid, sum(od.qty * od.unitprice) as TotalSales
into #totalsales
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
group by c.custid


select a.companyname, FirstSaleValue, TotalSales
from #firstorder a
inner join #totalsales b on a.custid = b.custid
order by a.companyname

end

GO

exec sp_GetFirstOrder

Test:	 
	 select c.custid, c.companyname, --o.orderdate, 
	 sum(od.qty * od.unitprice) as SalesValue
	 from sales.Customers c 
	 inner join sales.Orders o on o.custid = c.custid
	 inner join sales.OrderDetails od on od.orderid = o.orderid
	 where c.companyname = 'Customer EEALV'
	 group by c.custid, c.companyname--, o.orderdate
	 --order by o.orderdate
	 --Customer EEALV	1832.80	 22607.70
	 
	 
/*
Ex 4. Sa se creeze o procedura stocata care va crea tabela Raport_Vanzari_luna_anterioara de fiecare data cand va fi rulata. 
Tabela va avea coloanele:
a. IdLuna de forma yyyymm
b. Valoare_Vanzari
In tabela se va insera valoarea totala a vanzarilor din luna aterioara rularii, deci procedura va avea ca parametru luna curenta.
*/

if object_id('sp_PrevMonthSales', 'p') is not null
drop proc sp_PrevMonthSales
GO

create procedure sp_PrevMonthSales (@reportingdate date)
as

begin

set nocount on

--pas1: creare tabela

if object_id('Training.dbo.prevmonthsales','u') is not null
drop table Training.dbo.prevmonthsales

create table Training.dbo.prevmonthsales
(
IdLuna int,
Valoare_Vanzari decimal(18, 2)
)

--pas2: crearea variabilei idmonth, care sa populeze coloana IdLuna

declare @IdMonth int
set @IdMonth = (
				select year(dateadd(mm, -1, @reportingdate)) * 100 + 
					   month(dateadd(mm, -1, @reportingdate))
				)

--pas3: creare variabile startdate si enddate, pt a putea identifica limitele intervalului de timp (lunii)

declare @startdate date,
		@enddate date

set @startdate = dateadd(dd, 1, dateadd(mm, -2, EOMONTH(@reportingdate)))
set @enddate = dateadd(mm, -1, EOMONTH(@reportingdate))

--pas4: insert into table

insert into Training.dbo.prevmonthsales 
(IdLuna, Valoare_Vanzari)
select @IdMonth, sum(od.qty * od.unitprice) 
from sales.Orders o
inner join sales.OrderDetails od on od.orderid = o.orderid 
where o.orderdate between @startdate and @enddate

end
GO

exec sp_PrevMonthSales @reportingdate = '2007-06-01'
select * from Training.dbo.prevmonthsales

/*
Ex 5. Sa se modifice procedura creata la punctul 4. astfel incat executarea procedurii sa insereze in tabela existenta 
Raport_Vanzari_luna_anterioara valoarea vanzarilor din luna anterioara rularii. 
In cazul in care o rulare s-a realizat de 2 ori, sa se stearga datele din tabela pentru prima rulare si sa se insereze din nou.
*/

--pas1: creare tabela, ce nu se va sterge

create table Training.dbo.prevmonthsales
(
IdLuna int,
Valoare_Vanzari decimal(18, 2)
)

alter procedure sp_PrevMonthSales (@reportingdate date)
as

begin

set nocount on

--pas2: crearea variabilei idmonth, care sa populeze coloana IdLuna

declare @IdMonth int
set @IdMonth = (
				select year(dateadd(mm, -1, @reportingdate)) * 100 
						+ 
					   month(dateadd(mm, -1, @reportingdate))
				)

--pas3: creare variabile startdate si enddate, pt a putea identifica limitele intervalului de timp (lunii)

declare @startdate date,
		@enddate date

set @startdate = dateadd(dd, 1, dateadd(mm, -2, EOMONTH(@reportingdate)))
set @enddate = dateadd(mm, -1, EOMONTH(@reportingdate))

--pas4: stergere date deja inserate, pentru luna respectiva
delete from Training.dbo.prevmonthsales 
where IdLuna = @IdMonth

--pas5: inserare date

insert into Training.dbo.prevmonthsales 
(IdLuna, Valoare_Vanzari)
select @IdMonth, sum(od.qty * od.unitprice) 
from sales.Orders o
inner join sales.OrderDetails od on od.orderid = o.orderid 
where o.orderdate between @startdate and @enddate

end
GO

exec sp_PrevMonthSales @reportingdate = '2007-07-01'
select * from Training.dbo.prevmonthsales

--Proceduri stocate imbricate
/*
- Sa se creeze o procedura stocata care va extrage un raport cu vanzarile din anul anterior rularii.
- Sa se creeze o procedura stocata care va determina cati client cumparatori au fost in anul anterior.
- Sa se creeze o procedura stocata master care va rula cele doua proceduri de mai sus.
*/

if object_id('sp_RaportVanzari', 'p') is not null
drop proc sp_RaportVanzari
go

create procedure sp_RaportVanzari (@reportingdate date)
as

begin

set nocount on

select sum(od.qty * od.unitprice) as TotalVanzari
from sales.Orders o
inner join sales.OrderDetails od on od.orderid = o.orderid
where year(o.orderdate) = year(@reportingdate) - 1

end
GO

if object_id('sp_RaportClienti', 'p') is not null
drop proc sp_RaportClienti
go

create procedure sp_RaportClienti (@reportingdate date)
as

begin

set nocount on

select count(distinct c.custid) as NrClienti
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
where year(o.orderdate) = year(@reportingdate) - 1

end
GO 


if object_id('sp_master', 'p') is not null
drop proc sp_master
GO

create procedure sp_master (@reportingdate date) as

begin

set nocount on

exec sp_RaportVanzari @reportingdate
exec sp_RaportClienti @reportingdate

end
GO

exec sp_master '2007-01-01'


/*
PROIECT Proceduri stocate
Departamentul Sales de Business solicita departamentului de Data Warehouse un raport cu vanzarile detaliate la nivel de client 
(custid, companyname, country), categoria de produse (categoryid, categoryname) pentru o perioada mentionata (@startdate, @enddate). 
Rezultatul rularii raportului va fi stocata intr-o tabela creata one time, cu numele Sales_Report_by_Customer.
Mentiuni suplimentare:
- Pas 1: se va defini mai intai tabela Sales_report_by_Customer cu urmatoarele coloane:
o Startdate datetime
o Enddate datetime
o Custid int
o Companyname nvarchar(40)
o Country nvarchar(15)
o CategoryId int
o Categoryname nvarchar(15)
o Sales decimal(18,2)
- Pas 2: se va defini procedura stocata care:
o In cazul in care a fost deja rulata, se vor sterge randurile din tabela 
(se verifica daca startdate din tabela si enddate din tabela coincide cu parametrii de rulare)
o Va insera datele in tabela Sales_report_by_customer
*/

--pas1: creare tabela

create table Training.Sales.Sales_report_by_Customer
(
Startdate datetime,
Enddate datetime,
Custid int,
Companyname nvarchar(40),
Country nvarchar(15),
CategoryId int,
Categoryname nvarchar(15),
Sales decimal(18,2)
)

if object_id('sp_GetReportbyCust', 'p') is not null
drop proc sp_GetReportbyCust
GO

create procedure sp_GetReportbyCust (@startdate date, @enddate date)
as

begin

--pas2: stergerea datelor deja inserate pt un Startdate si Enddate

delete from Training.Sales.Sales_report_by_Customer
where Startdate = @startdate
and Enddate = @enddate

--pas3: inserare date in tabela

insert into Training.Sales.Sales_report_by_Customer
(Startdate, Enddate, Custid, Companyname, Country, CategoryId, Categoryname, Sales)
select @startdate, @enddate, c.custid, c.companyname, c.country, pc.categoryid, pc.categoryname, sum(od.qty * od.unitprice) as Sales
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
inner join Production.Products p on p.productid = od.productid
inner join Production.Categories pc on pc.categoryid = p.categoryid
group by c.custid, c.companyname, c.country, pc.categoryid, pc.categoryname

end
GO

exec sp_GetReportbyCust @startdate = '2007-01-01', @enddate = '2009-12-31'
select * from Training.Sales.Sales_report_by_Customer

--Functii

/*
Ex. Sa se construiasa o functie care va returna cantitate ori pret.
*/

create function udf_ExtAmount (@unitprice decimal(18, 4), @qty int)
returns decimal(18, 4)
as

begin

	return @unitprice * @qty

end

select orderid, productid, unitprice, qty, dbo.udf_ExtAmount (unitprice, qty) as Sales
from sales.OrderDetails

select orderid, sum(dbo.udf_ExtAmount (unitprice, qty)) as Sales
from sales.OrderDetails
group by orderid

/*
Ex.: Sa se construiasca o functie care va determina ziua peste 5 ani pornind de la o data mentionata.
*/

create function udf_getdateafter5yrs (@date date)
returns date
as

begin

	return dateadd(yy, 5, @date)

end

select empid, firstname, lastname, hiredate, dbo.udf_getdateafter5yrs(hiredate)
from hr.Employees

--numar ani
--date pensionare = data nastere + 60

/*
Sa se defineasca o functie scalara care va determina daca diferenta dintre doua date calendaristice este mai mare de 10 zile. 
Rezultatul va fi true sau false (bit). 
Sa se utilizeze functia pentru a calcula diferenta dintre orderdate si shippeddate din tabela Sales.Orders si 
sa se evalueze daca perioada de livrare este peste 10 zile sau sub 10 zile.
*/

create function udf_getperiod (@startdate date, @enddate date)
returns bit
as

begin

	declare @check bit
	set @check = (select case when datediff(dd, @startdate, @enddate) > 10 then 1 else 0 end)
	return @check

end

select orderid, orderdate, shippeddate, dbo.udf_getperiod(orderdate, shippeddate) as flag
from sales.Orders
where dbo.udf_getperiod(orderdate, shippeddate) = 1

alter function udf_getperiod (@startdate date, @enddate date)
returns bit
as

begin

	declare @check bit
	set @check = (select case when datediff(dd, @startdate, @enddate) > 15 then 1 else 0 end)
	return @check	

end
GO

select orderid, orderdate, shippeddate, dbo.udf_getperiod(orderdate, shippeddate) as flag
from sales.Orders
where dbo.udf_getperiod(orderdate, shippeddate) = 1

--Functii Tabelare
--Inline
/*
Sa se defineasca o functie care determina produsele vandute pentru o anumita categorie de produse mentionata.
*/

create function udf_getsalesctg(@categoryname varchar(30))
returns table
as

return 
(
select distinct p.productname, ctg.categoryname, sum(od.qty * od.unitprice) as Sales
from sales.OrderDetails od
inner join Production.Products p on p.productid = od.productid
inner join production.Categories ctg on ctg.categoryid = p.categoryid
where ctg.categoryname = @categoryname
group by p.productname, ctg.categoryname
)

select * from dbo.udf_getsalesctg('Seafood')

/*
Sa se defineasca o functie tabelara care sa determine incasarile per fiecare client pentru o tara client mentionata.
*/

create function udf_salescustcountry(@countryname varchar(30))
returns table
as

return
(
select c.companyname, c.country, sum(od.qty * od.unitprice) as Sales
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where c.country = @countryname
group by c.companyname, c.country
)
go

select * from udf_salescustcountry('Argentina')

--Table-valued functions

/*
Ex: Sa se determine intr-un tabel tarile clientilor si tarile angajatilor mentionand in dreptul fiecarei tari daca provine de la angajat 
sau de la client. Functia va rula cu parametrul country_name si va returna daca o tara apartine clientilor si / sau angajatilor.
*/

create function udf_getcountries(@countryname varchar(30))
returns @Countries table
(
countryname varchar(100),
type varchar(20)
)
as

begin

	insert into @Countries (countryname, type)
	select distinct country, 'Employee'
	from hr.Employees
	where country = @countryname

	insert into @Countries (countryname, type)
	select distinct country, 'Customer'
	from sales.customers
	where country = @countryname

	RETURN

end
go

select * from udf_getcountries('Argentina')

/*
Sa se modifice functia de mai sus astfel incat sa nu primeasca parametru si va avea ca rezultat toate tarile. 
In cazul in care se doreste sa se filtreze tabela, atunci conditia se va insera in clauza WHERE la rularea functiei.
*/

alter function udf_getcountries()
returns @Countries table
(
countryname varchar(100),
type varchar(20)
)
as

begin

	insert into @Countries (countryname, type)
	select distinct country, 'Employee'
	from hr.Employees

	insert into @Countries (countryname, type)
	select distinct country, 'Customer'
	from sales.customers

	RETURN

end
go

select * from dbo.udf_getcountries()
where countryname = 'Argentina'

/*
Ex. 1: Sa se construiasca o functie (scalara) care va returna pentru un client suma vanzarilor, stiindu-se clientul.
*/

create function udf_getsales(@custid int)
returns decimal(18, 2)
as

begin

return 

(
select sum(od.qty * od.unitprice) as Sales
from sales.Orders o
inner join sales.OrderDetails od on od.orderid = o.orderid
where custid = @custid
)

end
go

select [dbo].[udf_getsales](37) as Sales

