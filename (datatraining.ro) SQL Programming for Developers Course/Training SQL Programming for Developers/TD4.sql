/*
Sa se creeze doua copii pentru tabela Sales.Customers avand coloanele: custid, companyname, country. 
Fiecare tabela copie nu va avea initial date. 
Cele doua tabele copie se vor numi: Sales.CustSRC si Sales.CustTGT. 
Tabela sursa va veni full in fiecare zi.
- Sa se insereze in tabela Sales.CustSRC (atentie la coloana custid care este identity) urmatorii clienti:
o 8001, Test1, Romania
o 8002, Test2, Romania
o 8003, Test3, Romania
- Sa se construiasca MERGE astfel incat:
o Orice client nou venit in tabela sursa sa fie inserat in tabela target
o Orice modificare venita pe un client in tabela sursa se se propage in tabela target
o ! Daca se vor sterge clienti din tabela sursa, acestia sa nu se stearga din tabela target (in cadrul lui MERGE, nu se va trata WHEN NOT MATCHED BY SOURCE).
*/

--Pas1: Creare copii pt tabel Sales.Customers
select *
into Sales.CustSRC
from sales.Customers
where 1 = 2
GO

alter table Sales.CustSRC add constraint pk_custid_src primary key (custid)
GO

select *
into Sales.CustTGT
from sales.Customers
where 1 = 2
GO

alter table Sales.CustTGT add constraint pk_custid_tgt primary key (custid)
GO

alter table sales.CustSRC alter column [contactname] [nvarchar](30) NULL
alter table sales.CustSRC alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustSRC alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustSRC alter column [address] [nvarchar](60) NULL
alter table sales.CustSRC alter column [city] [nvarchar](15) NULL
alter table sales.CustSRC alter column [phone] [nvarchar](24) NULL

alter table sales.CustTGT alter column [contactname] [nvarchar](30) NULL
alter table sales.CustTGT alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustTGT alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustTGT alter column [address] [nvarchar](60) NULL
alter table sales.CustTGT alter column [city] [nvarchar](15) NULL
alter table sales.CustTGT alter column [phone] [nvarchar](24) NULL
--Pas2: Inserare inregistrari in tabel SRC

SET IDENTITY_INSERT sales.CustSRC ON
GO

insert into sales.CustSRC (custid, companyname, country)
values
	(8001, 'Test1', 'Romania'),
	(8002, 'Test2', 'Romania'),
	(8003, 'Test3', 'Romania')
GO


SET IDENTITY_INSERT sales.CustSRC OFF
go

SET IDENTITY_INSERT sales.CustTGT ON

MERGE INTO Sales.CustTGT t
USING sales.CustSRC s on t.custid = s.custid
WHEN MATCHED AND (t.companyname <> s.companyname OR t.country <> s.country)
	THEN UPDATE SET t.companyname = s.companyname,
					t.country = s.country
WHEN NOT MATCHED BY TARGET
	THEN INSERT (custid, companyname, country) VALUES (s.custid, s.companyname, s.country)
--WHEN NOT MATCHED BY SOURCE THEN
;

SET IDENTITY_INSERT sales.CustTGT OFF


create procedure sp_mergecust
as

begin

SET IDENTITY_INSERT sales.CustTGT ON

MERGE INTO Sales.CustTGT t
USING sales.CustSRC s on t.custid = s.custid
WHEN MATCHED AND (t.companyname <> s.companyname OR t.country <> s.country)
	THEN UPDATE SET t.companyname = s.companyname,
					t.country = s.country
WHEN NOT MATCHED BY TARGET
	THEN INSERT (custid, companyname, country) VALUES (s.custid, s.companyname, s.country);

SET IDENTITY_INSERT sales.CustTGT OFF

end

--Testare
--Scenariul 1: vin modificari in sursa pe cei 3 clienti

update sales.CustSRC
set companyname='Test 1 modificat'
where custid=8001

select * from sales.CustSRC

exec sp_mergecust

select * from sales.CustTGT

--Scenariul 2: vin clienti noi in sursa

