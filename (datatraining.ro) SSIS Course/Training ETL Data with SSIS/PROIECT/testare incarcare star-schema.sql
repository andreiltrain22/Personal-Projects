
  delete from VanzariCurs.dbo.Produse
  where idprodus=9002

  delete from VanzariCurs.dbo.Furnizori
  where idfurnizor=9999

  delete from VanzariCurs.dbo.Facturi
  where idfactura=6

  delete from VanzariCurs.dbo.Clienti
  where idclient=4000

delete from FactFacturi where idfactura=6
delete from DimClienti where idclient=4000
delete from DimFurnizori where idfurnizor=9999
delete from DimProduse where idprodus=9002


select * from DimClienti
select * from DimFurnizori
select * from DimProduse
select * from FactFacturi