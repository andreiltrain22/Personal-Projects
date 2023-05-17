/*
Proiect
*/

use Training
go

create table Product_Hist
(
productid int not null,
productname varchar(40),
unitprice decimal(18, 2),
categoryid int,
categoryname varchar(40),
ValidFrom date not null,
ValidTo date
)

alter table Product_Hist add constraint PK_Product_Hist primary key (productid, ValidFrom)

create procedure sp_merge_product_hist_1(@reportingdate date)
as

begin

if object_id('tempdb.dbo.#src', 'u') is not null
drop table tempdb.dbo.#src

select p.productid, p.productname, p.unitprice, ct.categoryid, ct.categoryname
into tempdb.dbo.#src
from Production.Products p
inner join Production.Categories ct on ct.categoryid = p.categoryid

if object_id('tempdb.dbo.#tbl', 'u') is not null
drop table tempdb.dbo.#tbl

create table tempdb.dbo.#tbl
(
action_Type varchar(10),
productid int
)

declare @Valid_To date
set @Valid_To = dateadd(dd, -1, @reportingdate)

merge into Product_Hist t
using #src s on s.productid = t.productid and t.ValidTo = '2999-12-31'
when matched and (t.productname <> s.productname OR t.categoryname <> s.categoryname OR t.unitprice <> s.unitprice)
	then update set t.ValidTo = @Valid_To
when not matched by target
	then insert (productid, productname, unitprice, categoryid, categoryname, ValidFrom, ValidTo) 
		 values	(s.productid, s.productname, s.unitprice, s.categoryid, s.categoryname, @reportingdate, '2999-12-31')

output
	$action as action_Type,
	deleted.productid
	into #tbl;

insert into Product_Hist(productid, productname, unitprice, categoryid, categoryname, ValidFrom, ValidTo) 
select s.productid, s.productname, s.unitprice, s.categoryid, s.categoryname, @reportingdate, '2999-12-31'
from #tbl as t
inner join #src as s on s.productid = t.productid
where action_Type = 'UPDATE'

end


alter procedure sp_merge_product_hist_2(@reportingdate date)
as

begin

if object_id('tempdb.dbo.#src', 'u') is not null
drop table tempdb.dbo.#src

select p.productid, p.productname, p.unitprice, ct.categoryid, ct.categoryname
into tempdb.dbo.#src
from Production.Products p
inner join Production.Categories ct on ct.categoryid = p.categoryid

declare @Valid_To date
set @Valid_To = dateadd(dd, -1, @reportingdate)

merge into Product_Hist t
using #src s on s.productid = t.productid and t.ValidTo = '2999-12-31'
when not matched by source and t.ValidTo = '2999-12-31'
	then update set t.ValidTo = @Valid_To;

end

create procedure sp_master_merge_product_hist(@reportingdate date)
as

begin

exec sp_merge_product_hist_1 @reportingdate
exec sp_merge_product_hist_2 @reportingdate

end

select * from Product_Hist

--Populare
exec sp_master_merge_product_hist '2020-10-10'

--Test2
update Production.Products
set unitprice = 50
where productid = 1

exec sp_master_merge_product_hist '2020-10-11'

select * from Product_Hist

--Test3
insert into Production.Categories(categoryname, description)
values ('Office', 'Office Products')

insert into production.Products (productname, supplierid, categoryid, unitprice, discontinued)
values ('Marker', 1, 9, 10, 0)

exec sp_master_merge_product_hist '2020-10-12'

select * from Product_Hist

--Test4
exec sp_master_merge_product_hist '2020-10-13'
GO

select * from Product_Hist

--Test5
delete from sales.OrderDetails where productid = 2
delete from production.Products where productid = 2

exec sp_master_merge_product_hist '2020-10-14'
GO

select * from Product_Hist

exec sp_master_merge_product_hist '2020-10-15'
GO

select * from Product_Hist

select categoryname, 
count(distinct case when unitprice <= 30 then productid end) as 'Pret Mic',
count(distinct case when unitprice between 31 and 59 then productid end) as 'Pret Mediu',
count(distinct case when unitprice >= 60 then productid end) as 'Pret Mare'
from Product_Hist 
where ValidTo = '2999-12-31'

update Product_Hist
set ValidTo = '2999-12-31'

update Product_Hist 
set ValidTo = '2020-10-10'
where productid = 1 and unitprice = 18

update Product_Hist 
set ValidTo = '2020-10-12'
where productid = 2

exec sp_master_merge_product_hist '2020-10-16'
GO
select * from Product_Hist

--Cursor--
--Are rolul de a evalua rand cu rand un input de date