set identity_insert Sales.CustSRC on;

insert into Sales.CustSRC (custid, companyname, country) values (8004,'Test4','Romania')

set identity_insert Sales.CustSRC off;

select * from sales.CustSRC

exec sp_mergecust

select * from sales.CustTGT

--Scenariul 3: se sterge un client din sursa

delete from sales.CustSRC
where custid=8002

select * from sales.CustSRC

exec sp_mergecust

select * from sales.CustTGT

/*
Sa se creeze doua copii pentru tabela Sales.Customers avand coloanele: cusid, companyname, country. 
Fiecare tabela copie nu va avea initial date. 
Cele doua tabele copie se vor numi: Sales.CustSRC2 si Sales.CustTGT2
- Sa se insereze in tabela Sales.CustSRC2 (atentie la coloana custid care este identity) urmatorii client:
o 8001, Test1, Romania
o 8002, Test2, Romania
o 8003, Test3, Romania
Obs: Tabela Sales.CustSRC2 vine zilnic full. In cazul in care anumiti clienti nu mai vin in tabela Sales.CustSRC2, atunci:
- Sa se transfere initial toti clientii in tabela Sales.CustTGT2 (nu este necesar MERGE)
o In acest moment ambele tabele sunt egale
- Sa se adauge o coloana noua la tabela Sales.CustTGT2 cu numele IsDeleted
- Coloana IsDeleted va avea 0 initial pentru toate inregistrarile (se va face un update pentru toate randurile cu valoarea 0 fara where)
- Sa se construiasca MERGE Statement astfel incat:
o Daca sunt modificari pe un client in tabela sursa, atunci modificarile sa se propage si in tabela target, iar flag-ul IsDeleted ramane 0.
o Daca vine un client nou in tabela sursa acesta sa fie inserat in tabela target cu IsDeleted = 0
o Daca se sterge un client din tabela sursa sa se faca update pe coloana IsDeleted cu valoarea 1 pentru acest client
*/

--Pas1: creare tabele

select *
into Sales.CustSRC2
from sales.Customers
where 1 = 2

alter table Sales.CustSRC2 add constraint pk_cust_src primary key (custid)

alter table sales.CustSRC2 alter column [contactname] [nvarchar](30) NULL
alter table sales.CustSRC2 alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustSRC2 alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustSRC2 alter column [address] [nvarchar](60) NULL
alter table sales.CustSRC2 alter column [city] [nvarchar](15) NULL
alter table sales.CustSRC2 alter column [phone] [nvarchar](24) NULL

select *
into Sales.CustTGT2
from sales.Customers
where 1 = 2

alter table Sales.CustTGT2 add constraint pk_cust_tgt primary key (custid)

alter table sales.CustTGT2 alter column [contactname] [nvarchar](30) NULL
alter table sales.CustTGT2 alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustTGT2 alter column [contacttitle] [nvarchar](30) NULL
alter table sales.CustTGT2 alter column [address] [nvarchar](60) NULL
alter table sales.CustTGT2 alter column [city] [nvarchar](15) NULL
alter table sales.CustTGT2 alter column [phone] [nvarchar](24) NULL

alter table Sales.CustTGT2
add IsDeleted bit

select * from sales.CustSRC2
select * from Sales.CustTGT2

--Pas2: inserare inregistrari in sursa

set identity_insert sales.CustSRC2 ON

insert into sales.CustSRC2 (custid, companyname, country)
values
	(8001, 'Test1', 'Romania'),
	(8002, 'Test2', 'Romania'),
	(8003, 'Test3', 'Romania')

set identity_insert sales.CustSRC2 OFF

--Pas3: Merge

set identity_insert sales.CustTGT2 ON

MERGE INTO sales.CustTGT2 t
using sales.CustSRC2 s ON s.custid = t.custid
WHEN MATCHED AND (t.companyname <> s.companyname OR t.country <> s.country) 
	THEN UPDATE SET t.companyname = s.companyname,
					t.country = s.country
