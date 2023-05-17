truncate table production.products_test
truncate table sales.orderdetails_test

alter procedure sp_get_ProductsReport as

begin

select productname, sum(o.qty) as qty, 
round(sum((1-discount)*o.unitprice*o.qty),2) as Sales
from Production.products_test p
inner join sales.OrderDetails_test as o on o.productid = p.productid
where p.discontinued = 0
group by productname
order by Sales desc, qty desc

end

select * from production.products_test
select * from sales.orderdetails_test

use Training_SSIS
go

ALTER TABLE [Production].[Products_bkp] DROP CONSTRAINT [FK_Products_Categories]
ALTER TABLE [Sales].[OrderDetails_bkp]  DROP CONSTRAINT [FK_OrderDetails_Products]

truncate table [Production].[Categories_bkp]
truncate table [Production].[Products_bkp]
truncate table [Sales].[OrderDetails_bkp]


ALTER TABLE [Production].[Products_bkp]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([categoryid])
REFERENCES [Production].[Categories_bkp] ([categoryid])


ALTER TABLE [Sales].[OrderDetails_bkp]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([productid])
REFERENCES [Production].[Products_bkp] ([productid])

use VanzariCursDWH
go

select * from [dbo].[DimClienti]