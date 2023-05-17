create database Vanzari

use Vanzari
go

create table Articole
(
ProductId int not null,
ProductName Nvarchar(40), 
SupplierId Int, 
CategoryId Int,
Unitprice Decimal(18,2), 
Discontinued bit 
)

alter table Articole 
add constraint pk_prod_id 
primary key (ProductId)

create table Comenzi
(
Orderid Int not null,
ProductId Int not null, 
Unitprice Decimal(18,2), 
Qty Int, 
Discount Decimal(18,2)
)

alter table Comenzi
add constraint pk_order_prod
primary key (Orderid, ProductId)

alter table Comenzi
add constraint fk_prod
FOREIGN KEY(ProductId)
REFERENCES Articole (ProductId)

create table ErrorImportArticole
(
[Flat File Source Error Output Column] varchar(max),
ErrorCode int,
ErrorColumn int
)

select * into Comenzi_not_matched
from Comenzi
where 1 = 2

select * from Articole
select * from ErrorImportArticole
select * from Comenzi
select * from Comenzi_not_matched

