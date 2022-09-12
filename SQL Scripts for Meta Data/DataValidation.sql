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
CREATE  TABLE [dbo].[DataValidation](
	[Id] [int] NOT NULL,
	[DataSource] [varchar](50) NOT NULL,
	[ValidationRule] [nvarchar](1000) NULL,
	[ValidationCondition] [nvarchar](4000) NULL,
	[ColumnName] [varchar](200) NULL,
	[FileName] [varchar](100) NULL,
	[DirectoryName] [varchar](100) NULL,
	[ContainerName] [varchar](50) NULL,
	[TableName] [varchar](50) NULL
) ON [PRIMARY]
GO