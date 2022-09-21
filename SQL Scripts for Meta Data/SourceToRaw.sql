CREATE TABLE [dbo].[SourceToRaw](
	[ServerName] [varchar](50) NOT NULL,
	[DatabaseName] [varchar](50) NOT NULL,
	[SchemaName] [varchar](50) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[Query] [varchar](8000) NOT NULL,
	[ConnectionSecret] [varchar](100) NOT NULL,
	[DataLakeContainer] [varchar](100) NOT NULL,
	[DataLakeDirectory] [varchar](100) NOT NULL,
	[DataLakeFileName] [varchar](50) NOT NULL,
	
) ON [PRIMARY]