WHEN NOT MATCHED BY TARGET
	THEN INSERT (custid, companyname, country, isdeleted) VALUES (s.custid, s.companyname, s.country, 0)
WHEN NOT MATCHED BY SOURCE
	THEN UPDATE SET t.isdeleted = 1
;

set identity_insert sales.CustTGT2 OFF

--Pas4: Incapsulare Merge in procedura stocata

create procedure sp_mergecust2
as

begin

set identity_insert sales.CustTGT2 ON

MERGE INTO sales.CustTGT2 t
using sales.CustSRC2 s ON s.custid = t.custid
WHEN MATCHED AND (t.companyname <> s.companyname OR t.country <> s.country) 
	THEN UPDATE SET t.companyname = s.companyname,
					t.country = s.country
WHEN NOT MATCHED BY TARGET
	THEN INSERT (custid, companyname, country, isdeleted) VALUES (s.custid, s.companyname, s.country, 0)
WHEN NOT MATCHED BY SOURCE
	THEN UPDATE SET t.isdeleted = 1
;

set identity_insert sales.CustTGT2 OFF

end

--Testare:
select * from sales.custsrc2
select * from sales.CustTGT2

exec sp_mergecust2

--modificare sursa
update sales.CustSRC2
set companyname = 'Test 1 modificat'
where custid = 8001

select * from sales.custsrc2

exec sp_mergecust2

select * from sales.CustTGT2

--rand nou sursa

set identity_insert Sales.CustSRC2 on

insert into Sales.CustSRC2 (custid, companyname, country) values (8004,'Test4','Romania')

set identity_insert Sales.CustSRC2 off

select * from sales.custsrc2

exec sp_mergecust2

select * from sales.CustTGT2

--rand sters in tabela sursa

delete from sales.CustSRC2
where custid = 8002

select * from sales.custsrc2

exec sp_mergecust2

select * from sales.CustTGT2


--Merge cu OUTPUT
/*
Se considera tabela Sales.Orders careia i se face:
-o copie cu numele Sales.OrdersTGTHIST (va avea inregistrarile istorizate) si 
-inca o copie cu numele Sales.OrdersSRCINI (va avea inregistrarile asa cum vin din sursa zilnic, 
mai intai full si apoi zilnic delta = doar comenzile noi, modificarile pe comenzi vechi, nu se sterg comenzi)
In tabela Sales.OrdersTGTHIST se vor adauga 2 coloane suplimentare care asigura istorizarea datelor: 
-Valid_From (data type = date) si 
-Valid_To (data type = date)
Din punct de vedere SCD (Slowly Changing Dimension), este SCD de tip 2: se cunoaste imaginea anterioara de la data x la data y si 
imaginea curenta de la data y la infinit.

Merge:
-inregistrari noi in sursa: se transfera catre target -> Valid From = ziua in care au fost aduse inregistrarile, Valid To = '2999-12-31'
-modificare date in sursa: se inchide vechea inregistrare (Valid To = ziua in care au fost aduse modificari) + inserare rand nou cu modificari
-stergere date din sursa: in target, linia cu inregistrarea stearsa se inchide (Valid To = ziua in care au fost sterse inregistrarile)
*/

--Pas1: creare tabele
select orderid, empid, freight, shippeddate
into sales.ordersTGTHIST
from sales.orders
where 1 = 2

alter table sales.ordersTGTHIST add ValidFrom date not null
alter table sales.ordersTGTHIST add ValidTo date not null

alter table sales.ordersTGTHIST add constraint pk_orderValid primary key (orderid, ValidFrom)

select orderid, empid, freight, shippeddate
into sales.ordersSRCINI
from sales.orders

alter table sales.ordersSRCINI add constraint pk_order primary key (orderid)

--Pas2: constructie Merge
--update Valid To pe randuri existente, inchizand randul, in cazul in care se modifica tabelul sursa
--insert randuri noi si Valid_From = data curenta, Valid_To = '2999-12-31'

create table #tbl
(
ActionType varchar(100),
OrderID int,
EmpID int,
Freight money,
ShippedDate date
)

