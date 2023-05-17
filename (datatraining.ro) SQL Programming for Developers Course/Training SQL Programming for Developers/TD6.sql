/*
Sa se determine per tara client si an order date suma vanzarilor.
*/

select c.country, year(orderdate) as Year, sum(qty * unitprice) as Sales
into sales.src
from sales.customers c
inner join sales.Orders o on o.custid = c.custid
inner join sales.OrderDetails od on od.orderid = o.orderid
group by c.country, year(orderdate)

--Pivot utilizand dynamic sql

declare @cols varchar(max), 
		@query varchar(max)

set @cols = stuff(
				  (select distinct ', ' + quotename('Sales_' + cast(Year as varchar(4)))
				   from sales.src
				   for xml path('')), 1, 1, ''
				   )

--select @cols

set @query = 'select country,' + @cols + '
			  from (select country,
			              ''Sales_'' + cast(Year as varchar(4)) as Year
					     , Sales
			        from sales.src) as s
					PIVOT(sum(Sales) for Year in (' + @cols + ')) as p'
select @query
--exec (@query)

select country, [Sales_2006], [Sales_2007], [Sales_2008]       
from (select country, 'Sales_' + cast(Year as varchar(4)) as Year            , Sales             from sales.src) as s       PIVOT(sum(Sales) for Year in ( [Sales_2006], [Sales_2007], [Sales_2008])) as p

/*
Departamentul Sales de Business solicita departamentului de DWH un raport cu vanzarile la nivel de luna si an, rapoart actualizat in fiecare zi. 
Datele vor fi stocate intr-o tabela la care are acces departamentul de Sales.
Tabela va avea:
- Prima coloana numita Luna – varchar(20)
- Urmatoarele coloane vor fi anii sub forma: An_yyyy
Coloanele An_yyyy se vor defini dinamic, la trecerea de la un an la altul se va adauga dinamic inca o coloana numita An_yyyy(anul urmator).
Actualizarea tabelului se va face cu delete tot continutul si insert noul continut.
*/

select datename(month, orderdate) as Month, 
	   year(orderdate) as Year, 
	   sum(qty * unitprice) as Sales
into src1
from sales.Orders o
inner join sales.OrderDetails od on od.orderid = o.orderid
group by datename(month, orderdate), 
         year(orderdate)

select * from #src

declare @cols varchar(max),
		@query varchar(max)

set @cols = stuff(
                    (
                     select distinct ', ' + 'Year_' + cast(Year as varchar(4)) 
					 from #src
					 for xml path('')
					  )
					  , 1, 1, ''
				  )

--select @cols

set @query = 'select Month,' + @cols + '
              into Sales.Dept_Sales
              from 
			      (
				   select Month, 
				          ''Year_'' + cast(Year as varchar(4)) as Year,
				          Sales
			       from src1
			       ) as source
			   pivot (sum(Sales) for Year in (' + @cols + ')) as piv'

--select @query
exec (@query)

/*
select Month,  Year_2006, Year_2007, Year_2008                
into Sales.Dept_Sales                
from            
(select Month,                 
'Year_' + cast(Year as varchar(4)) as Year,                
Sales            
from src1            
) as source        
pivot (sum(Sales) for Year in ( Year_2006, Year_2007, Year_2008)) as piv
*/

alter procedure sp_get_dept_sales
as

begin

if object_id('Training.dbo.src1', 'u') is not null
drop table Training.dbo.src1

if object_id('Training.Sales.Dept_Sales', 'u') is not null
drop table Training.Sales.Dept_Sales

select datename(month, orderdate) as Month, 
	   year(orderdate) as Year, 
	   sum(qty * unitprice) as Sales
into src1
from sales.Orders o
inner join sales.OrderDetails od on od.orderid = o.orderid
group by datename(month, orderdate), 
         year(orderdate)

declare @cols varchar(max),
		@query varchar(max)

