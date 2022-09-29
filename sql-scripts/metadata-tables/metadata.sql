CREATE TABLE [dbo].[metadata](
	[SourceContainer] [varchar](100) NOT NULL,
	[DataLakeDirectory] [varchar](100) NOT NULL,
	[DataLakeFileName] [varchar](50) NOT NULL,
	[DestinationContainer] [varchar](100) NOT NULL,
	[DestinationDirectory] [varchar](100) NOT NULL,
	[DestinationFileName] [varchar](50) NOT NULL
)