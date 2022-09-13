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