set @cols = stuff(
                    (
                     select distinct ', ' + 'Year_' + cast(Year as varchar(4)) 
					 from src1
					 for xml path('')
					  )
					  , 1, 1, ''
				  )

set @query = 'select Month,' + @cols + '
              into Sales.Dept_Sales
              from 
			      (
				   select Month, 
				          ''Year_'' + cast(Year as varchar(4)) as Year,
				          Sales
			       from src1
			       ) as source
			   pivot (sum(Sales) for Year in (' + @cols + ')) as piv'

exec (@query)

end

exec [dbo].[sp_get_dept_sales]

update Sales.Orders
set orderdate = '2009-03-10'
where orderid = 10248

select * from sales.dept_sales

/*
1. Sa se creeze o tabela cu numele Sales.Ord_bkp cu urmatoarele coloane: Orderid, Custid, Orderdate, Shipcountry. 
Tabela Sales.Ord_bkp nu contine date si va avea primary key pe coloana orderid.
2. Sa se construiasca dinamic statementul de merge care transfera date din tabela sursa in tabela target, 
cele doua putand fi stabilite de utilizator. 
Ambele tabele sunt pe aceeasi schema, Sales.
3. Sa se ruleze procedura pentru Sales.Ord_bkp si Sales.Orders
*/

--Pas1: creare tabele
create table sales.orders_source
(
orderid int not null,
custid int,
orderdate date,
shipcountry varchar(30)
)

alter table sales.orders_source add constraint pk_orderid primary key (orderid)

insert into sales.orders_source (orderid, custid, orderdate, shipcountry)
select orderid, custid, orderdate, shipcountry
from sales.Orders

create table sales.orders_target
(
orderid int not null,
custid int,
orderdate date,
shipcountry varchar(30)
)

alter table sales.orders_target add constraint pk_orderidtgt primary key (orderid)

declare @tablename_src varchar(50),
		@tablename_tgt varchar(50),
		@schema varchar(50)

set @tablename_src = 'Orders_Source'
set @tablename_tgt = 'Orders_Target'
set @schema = 'Sales'

--Pas2: calculare coloane pt cele 2 tabele
declare @cols_source varchar(max)

set @cols_source = stuff(
                          (select ', s.' + COLUMN_NAME
						   from information_schema.columns 
						   where table_name = @tablename_src 
						   and TABLE_SCHEMA = @schema
						   for xml path('')
						    ) 
						  , 1, 1, ''
						  )

--select * from information_schema.columns

--select @cols_source

declare @cols_target varchar(max)

set @cols_target = stuff(
                          (select ', ' + COLUMN_NAME
						   from INFORMATION_SCHEMA.COLUMNS
						   where table_name = @tablename_tgt
						   and TABLE_SCHEMA = @schema
						   for xml path('')
						    )
                          , 1, 1, '' 
                          )

--select @cols_target

--Pas3: PK pt tabela sursa si pt tabela target
declare @pk_source varchar(100)

set @pk_source = (
					select cu.COLUMN_NAME
					from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
					inner join INFORMATION_SCHEMA.KEY_COLUMN_USAGE cu on tc.CONSTRAINT_NAME = cu.CONSTRAINT_NAME
					where tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
					and tc.TABLE_NAME = @tablename_src
					and tc.TABLE_SCHEMA = @schema
					)

--select @pk_source

declare @pk_target varchar(100)

set @pk_target = (
                  select cu.column_name
				  from INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc
				  inner join INFORMATION_SCHEMA.KEY_COLUMN_USAGE as cu on tc.CONSTRAINT_NAME = cu.constraint_name
				  where tc.CONSTRAINT_type = 'PRIMARY KEY'
				  and tc.TABLE_NAME = @tablename_tgt
				  and tc.TABLE_SCHEMA = @schema
				  )

select @pk_target

declare @merge_sql varchar(max)

