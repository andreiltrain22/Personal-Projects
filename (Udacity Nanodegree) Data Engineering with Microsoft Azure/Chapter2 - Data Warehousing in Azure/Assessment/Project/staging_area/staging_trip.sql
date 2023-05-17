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

CREATE EXTERNAL TABLE dbo.staging_trip (
	[TripId] nvarchar(4000),
	[RideableType] nvarchar(4000),
	[StartTime] varchar(27),
	[EndTime] varchar(27),
	[StartStationId] nvarchar(4000),
	[EndStationId] nvarchar(4000),
	[RiderId] bigint
	)
	WITH (
	LOCATION = 'trip.csv',
	DATA_SOURCE = [divvyfs_divvyacc22_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.staging_trip
GO