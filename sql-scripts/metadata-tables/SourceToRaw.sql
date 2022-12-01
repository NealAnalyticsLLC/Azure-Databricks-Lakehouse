/****** Object:  Table [dbo].[SourceToRaw]    Script Date: 10/14/2022 12:40:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SourceToRaw](
	[DatabaseName] [varchar](50) NOT NULL,
	[SchemaName] [varchar](50) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[Delta_Column] [varchar](50) NOT NULL
	[Query] [varchar](8000) NOT NULL,
	[ConnectionSecret] [varchar](100) NOT NULL,
	[DataLakeContainer] [varchar](100) NOT NULL,
	[DataLakeDirectory] [varchar](100) NOT NULL,
	[DataLakeFileName] [varchar](50) NOT NULL,
	[RawWatermark] [datetime] NULL,
	
) ON [PRIMARY]
GO