set @merge_sql = 'merge into ' + @schema + '.' + @tablename_tgt + ' as t' +
				 ' using ' + @schema + '.' + @tablename_src + ' as s on s.' + @pk_source + ' = t.' + @pk_target +
				 ' when not matched by target ' + 
				           'then insert (' + @cols_target + ')' + 
						   ' values (' + @cols_source + ');'


select @merge_sql


select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE

alter procedure sp_dynamic_merge(@tablename_src varchar(50), @tablename_tgt varchar(50), @schema varchar(20))
as

begin

declare @cols_source varchar(max)

set @cols_source = stuff(
                          (select ', s.' + COLUMN_NAME
						   from information_schema.columns 
						   where table_name = @tablename_src 
						   and TABLE_SCHEMA = @schema
						   for xml path('')
						    ) 
						  , 1, 1, ''
						  )

declare @cols_target varchar(max)

set @cols_target = stuff(
                          (select ', ' + COLUMN_NAME
						   from INFORMATION_SCHEMA.COLUMNS
						   where table_name = @tablename_tgt
						   and TABLE_SCHEMA = @schema
						   for xml path('')
						    )
                          , 1, 1, '' 
                          )

declare @pk_source varchar(100)

set @pk_source = (
					select cu.COLUMN_NAME
					from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
					inner join INFORMATION_SCHEMA.KEY_COLUMN_USAGE cu on tc.CONSTRAINT_NAME = cu.CONSTRAINT_NAME
					where tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
					and tc.TABLE_NAME = @tablename_src
					and tc.TABLE_SCHEMA = @schema
					)

declare @pk_target varchar(100)

set @pk_target = (
                  select cu.column_name
				  from INFORMATION_SCHEMA.TABLE_CONSTRAINTS as tc
				  inner join INFORMATION_SCHEMA.KEY_COLUMN_USAGE as cu on tc.CONSTRAINT_NAME = cu.constraint_name
				  where tc.CONSTRAINT_type = 'PRIMARY KEY'
				  and tc.TABLE_NAME = @tablename_tgt
				  and tc.TABLE_SCHEMA = @schema
				  )

declare @merge_sql varchar(max)

set @merge_sql = 'merge into ' + @schema + '.' + @tablename_tgt + ' as t' +
				 ' using ' + @schema + '.' + @tablename_src + ' as s on s.' + @pk_source + ' = t.' + @pk_target +
				 ' when not matched by target ' + 
				           'then insert (' + @cols_target + ')' + 
						   ' values (' + @cols_source + ');'


exec (@merge_sql)

end

exec sp_dynamic_merge 'orders_source', 'orders_target', 'sales'

/*
TRIGGER
-obiect fizic pe baza de date
-DML -> actioneaza la insert/update/delete
-DDL -> actioneaza la create/alter/drop

Trigger DML:
-after/for -> actioneaza dupa ce a fost efectuata operatiunea
-instead of -> actioneaza inainte sa aiba loc operatiunea pe o tabela; folositi atunci cand se doreste protejarea datelor dintr-o tabela
*/

/*
Ex. Sa se creeze o copie a tabelei Production.Products cu numele Production.ProductsTG1. 
Aceasta tabela stocheaza produsele si preturile aferente. 
In cazul in care, are loc o modificare de pret, atunci sa se stocheze intr-o tabela noua (Production.ProductsAudit): 
-produsul, 
-pretul vechi, 
-pretul nou, 
-data modificarii pretului.
*/

--Pas1: Crearea tabelei Production.ProductsTG1
select * 
into Production.ProductsTG1
from Production.Products

select * from Production.ProductsTG1

--Pas2: Creare tabela auditare

create table Production.ProductsAudit
(
productid int,
old_price money,
new_price money,
change_date datetime
)

--Pas3: Definire trigger

create trigger tg_productprice on production.productstg1
for update 
as 
insert into production.productsaudit (productid, old_price, new_price, change_date)
select p.productid, d.unitprice as old_price, p.unitprice as new_price, getdate() as change_date
from production.productstg1 p
inner join deleted d on p.productid = d.productid