/*
Pasi:
-declarare cursor -> declare (input de date = angajati)
-deschidere cursor -> open
-preluare prima inregistrare -> fetch next
-bucla while in care e parcurs input-ul de date
@@FETCH_STATUS = 0 -> aducere inregistrare anterioara a fost cu succes
@@FETCH_STATUS = 1 -> inregistrare in afara input-ului de date
@@FETCH_STATUS = 2 -> inregistrare lipseste din input de date
inchidere cursor -> close
dealocare cursor -> deallocate
*/

/*
Sa se det., pt fiecare angajat, vechimea pana in momentul de fata, la actualul loc de munca.
Sa se afiseze Text = 'Vechimea angajatului x este {nr. ani}'.
*/

declare @idangajat int

--declarare cursor
DECLARE emp_cursor CURSOR FOR
select empid from hr.employees --input de date cursor

--deschidere cursor
OPEN emp_cursor

--preluare prima inregistrare din input de date
FETCH NEXT FROM emp_cursor INTO @idangajat

--bucla while
WHILE @@FETCH_STATUS = 0

BEGIN

--evaluare fiecare iteratie in parte
select 'Vechimea Angajatului ' + firstname + ' ' + lastname + ' este: ' + cast(datediff(yy, hiredate, getdate()) as varchar(2)) + ' ani' as Message
from hr.employees
where empid = @idangajat

--preluare urm. inregistrare din cursor
FETCH NEXT FROM emp_cursor INTO @idangajat

END

--inchidere cursor
CLOSE emp_cursor

--dealocare cursor
DEALLOCATE emp_cursor


/*Sa se determine pentru fiecare client valoarea totala a vanzarilor. 
Sa se incapsuleze codul intr-o procedura stocata care va avea ca parametru @custid.
Apoi sa se ruleze procedura stocata pentru toti clientii si sa se afiseze mesajul “Valoarea vanzarilor clientului X cu numele Y este de Z”.
*/

create table ReportCust
(
custid int,
companyname varchar(30),
Sales decimal(18, 2)
)

create procedure sp_getsalescust(@custid int)
as

begin

select c.custid, c.companyname, sum(od.qty * od.unitprice) as Sales
from sales.Customers c
inner join sales.orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where c.custid = @custid
group by c.custid, c.companyname

end
GO

exec sp_getsalescust 37
GO

declare @customerid int

--declarare cursor
declare sales_cursor CURSOR FOR
select custid from sales.Customers --input de date

--deschidere cursor
OPEN sales_cursor

--preluare prima inregistrare din cursor si salvare in variabila
FETCH NEXT FROM sales_cursor INTO @customerid 

--WHILE
WHILE @@FETCH_STATUS = 0

BEGIN

insert into ReportCust (custid, companyname, Sales)
exec sp_getsalescust @customerid

--preluarea urmatoarei inregistrari
FETCH NEXT FROM sales_cursor INTO @customerid

END 

--inchidere cursor
CLOSE sales_cursor

--dezalocare cursor
DEALLOCATE sales_cursor

select * from ReportCust

/*
Sa se defineasca o procedura stocata care va determina vanzarea totala pentru o tara mentionata.
Apoi, sa se ruleze procedura stocata pentru toate tarile in tabela Customers utilizand un cursor.
*/

create procedure sp_getSalesForCountry(@country varchar(40))
as

begin

select c.country, sum(od.qty * od.unitprice) as Sales
from sales.Customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
where c.country = @country
group by c.country

end
GO

exec sp_getSalesForCountry 'Italy'
GO

create table SalesByCountry
(
country varchar(40),
Sales decimal(18, 2)
)

declare @countryname varchar(40)

declare sales_cursor CURSOR FOR
select distinct country from sales.Customers

open sales_cursor

fetch next from sales_cursor into @countryname

while @@FETCH_STATUS = 0 

begin

insert into SalesByCountry
exec sp_getSalesForCountry @countryname

fetch next from sales_cursor into @countryname

end

close sales_cursor
deallocate sales_cursor

--SQL Dinamic
/*
Sa se extraga numarul de comenzi sau numarul de produse sau numarul de categorii de produse sau numarul de clienti. 
Pentru aceasta cerinta sa se creeze un script care va avea ca filtru pe numele tabelului. 
Apoi, sa se transforme scriptul in procedura stocata cu parametru numele tabelului. 
Rezultatul scriptului sau al procedurii stocate va fi un count de nr total de randuri si numele tabelului. 
Rezultatul scriptului va fi inserat intr-o tabela permanenta cu urmatoarele coloane:
	Reporting_Date = getdate()
	Table_Name = provenit din parametru
	No_Rows = rezultatul count-ului.
*/

--Pas1: select simplu din tabela mentionata

select getdate() as reportingdate, 
	   'Production.Products' as tablename, 
	   count(*) as norows
from Production.Products

