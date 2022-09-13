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
CREATE TABLE [dbo].[ActivityLogs] (
  [activity_id] nvarchar(36) PRIMARY KEY NOT NULL,
  [activity_name] nvarchar(64) NOT NULL,
  [activity_type] nvarchar(32),	
  [pipeline_id] nvarchar(36) NOT NULL,				
  [pipeline_name] nvarchar(64) NOT NULL,				 				
  [pipeline_run_id] varchar(36) NULL,	
  [trigger_id] nvarchar(36) NULL,
  [event_status] varchar(16) NULL,
  [pipeline_exe_status] varchar(16) NULL,
  [rows_processed] int NULL,
  [started_dttm] datetime NULL,	
  [finished_dttm] datetime NULL,
  [datetime_created] datetime,				
  [datetime_modified] datetime,				
  [updated_by] varchar(32)
)