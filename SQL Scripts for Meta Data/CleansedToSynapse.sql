/************************************************************************** 
* Copyright (c) NEAL ANALYTICS LLC 2018
* __________________
* All Rights Reserved.
* 
* NOTICE:  All information contained herein is, and remains the property of 
* Neal Analytics LLC.
* 
* The intellectual and technical concepts contained herein are proprietary to 
* Neal Analytics LLC and may be covered by U.S. and Foreign Patents, patents 
* in process, and are protected by trade secret or copyright law.
* 
* Dissemination of this information or reproduction of this material is 
* strictly forbidden unless prior written permission is obtained from Neal 
* Analytics LLC.
*****************************************************************************/

/****************************************************************************/
CREATE TABLE [dbo].[CleansedToSynapse](
	[PrimaryKey] [varchar](255) NOT NULL,
	[Columns] [varchar](4000) NOT NULL,
	[IncColumnName] [varchar](100) NULL,
	[LoadType] [varchar](30) NULL,
	[DataLakeContainer] [varchar](100) NOT NULL,
	[DataLakeDirectory] [varchar](100) NOT NULL,
	[DataLakeFileName] [varchar](50) NOT NULL,
	[DataLakeConnection] [varchar](50) NOT NULL,
	[DestinationSchemaName] [varchar](50) NOT NULL,
	[DestinationTableName] [varchar](50) NOT NULL,
	[DestinationConnection] [varchar](50) NOT NULL,
	[DimensionType] [tinyint] NOT NULL
)