--Pas2: parametrizare statement
declare @reportingdate varchar(10), @tablename varchar(40)

set @reportingdate = cast(cast(getdate() as date) as varchar(10))
set @tablename = 'Production.Products'

select 'select ''' + @reportingdate + ''' as reportingdate,''' + char(13) + char(10)
		        + @tablename + ''' as tablename,
			   count(*) as no_rows
		from ' + @tablename
from INFORMATION_SCHEMA.TABLES
where TABLE_SCHEMA + '.' + TABLE_NAME = @tablename 
--select '2020-10-17' as reportingdate,' Production.Products' as tablename,        count(*) as no_rows    from Production.Products

create table sales.audit
(
reportingdate varchar(10),
tablename varchar(30),
row_no int
)

declare @sql varchar(max)

declare @reportingdate date, @tablename varchar(40)

set @reportingdate = cast(cast(getdate() as date) as varchar(10))
set @tablename = 'Production.Products'

set @sql = 'select ''' + @reportingdate + '''as reportingdate,
		       ''' + @tablename ''' as tablename,
			   count(*) as no_rows
		from ' + @tablename

--select @sql
--exec (@sql)

declare @insert varchar(max)
set @insert = 'insert into sales.audit (reportingdate, tablename, no_rows)'

--select * from INFORMATION_SCHEMA.TABLES
declare @delete varchar(max)
set @delete = 'delete from sales.audit where tablename = ''' + @tablename + ''''--and reportingdate = ''' + @reportingdate +'''' 

declare @finalsql varchar(max)
set @finalsql = @delete + @insert + @sql
select @finalsql


alter procedure sp_get_no_rows(@tablename varchar(40))
as

begin

declare @reportingdate varchar(10)
set @reportingdate = cast(cast(getdate() as date) as varchar(10))

declare @sql varchar(max)

set @sql = 'select ''' + @reportingdate + ''' as reportingdate,
		       ''' + @tablename + ''' as tablename,
			   count(*) as no_rows
		from ' + @tablename

declare @insert varchar(max)
set @insert = 'insert into sales.audit (reportingdate, tablename, no_rows)'

declare @delete varchar(max)
set @delete = 'delete from sales.audit where tablename = ''' + @tablename + ''' and reportingdate = ''' + @reportingdate +''' ' 

declare @finalsql varchar(max)
set @finalsql = @delete + @insert + @sql

exec @finalsql @tablename

end
GO

exec sp_get_no_rows 'Production.Products'

--Rularea procedurii din cursor
declare @tablename varchar(40)

declare tbl_cursor CURSOR FOR
select table_schema + '.' + table_name
from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'BASE TABLE' and table_name <> 'Audit'

OPEN tbl_cursor

FETCH NEXT FROM tbl_cursor INTO table_name

WHILE @@FETCH_STATUS = 0

BEGIN 

exec sp_get_no_rows @tablename

FETCH NEXT FROM tbl_cursor INTO table_name

END

CLOSE tbl_cursor
DEALLOCATE tbl_cursor

/*
Sa se determine per tara client si an order date suma vanzarilor.
*/

select c.country, year(o.shippeddate) An, sum(od.qty*od.unitprice) as Vanzare
from Sales.Customers c
inner join Sales.Orders o on o.custid=c.custid
inner join Sales.OrderDetails od on od.orderid=o.orderid
where o.shippeddate is not null
group by c.country, year(o.shippeddate)

select c.country,
sum(case when year(o.shippeddate)=2006 then od.qty*od.unitprice end) as Vanzari_2006,
sum(case when year(o.shippeddate)=2007 then od.qty*od.unitprice end) as Vanzari_2007,
sum(case when year(o.shippeddate)=2008 then od.qty*od.unitprice end) as Vanzari_2008
from Sales.Customers c
inner join Sales.Orders o on o.custid=c.custid
inner join Sales.OrderDetails od on od.orderid=o.orderid
where o.shippeddate is not null
group by c.country

--PIVOT

select country, [Sales_2006], [Sales_2007], [Sales_2008]
into #tblpivot
from
 
	(
		select c.country, 'Sales_' + cast(year(orderdate) as varchar(4)) as Year,
		sum(od.qty * od.unitprice) as Sales
		from sales.customers c
		inner join sales.Orders o on o.custid = c.custid
		inner join sales.OrderDetails od on od.orderid = o.orderid
		group by c.country, 'Sales_' + cast(year(orderdate) as varchar(4))
	 ) as s

PIVOT (sum(Sales) for Year in ([Sales_2006], [Sales_2007], [Sales_2008])) as PivotTable

select * from #tblpivot

select country, right(Year, 4) as Year, Sales
from #tblpivot
UNPIVOT (Sales for Year in ([Sales_2006], [Sales_2007], [Sales_2008])) as unpvt