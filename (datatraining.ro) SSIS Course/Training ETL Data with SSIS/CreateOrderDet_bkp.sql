USE [Training_SSIS]
GO

/****** Object:  Table [Sales].[OrderDetails_bkp]    Script Date: 15.07.2020 16:29:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--CREATE SCHEMA Sales

DROP TABLE [Sales].[OrderDetails_bkp]

CREATE TABLE [Sales].[OrderDetails_bkp](
	[orderid] [int] NOT NULL,
	[productid] [int] NOT NULL,
	[unitprice] [money] NOT NULL,
	[qty] [smallint] NOT NULL,
	[discount] [numeric](4, 3) NOT NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[orderid] ASC,
	[productid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [Sales].[OrderDetails_bkp] ADD  CONSTRAINT [DFT_OrderDetails_unitprice]  DEFAULT ((0)) FOR [unitprice]
GO

ALTER TABLE [Sales].[OrderDetails_bkp] ADD  CONSTRAINT [DFT_OrderDetails_qty]  DEFAULT ((1)) FOR [qty]
GO

ALTER TABLE [Sales].[OrderDetails_bkp] ADD  CONSTRAINT [DFT_OrderDetails_discount]  DEFAULT ((0)) FOR [discount]
GO

ALTER TABLE [Sales].[OrderDetails_bkp]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([productid])
REFERENCES [Production].[Products_bkp] ([productid])
GO

ALTER TABLE [Sales].[OrderDetails_bkp] CHECK CONSTRAINT [FK_OrderDetails_Products]
GO

ALTER TABLE [Sales].[OrderDetails_bkp]  WITH CHECK ADD  CONSTRAINT [CHK_discount] CHECK  (([discount]>=(0) AND [discount]<=(1)))
GO

ALTER TABLE [Sales].[OrderDetails_bkp] CHECK CONSTRAINT [CHK_discount]
GO

ALTER TABLE [Sales].[OrderDetails_bkp]  WITH CHECK ADD  CONSTRAINT [CHK_qty] CHECK  (([qty]>(0)))
GO

ALTER TABLE [Sales].[OrderDetails_bkp] CHECK CONSTRAINT [CHK_qty]
GO

ALTER TABLE [Sales].[OrderDetails_bkp]  WITH CHECK ADD  CONSTRAINT [CHK_unitprice] CHECK  (([unitprice]>=(0)))
GO

ALTER TABLE [Sales].[OrderDetails_bkp] CHECK CONSTRAINT [CHK_unitprice]
GO


