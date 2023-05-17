use Training_DWH
go

create procedure sp_load_dimCust
as

begin

insert into Training_DWH.dbo.Dim_Customers 
(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax)
select c.custid, c.companyname, c.contactname, c.contacttitle, c.address, c.city, c.region, c.postalcode, c.country, c.phone, c.fax
from Training.Sales.Customers c
left join Training_DWH.dbo.Dim_Customers dc on dc.custid = c.custid
where dc.custid is null 

end

create procedure sp_load_dimProd
as

begin

insert into Training_DWH.dbo.Dim_Products
(productid, productname, supplierid, unitprice, categoryid)
select p.productid, p.productname, p.supplierid, p.unitprice, p.categoryid
from Training.Production.Products p
left join Training_DWH.dbo.Dim_Products dp on dp.productid = p.productid
where dp.productid is null

end

create procedure sp_load_dimShip
as

begin

insert into Training_DWH.dbo.Dim_Shippers
(shipperid, companyname, phone)
select s.shipperid, s.companyname, s.phone 
from Training.Sales.Shippers s
left join Training_DWH.dbo.Dim_Shippers ds on ds.shipperid = s.shipperid
where ds.shipperid is null

end

create procedure sp_load_factOrders
as

begin

insert into Training_DWH.dbo.Fact_Orders
(orderid, dim_date_id, dim_customer_id, dim_products_id, dim_shipper_id, unitprice, qty, discount)
select o.orderid, dd.DateKey, dc.dim_customer_id, dp.dim_product_id, ds.dim_shipper_id, od.unitprice, od.qty, od.discount
from Training.Sales.Orders o
inner join Training.Sales.OrderDetails od on od.orderid = o.orderid
left join Training_DWH.dbo.Dim_Customers dc on dc.custid = o.custid
left join Training_DWH.dbo.DimDate dd on dd.Date = o.orderdate
left join Training_DWH.dbo.Dim_Products dp on dp.productid = od.productid
left join Training_DWH.dbo.Dim_Shippers ds on ds.shipperid = o.shipperid
left join Training_DWH.dbo.Fact_Orders fo on fo.orderid = o.orderid
where fo.orderid is null

end

create procedure sp_load_dimensions
as

begin

exec sp_load_dimCust
exec sp_load_dimProd
exec sp_load_dimShip

end

