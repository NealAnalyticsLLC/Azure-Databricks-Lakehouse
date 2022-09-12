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
CREATE TABLE [dbo].[StagingToCleansed] (
  [ConnectionSecret] [nvarchar](100) NOT NULL,
  [SourceDataLakeContainer] [nvarchar](100) NOT NULL,
  [SourceDataLakeDirectory] [nvarchar](100) NOT NULL,
  [SourceDataLakeFileName] [nvarchar](50) NOT NULL,
  [DestinationDataLakeContainer] [nvarchar](100) NOT NULL,
  [DestinationDataLakeDirectory] [nvarchar](100) NOT NULL,
  [DestinationDataLakeFileName] [nvarchar](50) NOT NULL
)
GO