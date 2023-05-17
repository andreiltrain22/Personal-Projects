--Incarcare dim Clienti

use VanzariCursDWH
go

create procedure sp_loadClienti as

begin

insert into VanzariCursDWH.dbo.DimClienti (idclient, DenumireClient, Locatie)
select c.idclient, nume as DenumireClient, c.locatie 
from VanzariCurs.dbo.Clienti as c
left join VanzariCursDWH.dbo.DimClienti as dc on c.idclient = dc.idclient
where dc.idclient is null

end

create procedure sp_loadFurnizori as

begin

insert into VanzariCursDWH.dbo.DimFurnizori (idfurnizor, DenumireFurnizor, Locatie)
select f.idfurnizor, f.denumire as DenumireFurnizor, f.Locatie
from VanzariCurs.dbo.Furnizori f
left join VanzariCursDWH.dbo.DimFurnizori df on f.idfurnizor = df.idfurnizor
where df.idfurnizor is null

end

alter procedure sp_loadProduse as

begin

insert into VanzariCursDWH.dbo.DimProduse (idprodus, DenumireProdus, stoc, perioadaexprirare, DenumireCategorie)
select p.idprodus, p.denumire as DenumireProdus, p.stoc, p.perioadaexpirare, cp.denumire as DenumireCategorie
from VanzariCurs.dbo.Produse p
inner join VanzariCurs.dbo.Categ_Produse cp on p.categorieprodus = cp.idcategorie
left join VanzariCursDWH.dbo.DimProduse dp on dp.idprodus = p.idprodus
where dp.idprodus is null

end

create procedure sp_loadfactFacturi as

begin

insert into VanzariCursDWH.dbo.FactFacturi (idfactura, ProdusKey, ClientKey, FurnizorKey, DateKey, Cantitate, Pret)
select f.idfactura, dp.ProdusKey, dc.ClientKey, df.FurnizorKey, dd.DateKey, f.cantitate, f.pret
from VanzariCurs.dbo.Facturi f
left join VanzariCursDWH.dbo.FactFacturi ff on ff.idfactura = f.idfactura
left join VanzariCursDWH.dbo.DimProduse dp on dp.idprodus = f.idprodus
left join VanzariCursDWH.dbo.DimClienti dc on dc.idclient = f.idclient
left join VanzariCurs.dbo.Produse p on p.idprodus = dp.idprodus
left join VanzariCursDWH.dbo.DimFurnizori df on df.idfurnizor = p.idfurnizor
left join VanzariCursDWH.dbo.dimDate dd on dd.Date = f.datafactura
where ff.idfactura is null

end

exec dbo.sp_loadClienti
exec dbo.sp_loadFurnizori
exec dbo.sp_loadProduse
exec dbo.sp_loadfactFacturi

create table AuditTbl 
(
Denumire varchar(20),
ImportDate date
)

insert into AuditTbl
values ('Proiect', '2019-11-20')

select convert(varchar(8), ImportDate, 112)
from AuditTbl
where Denumire = 'Proiect'

update AuditTbl
set ImportDate = DATEADD(dd, 1, ImportDate)
where Denumire = 'Proiect'