use Training_SSIS
go

create table CustomerDailyImport
(
Customer_Id	int not null,
Customer_Name varchar(50) not null,
Import_Date datetime not null
)

select * from CustomerDailyImport

use Training_SSIS
go


create table ImportSales
(
customer_id int null,
sales int null,
month int null
)

truncate table ErrorImportSales
create table ErrorImportSales
(
[Flat File Source Error Output Column] varchar(max),
ErrorCode int,
ErrorColumn int
)

select * from ImportSales
select * from ErrorImportSales
select * from DateImport

select * from relcifimported

create table relciffull
(
customer int not null,
account int not null,
role int not null,
fileDate int not null
)

create procedure dbo.spload_relciffull

as

begin 

select ri.* 
from relcifimported as ri
left join relciffull as rf on rf.customer = ri.customer 
						   and rf.account = ri.account 
						   and rf.role = ri.role 
						   and rf.fileDate = ri.fileDate
where isnull(ri.customer, 999) <> isnull(rf.customer, 999)
OR isnull(ri.account, 999) <> isnull(rf.account, 999)
OR isnull(ri.role, 999) <> isnull(rf.role, 999)
OR isnull(ri.fileDate, 999) <> isnull(rf.fileDate, 999)


end

select * from relcifimported

select * from relciffull

truncate table relciffull

insert into relcifimported
values 
(200, 100, 2, 20200712)

delete from relcifimported where customer = 200 and account = 100 and role = 2 and fileDate = 20200712
delete from relciffull where customer = 200 and account = 100 and role = 2 and fileDate = 20200712

select * from ImportSales

--pornim de la ImportSales
--split into: salesmax >= 1000, salesmin < 1000
--In salesmax, salesmin doar noile inregistrari din sales

select * 
into ImportSalesMax 
from ImportSales 
where sales >= 1000;

select * 
into ImportSalesMin 
from ImportSales 
where sales < 1000;

select * from ImportSales;
select * from ImportSalesMax;
select * from ImportSalesMin;

insert into ImportSales
values 
(3, 1001, 202007),
(4, 1000, 202007),
(5, 999, 202007),
(6, 998, 202007)

create table Raport 
(
[Tara livrare] nvarchar(50),
[An plasare comanda] int,
Incasare decimal(18, 4)
)

select * from Raport