SET IDENTITY_INSERT sales.orderstgthist ON

MERGE INTO sales.orderstgthist t
USING sales.orderssrcini s on s.orderid = t.orderid AND t.ValidTo = '2999-12-31'
WHEN MATCHED AND (t.empid <> s.empid OR t.freight <> s.freight OR t.shippeddate <> s.shippeddate)
	THEN UPDATE SET t.ValidTo = cast(getdate() as date)
WHEN NOT MATCHED BY TARGET 
	THEN INSERT (orderid, empid, freight, shippeddate, ValidFrom, ValidTo) 
		 VALUES (s.orderid, s.empid, s.freight, s.shippeddate, cast(getdate() as date), '2999-12-31')
OUTPUT $action as ActionType, 
	   deleted.orderid, 
	   deleted.empid, 
	   deleted.freight, 
	   deleted.shippeddate 
INTO #tbl

INSERT INTO sales.ordersTGTHIST (orderid, empid, freight, shippeddate, ValidFrom, ValidTo)
select s.orderid, s.empid, s.freight, s.shippeddate, dateadd(dd, 1, cast(getdate() as date)) as ValidFrom, '2999-12-31' as ValidTo
from sales.ordersSRCINI s
inner join sales.ordersTGTHIST s on s.orderid = t.orderid
where ActionType = 'UPDATE'

SET IDENTITY_INSERT sales.orderstgthist OFF

--Pas3: Incapsulare in procedura stocata
create procedure sp_mergeordersOUT as

begin

if object_id('#tbl', 'u') is not null
	drop table #tbl

create table #tbl
(
ActionType varchar(100),
OrderID int,
EmpID int,
Freight money,
ShippedDate date
)

SET IDENTITY_INSERT sales.orderstgthist ON

MERGE INTO sales.orderstgthist t
USING sales.orderssrcini s on s.orderid = t.orderid AND t.ValidTo = '2999-12-31'
WHEN MATCHED AND (t.empid <> s.empid OR t.freight <> s.freight OR t.shippeddate <> s.shippeddate)
	THEN UPDATE SET t.ValidTo = cast(getdate() as date)
WHEN NOT MATCHED BY TARGET 
	THEN INSERT (orderid, empid, freight, shippeddate, ValidFrom, ValidTo) 
		 VALUES (s.orderid, s.empid, s.freight, s.shippeddate, cast(getdate() as date), '2999-12-31')
OUTPUT $action as ActionType, 
	   deleted.orderid, 
	   deleted.empid, 
	   deleted.freight, 
	   deleted.shippeddate 
INTO #tbl;

INSERT INTO sales.ordersTGTHIST (orderid, empid, freight, shippeddate, ValidFrom, ValidTo)
select s.orderid, s.empid, s.freight, s.shippeddate, dateadd(dd, 1, cast(getdate() as date)) as ValidFrom, '2999-12-31' as ValidTo
from sales.ordersSRCINI s
inner join #tbl t on s.orderid = t.orderid
where ActionType = 'UPDATE'

SET IDENTITY_INSERT sales.orderstgthist OFF

end

select * from sales.ordersSRCINI
select * from sales.ordersTGTHIST

exec sp_mergeordersOUT

select * from sales.ordersTGTHIST

--Test1: modificare date in sursa
update sales.ordersSRCINI
set empid = 7
where orderid = 10248

select * from sales.ordersSRCINI
select * from sales.ordersTGTHIST

exec sp_mergeordersOUT

select * from dbo.#tbl

/*
Proiect Merge si Proceduri
*/

--Pas1: creare tabele

select custid, companyname, country
into sales.cust_project
from sales.Customers
where 1 = 2

drop table sales.cust_project_hist
select custid, companyname, country, cast(getdate() as date) as Valid_From, '2999-12-31' as Valid_To
into sales.cust_project_hist
from sales.Customers

alter table sales.cust_project add constraint pk_cust primary key (custid)

alter table sales.cust_project_hist alter column Valid_From date not null
alter table sales.cust_project_hist add constraint pk_custValid primary key (custid, Valid_From)

