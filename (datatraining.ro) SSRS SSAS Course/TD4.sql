create table dim_categories
(
dim_categoryid int identity(1, 1) not null,
categoryid int not null,
categoryname nvarchar(15) not null,
description nvarchar(200) not null,
constraint pk_dim_categories primary key (dim_categoryid)
)

--creare procedura stocata de populare dim_categories
use Training_DWH
go

create procedure dbo.sp_load_dimctg
as

begin

	insert into Training_DWH.dbo.dim_categories
	(categoryid, categoryname, description)
	select c.categoryid, c.categoryname, c.description
	from Training.Production.Categories c
	left join Training.dbo.dim_categories dc on dc.categoryid = c.categoryid
	where dc.categoryid is null  

end

--modific dim_products -> adaug coloana = Ctgid
alter table dim_products 
add dim_categoryid int  

--populare coloana cu date
update dp
set dp.dim_categoryid = dc.dim_categoryid
from dbo.dim_products as dp
inner join dbo.dim_categories as dc on dp.categoryid = dc.categoryid

alter table dim_products 
drop column categoryid

alter table dbo.dim_products
add constraint FK_dim_products foreign key (dim_categoryid) references dim_categories(dim_categoryid)