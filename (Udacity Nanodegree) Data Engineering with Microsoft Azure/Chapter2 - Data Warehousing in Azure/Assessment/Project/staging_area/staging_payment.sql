IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'divvyfs_divvyacc22_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [divvyfs_divvyacc22_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://divvyfs@divvyacc22.dfs.core.windows.net', 
		TYPE = HADOOP 
	)
GO

DROP EXTERNAL TABLE dbo.staging_payment
GO 

CREATE EXTERNAL TABLE dbo.staging_payment (
	[PaymentId] bigint,
	[Date] varchar(27),
	[Amount] float,
	[RiderId] bigint
	)
	WITH (
	LOCATION = 'payment.csv',
	DATA_SOURCE = [divvyfs_divvyacc22_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.staging_payment
GO