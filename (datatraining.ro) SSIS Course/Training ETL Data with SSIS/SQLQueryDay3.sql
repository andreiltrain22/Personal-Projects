
alter procedure dbo.sp_extract_sales as

begin

select c.categoryname, year(o.orderdate)*100 + month(o.orderdate) as sales_month,
count(distinct o.custid) as distinct_customers,
count(distinct o.orderid) as distinct_orders,
sum((1-discount)*od.unitprice*od.qty) as total_sales,
sum(od.qty) as qty
from Production.Products p
inner join production.Categories c on p.categoryid = c.categoryid
inner join sales.OrderDetails od on od.productid = p.productid
inner join sales.Orders o on o.orderid = od.orderid
group by c.categoryname, year(o.orderdate)*100 + month(o.orderdate)
order by c.categoryname, year(o.orderdate)*100 + month(o.orderdate)

end

select * from sales.OrderDetails

alter procedure sp_raport_comenzi_zilnic as

begin

declare @shipdate datetime
set @shipdate = GETDATE()

select s.companyname as NumeDistribuitor, 
c.companyname as NumeClient, c.custid as IdClient, 
o.orderdate as DataComanda, o.shippeddate as DataLivrare, o.freight as CostTransport, o.orderid as IdComanda,
sum((1-discount)*od.qty*od.unitprice) as Vanzare,
freight/sum((1-discount)*od.qty*od.unitprice)*100 as ProcentComanda
from sales.orders as o
inner join sales.OrderDetails od on od.orderid = o.orderid
inner join sales.Shippers s on s.shipperid = o.shipperid
inner join sales.Customers c on c.custid = o.custid
where o.shippeddate < @shipdate
group by s.companyname, c.companyname, c.custid, o.orderdate, o.shippeddate, o.freight, o.orderid

end

select * from sales.customers

select * into production.products_test
from [Production].[Products]
where 1 = 2

select * into production.products_test_error
from Production.products_test
--where 1 = 2

select distinct min(supplierid) as minsupplierid, max(supplierid) as maxsupplierid,
min(categoryid) as mincategoryid, max(categoryid) as maxcategoryid
from [Production].[Products]
select * from Production.products_test
select * from Production.products_test_error

select * into sales.OrderDetails_test
from sales.OrderDetails
where 1 = 2

select * from [Sales].[OrderDetails]
select * from [Sales].[OrderDetails_test]