select orderid, custid, orderdate, freight
into sales.ord_project
from sales.Orders
where 1 = 2

drop table sales.ord_project_hist
select orderid, custid, orderdate, freight, cast(getdate() as date) as Valid_From, '2999-12-31' as Valid_To
into sales.ord_project_hist
from sales.Orders

alter table sales.ord_project add constraint pk_ord primary key (orderid)
GO

alter table sales.ord_project_hist alter column Valid_From date not null
GO

alter table sales.ord_project_hist add constraint pk_ordValid primary key (orderid, Valid_From)
GO

alter table sales.ord_project_hist drop constraint pk_ordValid

alter table sales.ord_project_hist drop column Valid_From
GO
alter table sales.ord_project_hist drop column Valid_To

alter table sales.ord_project_hist add constraint pk_ord2 primary key (orderid)

--Pas2: Creare Procedura de Merge Cust

alter procedure sp_mergecust as

begin

if object_id('#mergecust', 'u') is not null
	drop table #mergecust

create table #mergecust
(
action_type varchar(10),
custid int,
companyname varchar(50),
country varchar(50)
)

SET IDENTITY_INSERT sales.cust_project_hist ON 

MERGE INTO sales.cust_project_hist t
USING sales.cust_project s on s.custid = t.custid AND t.Valid_To = '2999-12-31'
WHEN MATCHED AND (t.companyname <> s.companyname OR t.country <> s.country)
	THEN UPDATE SET t.Valid_To = cast(getdate() as date)
WHEN NOT MATCHED BY TARGET
	THEN INSERT (custid, companyname, country, Valid_From, Valid_To) 
		 VALUES (s.custid, s.companyname, s.country, cast(getdate() as date), '2999-12-31') 
OUTPUT $action as action_type,
	   deleted.custid,
	   deleted.companyname,
	   deleted.country
INTO #mergecust;

INSERT INTO sales.cust_project_hist (custid, companyname, country, Valid_From, Valid_To)
select s.custid, s.companyname, s.country, dateadd(dd, 1, cast(getdate() as date)) as Valid_From, '2999-12-31'
from sales.cust_project s
inner join #mergecust t on t.custid = s.custid
where action_type = 'UPDATE'

SET IDENTITY_INSERT sales.cust_project_hist OFF

end

--Pas3: Creare procedura de incremental load in orders
create procedure sp_insertordersdelta as

begin 

SET IDENTITY_INSERT sales.ord_project_hist ON

INSERT INTO sales.ord_project_hist (orderid, custid, orderdate, freight)
select a.orderid, a.custid, a.orderdate, a.freight
from sales.ord_project a
left join sales.ord_project_hist b on a.orderid = b.orderid
where b.orderid is null

SET IDENTITY_INSERT sales.ord_project_hist OFF

end

--Pas4: Creare procedura master, de executie a celor 2 proceduri create anterior
alter procedure sp_master as

begin

exec sp_mergecust
exec sp_insertordersdelta

end 

--Pas5: creare functie de utilizat in raport
create function udf_getshippers(@freight money)
returns decimal(18, 4)
as

begin

return 0.1 * @freight

end 

--Pas6: creare procedura creare raport

create procedure sp_report_prj as

begin

select c.custid, c.companyname, c.country, count(o.orderid) as Orders, sum(freight) as Freight, sum(dbo.udf_getshippers(freight)) as ShippersCost
from sales.cust_project_hist c
inner join sales.ord_project_hist o on o.custid = c.custid
where Valid_To = '2999-12-31'
group by c.custid, c.companyname, c.country

end

select * from sales.cust_project_hist
select * from sales.ord_project_hist

exec sp_report_prj

SET IDENTITY_INSERT sales.cust_project ON

insert into sales.cust_project (custid, companyname, country)
values (52, 'Customer PZNLA', 'Italy')

SET IDENTITY_INSERT sales.cust_project OFF

exec sp_master

select * from sales.cust_project_hist where custid = 52