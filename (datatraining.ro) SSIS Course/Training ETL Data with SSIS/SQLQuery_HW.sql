ALTER TABLE [Production].[Products_bkp] DROP CONSTRAINT [FK_Products_Categories]
ALTER TABLE [Sales].[OrderDetails_bkp]  DROP CONSTRAINT [FK_OrderDetails_Products]

truncate table [Production].[Categories_bkp]
truncate table [Production].[Products_bkp]
truncate table [Sales].[OrderDetails_bkp]


ALTER TABLE [Production].[Products_bkp]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([categoryid])
REFERENCES [Production].[Categories_bkp] ([categoryid])


ALTER TABLE [Sales].[OrderDetails_bkp]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([productid])
REFERENCES [Production].[Products_bkp] ([productid])
