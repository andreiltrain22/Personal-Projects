--Raport utilizand procedura stocata: Sa se determine toate comenzile clientului 53 din anul 2008.

use Training 
GO

select custid, orderid, orderdate, shippeddate
from sales.orders a
where custid = 53
and orderdate between '2008-01-01' and '2008-12-31'

--Se cere din nou raportul, dar pt custid = 37, vanzari pe 2007

select custid, orderid, orderdate, shippeddate
from sales.orders a
where custid = 37
and orderdate between '2007-01-01' and '2007-12-31'

create procedure sp_getorders(@custid int, @startdate date, @enddate date)
as

begin

select custid, orderid, orderdate, shippeddate
from sales.orders a
where custid = @custid
and orderdate between @startdate and @enddate

end

exec sp_getorders 37, '2007-01-01', '2007-12-31'

--Sa se construiasca o procedura stocata care sa determina lista comenzilor plasate de un anumit client intr-o perioada. 
--In cazul in care se omite perioada sau se doreste afisarea tuturor comenzilor unui client, atunci perioada sa nu fie nevoie sa fie completata.

if object_id('sp_getorders', 'P') is not null
drop procedure sp_getorders
GO

create procedure sp_getorders(@custid int, @startdate date = '1900-01-01', @enddate date = '2999-12-31')
as

begin

select custid, orderid, orderdate, shippeddate
from sales.orders a
where custid = @custid
and orderdate between @startdate and @enddate

end

exec sp_getorders 37

select custid, companyname, address, c.country. c.city, c.phone 
from sales.Customers c

select e.firstname + ' ' + e.lastname + ', ' + title, e.hiredate, e.address, o.orderdate
from hr.Employees e
inner join sales.orders o on o.empid = e.empid

create procedure sp_getemporders
as

begin

select e.firstname + ' ' + e.lastname as fullname, o.orderdate, o.shipaddress
from hr.Employees e
inner join sales.Orders o on o.empid = e.empid

end