update Production.ProductsTg1
set unitprice = 200
where productid = 1

select * from production.productsaudit

/*
Sa se construiasca o tabela copie pentru tabela sales.orders cu urmatoarele coloane: orderid, orderdate, freight. 
Tabela se va actualiza zilnic doar prin insert. 
Pentru auditarea tabelei, se solicita un trigger care sa pastreze zilnic numarul de inserturi in aceasta tabela.
*/

--Pas1: creare tabela copie

create table sales.ordercopy
(
orderid int,
orderdate date,
freight money
)

create table sales.ordersaudit
(
reportingdate date,
norows int
)

--Pas2: creare trigger
create trigger tg_orderscopy on sales.ordercopy 
for insert
as

insert into sales.ordersaudit (reportingdate, norows)
select cast(getdate() as date) as reportingdate,
count(*) as norows
from sales.ordercopy oc
inner join inserted i on i.orderid = oc.orderid
--group by cast(getdate() as date) 

--Pas3: testare functionalitate trigger
insert into sales.ordercopy (orderid, orderdate, freight)
select orderid, orderdate, freight
from sales.Orders

select * from sales.ordersaudit

/*
PROIECT: Import informatii din sursa, actualizare tabela target si auditarea actiunilor pe tabela target.
Avem urmatorul scenariu de development:
- In fiecare noapte se transfera date de la surse catre datawarehouse
- Echipa de datawarehouse preia datele de la sursa si le propaga in tabelele pentru raportare din baza de date, astfel incat, este necesar sa se stie:
o Care sunt clientii modificati
o Ce s-a modificat
o Cand s-a modificat
Solutie:
- Analistul Tehnic trebuie sa stie cum vin datele din sursa: full sau delta, care este coloana sau coloanele din cheia primara, 
care sunt coloanele care se modifica si care nu se modifica, daca din sursa se pot sterge date sau nu. In functie de aceste raspunsuri se demareaza implementarea tehnica de catre developer.
- Developerul:
o va creea o procedura stocata care va rula in fiecare noapte, dupa ce sursele trimit date in dwh. Procedura va incarca datele in tabelele target.
o Procedura va face MERGE pentru a actualiza datele in dwh si pentru a pastra istoricul: Valid_From, Valid_To
o Mai este necesara o procedura care sa auditeze load-ul in dwh:
▪ Cate randuri au fost inserate si cate modificate.


Pentru exemplificare:
- Sa se creeze 2 copii (ambele goale) pentru tabela Sales.Customers cu numele Sales.CustTest1 si Sales.CustTest2 cu urmatoarele coloane: 
custid, companyname, country. Tabela Sales.CustTest2 va contine in plus si urmatoarele coloane: Valid_From, Valid_To. 
PK pentru Sales.CustTest1 va fi custid, iar PK pentru Sales.CustTest2 va fi Custid si Valid_from.
- In tabela Sales.CustTest1 (este tabela sursa si vine delta: clientii noi sau modifcati clientii vechi) se vor insera urmatorii clienti:
o 1001, Test1, Romania
o 1001, Test2, Romania
- Se va creea o procedura stocata care va gestiona MERGE Statement pentru transfer de date de la Sales.CustTest1 catre Sales.CustTest2 astfel:
o Inserturi noi
o Modificari cu inchidere randuri vechi si insert randuri vechi modificate
- Se vor define 2 tabele suplimentare utilizate pentru auditare: cu inca o procedura stocata se vor pastra modificarile in tabela de modificari, cu un trigger se gestioneaza inserturile:
o Tabela pentru inserturi in Sales.CustTest2, numita Sales.CustTest2Audit
o Tabela pentru update-uri pe Sales.CustTest2
- Se va creea o procedura de auditare care va extrage informatiile din tabelele create suplimentar:
o Tabela pentru inserturi in Sales.CustTest2, numita Sales.CustTest2Audit
o Tabela pentru update-uri pe Sales.CustTest2
- Procedura va extrage un raport cu nr de randuri updata-te pe tabela Sales.CustTest2 si nr de randuri inserate pe tabea Sales.CustTest2.
*/

