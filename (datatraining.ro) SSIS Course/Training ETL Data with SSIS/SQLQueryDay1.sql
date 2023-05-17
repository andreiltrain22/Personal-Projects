create table Imobiliare
(
IdAnunt varchar(50) not null,
TipApartament int not null,
Localitate varchar(50),
Pret decimal(18,4),
AnConstructie int,
Confort varchar(50),
Status varchar(50),
Comision decimal(18,4),
LunaAnunt varchar(50) 
)

alter table Imobiliare
add constraint PK_ID primary key(IdAnunt)

select * from Imobiliare

exec sp_rename 'Clienti', 'DateAngajati'

drop table DateImport
create table DateImport
(
id_producator bigint not null,
id_articol bigint not null,
id_magazin bigint not null,
magazin varchar(50),
grupa_client varchar(50),
vanzari_2011 decimal(18,4),
cantitate_2011 decimal(18,4),
vanzari_2012 decimal(18,4),
cantitate_2012 decimal(18,4)
)

alter table DateImport 
add constraint PK_ProdArtMgz 
primary key(id_producator, id_articol, id_magazin)

alter table DateImport 
drop constraint PK_ProdArtMgz

select * from DateImport;

create table relcifimported
(
customer int not null,
account int not null,
role int not null,
fileDate int not null
)

if exists 
(
select top 1 * 
from Training_SSIS.dbo.relcifimported
)
select cast(max(fileDate) + 1 as varchar(15))
from Training_SSIS.dbo.relcifimported
else
select 20150701

select * from relcifimported;
truncate table relcifimported

drop table tx_import
create table tx_import
(
TransactionId int not null,
TransactionDate	date,
TransactionAmount decimal(18, 4),	
Customer_Id int not null
)

if exists 
(
select top 1 * 
from Training_SSIS.dbo.tx_import
)
select cast(
			substring(cast(TransactionDate as varchar(15)), 1, 4) + 
			substring(cast(TransactionDate as varchar(15)), 9, 2) + 
			substring(cast(TransactionDate as varchar(15)), 6, 2) 
			as int
			) + 1
from Training_SSIS.dbo.tx_import
else
select 20160312

select * from tx_import

select  
from Training_SSIS.dbo.tx_import