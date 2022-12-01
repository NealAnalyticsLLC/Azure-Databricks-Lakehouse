/****** Object:  Table [dbo].[RawToBronze]    Script Date: 10/14/2022 12:40:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RawToBronze](
	[RawDirectory] [varchar](100) NOT NULL,
	[RawTableName] [varchar](50) NOT NULL,
	[RawTableFormat] [varchar](50) NOT NULL,
	[RawTablePrimaryKey] [varchar](50) NOT NULL,
	[BronzeDirectory] [varchar](50) NOT NULL,
	[BronzeTableName] [varchar](50) NOT NULL,
	[BronzeWatermark] [datetime] NULL
) ON [PRIMARY]
GO