--Pas1: creare tabele sursa si target
create table sales.custtest1 --sursa
(
custid int not null,
companyname varchar(100),
country varchar(100),
constraint pk_custtest1 primary key (custid)
)

create table sales.custtest2 --target
(
custid int not null,
companyname varchar(100),
country varchar(100),
ValidFrom date not null,
ValidTo date not null,
constraint pk_custtest2 primary key (custid, ValidFrom)
)

--Pas2: procedura merge cu output
create procedure sp_mergecusttest2(@reportingdate date)
as

begin

if object_id('tempdb.dbo.#tbl', 'u') is not null
drop table tempdb.dbo.#tbl

create table #tbl
(
actiontype varchar(100),
custid int
)

declare @ValidTo date
set @ValidTo = dateadd(dd, -1, @reportingdate)

merge into sales.custtest2 as t
using sales.custtest1 as s on s.custid = t.custid and t.ValidTo = '2999-12-31'
when matched and (t.companyname <> s.companyname OR t.country <> s.country)
	then update set t.ValidTo = @ValidTo
when not matched by target
	then insert (custid, companyname, country, ValidFrom, ValidTo)
		 values (s.custid, s.companyname, s.country, @reportingdate, '2999-12-31')

OUTPUT 
	$action as actiontype,
	deleted.custid
	into #tbl;

insert into sales.custtest2 (custid, companyname, country, ValidFrom, ValidTo)
select t.custid, t.companyname, t.country, @reportingdate as ValidFrom, '2999-12-31' as ValidTo
from sales.custtest1 as t
inner join #tbl as tb on tb.custid = t.custid
where tb.actiontype = 'UPDATE'

end

--Creare tabel de auditare pt modificari
create table sales.custtest2audit1
(
custid int,
old_companyname varchar(40),
new_companyname varchar(40),
old_country		varchar(20),
new_country		varchar(20),
changedate		datetime
)

--Creare tabel de audit pt insert-uri
create table sales.custtest2audit2
(
custid int,
companyname varchar(40),
country varchar(20),
changedate datetime
)

--Procedura stocata pt captarea modificarilor
create procedure sp_update_custtest2(@reportingdate date)
as

begin

insert into sales.custtest2audit1 (custid, old_companyname, new_companyname, old_country, new_country, changedate)
select t2.custid,
t2.companyname as old_companyname,
tt2.companyname as new_companyname,
t2.country as old_country,
tt2.country as new_country,
tt2.ValidFrom as changedate
from sales.custtest2 as t2
inner join sales.custtest2 as tt2 on tt2.custid = t2.custid
where tt2.ValidTo = '2999-12-31'
 and t2.ValidTo = dateadd(dd, -1, @reportingdate)

end

--trigger pentru insert-urile noi
create trigger tg_auditcusttest2insert on sales.custtest2 
for insert
as

insert into sales.custtest2audit2 (custid, companyname, country, changedate)
select t.custid, i.companyname, i.country, t.ValidFrom as changedate
from sales.custtest2 t
inner join inserted i on t.custid = i.custid
and i.custid not in (select custid from sales.custtest2 where ValidTo <> '2999-12-31')

--procedura stocata pentru raport
create procedure sp_auditcusttest2 (@reportingdate date)
as

begin

select changedate as ReportingDate,
	   'UPDATE' as ActionType,
	   count(custid) as No_Rows
from sales.custtest2audit1
where changedate = @reportingdate
group by changedate

union all

select changedate as ReportingDate,
	   'INSERT' as ActionType,
	   count(custid) as No_Rows
from sales.custtest2audit2
where changedate = @reportingdate
group by changedate

end