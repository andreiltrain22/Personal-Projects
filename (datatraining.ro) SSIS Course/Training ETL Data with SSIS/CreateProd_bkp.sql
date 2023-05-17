USE [Training_SSIS]
GO

/****** Object:  Table [Production].[Products]    Script Date: 15.07.2020 16:28:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE [Production].[Products_bkp]

CREATE TABLE [Production].[Products_bkp](
	[productid] [int] IDENTITY(1,1) NOT NULL,
	[productname] [nvarchar](40) NOT NULL,
	[supplierid] [int] NOT NULL,
	[categoryid] [int] NOT NULL,
	[unitprice] [money] NOT NULL,
	[discontinued] [bit] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[productid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [Production].[Products_bkp] ADD  CONSTRAINT [DFT_Products_unitprice]  DEFAULT ((0)) FOR [unitprice]
GO

ALTER TABLE [Production].[Products_bkp] ADD  CONSTRAINT [DFT_Products_discontinued]  DEFAULT ((0)) FOR [discontinued]
GO

ALTER TABLE [Production].[Products_bkp]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([categoryid])
REFERENCES [Production].[Categories_bkp] ([categoryid])
GO

ALTER TABLE [Production].[Products_bkp] CHECK CONSTRAINT [FK_Products_Categories]
GO

ALTER TABLE [Production].[Products_bkp]  WITH CHECK ADD  CONSTRAINT [CHK_Products_unitprice] CHECK  (([unitprice]>=(0)))
GO

ALTER TABLE [Production].[Products_bkp] CHECK CONSTRAINT [CHK_Products_unitprice]
GO


