/****** Object:  Table [dbo].[BronzeToSilver]    Script Date: 10/14/2022 12:39:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BronzeToSilver](
	[BronzeDirectory] [varchar](100) NOT NULL,
	[BronzeTableName] [varchar](50) NOT NULL,
	[BronzeTablePrimaryKey] [varchar](50) NOT NULL,
	[SilverDirectory] [varchar](50) NOT NULL,
	[SilverTableName] [varchar](50) NOT NULL,
	[SilverWatermark] [datetime] NULL
) ON [PRIMARY]
GO


