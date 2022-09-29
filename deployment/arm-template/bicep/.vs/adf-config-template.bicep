param project_name string
param factoryName string = 'adf-${project_name}-dev'
param AzureKeyVault_properties_typeProperties_baseUrl string = 'https://kv-${project_name}-dev.vault.azure.net/'
param sqldb_connection_secret string
param ADLS2_properties_typeProperties_url string = 'https://adls${project_name}dev.dfs.core.windows.net'
param SQLServer_properties_typeProperties_connectionString_secretName string = 'OnPremSQLConnection'
param sqldw_connection_secret string
param sqldwmasterDB_connection_secret string
param adlskey_secret string
//var factoryId = 'Microsoft.DataFactory/factories/${factoryName}'

resource factoryName_DS_SQL 'Microsoft.DataFactory/factories/datasets@2018-06-01'= {
  name: '${factoryName}/DS_SQL'
  properties: {
    linkedServiceName: {
      referenceName: 'SQLServer'
      type: 'LinkedServiceReference'
    }
    parameters: {
      TableName: {
        type: 'String'
      }
    }
    annotations: []
    type: 'SqlServerTable'
    schema: []
    typeProperties: {}
  }
  dependsOn: [
    
  ]
}

resource factoryName_DS_Parquet_Raw 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${factoryName}/DS_Parquet_Raw'
  properties: {
    linkedServiceName: {
      referenceName: 'ADLS2'
      type: 'LinkedServiceReference'
    }
    parameters: {
      ADLSDirectory: {
        type: 'String'
      }
      Filename: {
        type: 'String'
      }
    }
    annotations: []
    type: 'Parquet'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@dataset().Filename'
          type: 'Expression'
        }
        folderPath: {
          value: '@dataset().ADLSDirectory'
          type: 'Expression'
        }
        fileSystem: 'raw'
      }
      compressionCodec: 'snappy'
    }
    schema: []
  }
  dependsOn: [
  ]
}

resource factoryName_DS_Parquet_Staging 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${factoryName}/DS_Parquet_Staging'
  properties: {
    linkedServiceName: {
      referenceName: 'ADLS2'
      type: 'LinkedServiceReference'
    }
    parameters: {
      ADLSDirectory: {
        type: 'String'
      }
    }
    annotations: []
    type: 'Parquet'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        folderPath: {
          value: '@dataset().ADLSDirectory'
          type: 'Expression'
        }
        fileSystem: 'staging'
      }
      compressionCodec: 'snappy'
    }
    schema: []
  }
  dependsOn: [
  ]
}

resource factoryName_DS_Synapse 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${factoryName}/DS_Synapse'
  properties: {
    linkedServiceName: {
      referenceName: 'Synapse'
      type: 'LinkedServiceReference'
    }
    parameters: {
      TableName: {
        type: 'String'
      }
    }
    annotations: []
    type: 'AzureSqlDWTable'
    schema: []
    typeProperties: {
      schema: 'staging'
      table: {
        value: '@dataset().TableName'
        type: 'Expression'
      }
    }
  }
  dependsOn: [
  ]
}

resource factoryName_DS_AzureSQL 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${factoryName}/DS_AzureSQL'
  properties: {
    linkedServiceName: {
      referenceName: 'AzureSQLDB'
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {}
  }
  dependsOn: [
  ]
}

resource dataFactory_IR 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${factoryName}/${project_name}-IR'
  properties: {
    type: 'SelfHosted'
    typeProperties: {}
  }
  dependsOn: []
}

resource factoryName_AzureKeyVault 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/AzureKeyVault'
  properties: {
    annotations: []
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: AzureKeyVault_properties_typeProperties_baseUrl
    }
  }
  dependsOn: []
}

resource factoryName_AzureSQLDB 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/AzureSQLDB'
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault'
          type: 'LinkedServiceReference'
        }
        secretName: sqldb_connection_secret
        secretVersion: 'eeb65bdefba6492d8bb747c14aad0a48'
      }
    }
  }
  dependsOn: [
  ]
}

resource factoryName_ADLS2 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/ADLS2'
  properties: {
    annotations: []
    type: 'AzureBlobFS'
    typeProperties: {
      url: ADLS2_properties_typeProperties_url
      accountKey: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault'
          type: 'LinkedServiceReference'
        }
        secretName: 'ADLSKey'
      }
    }
  }
  dependsOn: [
  ]
}

resource factoryName_SQLServer 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/SQLServer'
  properties: {
    annotations: []
    type: 'SqlServer'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault'
          type: 'LinkedServiceReference'
        }
        secretName: SQLServer_properties_typeProperties_connectionString_secretName
      }
    }
    connectVia: {
      referenceName: '${project_name}-IR'
      type: 'IntegrationRuntimeReference'
    }
  }
  dependsOn: [
  ]
}

resource factoryName_Synapse 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/Synapse'
  properties: {
    annotations: []
    type: 'AzureSqlDW'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault'
          type: 'LinkedServiceReference'
        }
        secretName: sqldw_connection_secret
      }
    }
  }
  dependsOn: [
  ]
}

resource factoryName_SynapseMasterDB 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  name: '${factoryName}/SynapseMasterDB'
  properties: {
    annotations: []
    type: 'AzureSqlDW'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: 'AzureKeyVault'
          type: 'LinkedServiceReference'
        }
        secretName: sqldwmasterDB_connection_secret
        secretVersion: 'dccd85b2f397437eb48728c615dbe204'
      }
    }
  }
  dependsOn: [
  ]
}

resource factoryName_PL_Load_Into_DimFact 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${factoryName}/PL_Load_Into_DimFact'
  properties: {
    activities: [
      {
        name: 'Store Data in Dim Tables'
        type: 'SqlServerStoredProcedure'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          storedProcedureName: '[dbo].[InsertIntoDimTables]'
        }
        linkedServiceName: {
          referenceName: 'Synapse'
          type: 'LinkedServiceReference'
        }
      }
      {
        name: 'Store Data into Fact Tables'
        type: 'SqlServerStoredProcedure'
        dependsOn: [
          {
            activity: 'Store Data in Dim Tables'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          storedProcedureName: '[dbo].[sp_fact_ProductSalesOrder]'
        }
        linkedServiceName: {
          referenceName: 'Synapse'
          type: 'LinkedServiceReference'
        }
      }
      {
        name: 'Store logs in DB After Completion'
        type: 'SqlServerStoredProcedure'
        dependsOn: [
          {
            activity: 'Store Data into Fact Tables'
            dependencyConditions: [
              'Completed'
            ]
          }
        ]
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          storedProcedureName: '[dbo].[sp_StoreActivityLogs]'
          storedProcedureParameters: {
            activity_id: {
              value: '0'
              type: 'String'
            }
            data_object_name: {
              value: 'not required'
              type: 'String'
            }
            event_name: {
              value: ''
              type: 'String'
            }
            event_status: {
              value: 'not required'
              type: 'String'
            }
            event_value: {
              value: ''
              type: 'String'
            }
            finished_dttm: {
              value: ''
              type: 'String'
            }
            isCompleted: {
              value: 'true'
              type: 'Boolean'
            }
            isNew: {
              value: 'false'
              type: 'Boolean'
            }
            pipeline_exe_status: {
              value: 'Succeeded'
              type: 'String'
            }
            pipeline_id: {
              value: '0'
              type: 'Int32'
            }
            pipeline_run_id: {
              value: {
                value: '@pipeline()?.TriggeredByPipelineRunId'
                type: 'Expression'
              }
              type: 'String'
            }
            rows_processed: {
              value: '0'
              type: 'Int32'
            }
            started_dttm: {
              value: {
                value: '@pipeline().TriggerTime'
                type: 'Expression'
              }
              type: 'DateTime'
            }
            trigger_id: {
              value: {
                value: '@pipeline().TriggerId'
                type: 'Expression'
              }
              type: 'String'
            }
          }
        }
        linkedServiceName: {
          referenceName: 'AzureSQLDB'
          type: 'LinkedServiceReference'
        }
      }
    ]
    policy: {
      elapsedTimeMetric: {}
      cancelAfter: {}
    }
    annotations: []
    lastPublishTime: '2022-07-27T04:44:28Z'
  }
  dependsOn: [
  ]
}

resource factoryName_PL_SQL_Source_To_Synapse 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${factoryName}/PL_SQL_Source_To_Synapse'
  properties: {
    activities: [
      {
        name: 'ForEach SQL Table'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Get Data Object Parameters'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Get Data Object Parameters\').output.value'
            type: 'Expression'
          }
          activities: [
            {
              name: 'Copy SQL Data to ADLS'
              type: 'Copy'
              dependsOn: []
              policy: {
                timeout: '7.00:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'SqlServerSource'
                  sqlReaderQuery: {
                    value: '@concat(item().query, \' \', item().where)'
                    type: 'Expression'
                  }
                  queryTimeout: '02:00:00'
                  partitionOption: 'None'
                }
                sink: {
                  type: 'ParquetSink'
                  storeSettings: {
                    type: 'AzureBlobFSWriteSettings'
                  }
                  formatSettings: {
                    type: 'ParquetWriteSettings'
                  }
                }
                enableStaging: false
                translator: {
                  type: 'TabularTranslator'
                  typeConversion: true
                  typeConversionSettings: {
                    allowDataTruncation: true
                    treatBooleanAsNumber: false
                  }
                }
              }
              inputs: [
                {
                  referenceName: 'DS_SQL'
                  type: 'DatasetReference'
                  parameters: {
                    TableName: {
                      value: '@concat(item().ing_schema_name,\'.\',item().ing_table_name)'
                      type: 'Expression'
                    }
                  }
                }
              ]
              outputs: [
                {
                  referenceName: 'DS_Parquet_Raw'
                  type: 'DatasetReference'
                  parameters: {
                    ADLSDirectory: {
                      value: '@pipeline().parameters.ADLSDirectory'
                      type: 'Expression'
                    }
                    Filename: {
                      value: '@item().Sink_file_name'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            {
              name: 'Store logs in DB'
              type: 'SqlServerStoredProcedure'
              dependsOn: [
                {
                  activity: 'Copy SQL Data to ADLS'
                  dependencyConditions: [
                    'Completed'
                  ]
                }
              ]
              policy: {
                timeout: '7.00:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                storedProcedureName: '[dbo].[sp_StoreActivityLogs]'
                storedProcedureParameters: {
                  activity_id: {
                    value: {
                      value: '@item().activity_id'
                      type: 'Expression'
                    }
                    type: 'String'
                  }
                  data_object_name: {
                    value: {
                      value: '@item().table_name'
                      type: 'Expression'
                    }
                    type: 'String'
                  }
                  event_name: {
                    value: ''
                    type: 'String'
                  }
                  event_status: {
                    value: {
                      value: '@activity(\'Copy SQL Data to ADLS\').output.executionDetails[0].status'
                      type: 'Expression'
                    }
                    type: 'String'
                  }
                  event_value: {
                    value: ''
                    type: 'String'
                  }
                  finished_dttm: {
                    value: ''
                    type: 'String'
                  }
                  isCompleted: {
                    value: 'false'
                    type: 'Boolean'
                  }
                  isNew: {
                    value: 'true'
                    type: 'Boolean'
                  }
                  pipeline_exe_status: {
                    value: ''
                    type: 'String'
                  }
                  pipeline_id: {
                    value: {
                      value: '@item().pipeline_id'
                      type: 'Expression'
                    }
                    type: 'Int32'
                  }
                  pipeline_run_id: {
                    value: {
                      value: '@pipeline()?.TriggeredByPipelineRunId'
                      type: 'Expression'
                    }
                    type: 'String'
                  }
                  rows_processed: {
                    value: {
                      value: '@activity(\'Copy SQL Data to ADLS\').output.rowsCopied'
                      type: 'Expression'
                    }
                    type: 'Int32'
                  }
                  started_dttm: {
                    value: {
                      value: '@pipeline().TriggerTime'
                      type: 'Expression'
                    }
                    type: 'DateTime'
                  }
                  trigger_id: {
                    value: {
                      value: '@pipeline().TriggerId'
                      type: 'Expression'
                    }
                    type: 'String'
                  }
                }
              }
              linkedServiceName: {
                referenceName: 'AzureSQLDB'
                type: 'LinkedServiceReference'
              }
            }
          ]
        }
      }
      {
        name: 'Copy Data From Raw to Staging'
        description: 'Copy Data From Raw to Staging Container'
        type: 'Copy'
        dependsOn: [
          {
            activity: 'ForEach SQL Table'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'ParquetSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: true
              wildcardFolderPath: {
                value: '@pipeline().parameters.ADLSDirectory'
                type: 'Expression'
              }
              wildcardFileName: '*.parquet'
              enablePartitionDiscovery: false
            }
          }
          sink: {
            type: 'ParquetSink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
              copyBehavior: 'PreserveHierarchy'
            }
            formatSettings: {
              type: 'ParquetWriteSettings'
            }
          }
          enableStaging: false
          translator: {
            type: 'TabularTranslator'
            typeConversion: true
            typeConversionSettings: {
              allowDataTruncation: true
              treatBooleanAsNumber: false
            }
          }
        }
        inputs: [
          {
            referenceName: 'DS_Parquet_Raw'
            type: 'DatasetReference'
            parameters: {
              ADLSDirectory: {
                value: '@pipeline().parameters.ADLSDirectory'
                type: 'Expression'
              }
              Filename: 'MentionedInWildCard'
            }
          }
        ]
        outputs: [
          {
            referenceName: 'DS_Parquet_Staging'
            type: 'DatasetReference'
            parameters: {
              ADLSDirectory: {
                value: '@pipeline().parameters.ADLSDirectory'
                type: 'Expression'
              }
            }
          }
        ]
      }
      {
        name: 'Get Data Object Parameters'
        type: 'Lookup'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'AzureSqlSource'
            sqlReaderStoredProcedureName: '[dbo].[sp_GetDataObjectParameters]'
            storedProcedureParameters: {
              pipeline_name: {
                type: 'String'
                value: {
                  value: '@pipeline().Pipeline'
                  type: 'Expression'
                }
              }
            }
            queryTimeout: '02:00:00'
            partitionOption: 'None'
          }
          dataset: {
            referenceName: 'DS_AzureSQL'
            type: 'DatasetReference'
            parameters: {}
          }
          firstRowOnly: false
        }
      }
      {
        name: 'Copy data to Cultivated tables'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Copy Data From Raw to Staging'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Get Data Object Parameters\').output.value'
            type: 'Expression'
          }
          activities: [
            {
              name: 'Copy data to Staging tables'
              type: 'Copy'
              dependsOn: []
              policy: {
                timeout: '7.00:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'ParquetSource'
                  storeSettings: {
                    type: 'AzureBlobFSReadSettings'
                    recursive: true
                    wildcardFolderPath: {
                      value: '@pipeline().parameters.ADLSDirectory'
                      type: 'Expression'
                    }
                    wildcardFileName: {
                      value: '@item().Sink_file_name'
                      type: 'Expression'
                    }
                    enablePartitionDiscovery: false
                  }
                }
                sink: {
                  type: 'SqlDWSink'
                  preCopyScript: {
                    value: '@{concat(\'TRUNCATE TABLE staging.\',item().table_name)}'
                    type: 'Expression'
                  }
                  writeBehavior: 'Insert'
                  sqlWriterUseTableLock: false
                  disableMetricsCollection: false
                }
                enableStaging: false
                translator: {
                  type: 'TabularTranslator'
                  typeConversion: true
                  typeConversionSettings: {
                    allowDataTruncation: true
                    treatBooleanAsNumber: false
                  }
                }
              }
              inputs: [
                {
                  referenceName: 'DS_Parquet_Staging'
                  type: 'DatasetReference'
                  parameters: {
                    ADLSDirectory: {
                      value: '@pipeline().parameters.ADLSDirectory'
                      type: 'Expression'
                    }
                  }
                }
              ]
              outputs: [
                {
                  referenceName: 'DS_Synapse'
                  type: 'DatasetReference'
                  parameters: {
                    TableName: {
                      value: '@item().table_name'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            {
              name: 'Store data in Cultivated tables'
              type: 'SqlServerStoredProcedure'
              dependsOn: [
                {
                  activity: 'Copy data to Staging tables'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              policy: {
                timeout: '7.00:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                storedProcedureName: {
                  value: '@item().sp_name'
                  type: 'Expression'
                }
              }
              linkedServiceName: {
                referenceName: 'Synapse'
                type: 'LinkedServiceReference'
              }
            }
          ]
        }
      }
    ]
    policy: {
      elapsedTimeMetric: {}
      cancelAfter: {}
    }
    parameters: {
      ADLSDirectory: {
        type: 'String'
      }
    }
    annotations: []
    lastPublishTime: '2022-07-27T02:47:54Z'
  }
  dependsOn: [
  ]
}

resource factoryName_PL_SQL_Master 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${factoryName}/PL_SQL_Master'
  properties: {
    activities: [
      {
        name: 'Source to Synapse'
        type: 'ExecutePipeline'
        dependsOn: []
        userProperties: []
        typeProperties: {
          pipeline: {
            referenceName: 'PL_SQL_Source_To_Synapse'
            type: 'PipelineReference'
          }
          waitOnCompletion: true
          parameters: {
            ADLSDirectory: 'AdventureWorks'
          }
        }
      }
      {
        name: 'Load Into DimFact'
        type: 'ExecutePipeline'
        dependsOn: [
          {
            activity: 'Source to Synapse'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          pipeline: {
            referenceName: 'PL_Load_Into_DimFact'
            type: 'PipelineReference'
          }
          waitOnCompletion: true
          parameters: {}
        }
      }
    ]
    policy: {
      elapsedTimeMetric: {}
      cancelAfter: {}
    }
    annotations: []
    lastPublishTime: '2022-07-27T02:47:55Z'
  }
  dependsOn: [
  ]
}

resource factoryName_PL_Pause_Or_Resume_SQLPool 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${factoryName}/PL_Pause_Or_Resume_SQLPool'
  properties: {
    description: 'Resume or Pause Azure Synapse Analytics SQL Pool'
    activities: [
      {
        name: 'Check Azure Synapse SQL Pool Status'
        type: 'WebActivity'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          url: {
            value: '@concat(\'https://management.azure.com/subscriptions/\',pipeline().parameters.SubscriptionId,\'/resourceGroups/\',pipeline().parameters.ResourceGroupName,\'/providers/Microsoft.Sql/servers/\',pipeline().parameters.ServerName,\'/databases/\',pipeline().parameters.DatabaseName,\'?api-version=2014-04-01-preview\')'
            type: 'Expression'
          }
          method: 'GET'
          headers: {}
          authentication: {
            type: 'MSI'
            resource: 'https://management.azure.com/'
          }
        }
      }
      {
        name: 'If Paused and Command is Resume then Resume'
        type: 'IfCondition'
        dependsOn: [
          {
            activity: 'Check Azure Synapse SQL Pool Status'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@and(equals(activity(\'Check Azure Synapse SQL Pool Status\').output.properties.status,\'Paused\'),equals(pipeline().parameters.Command,\'resume\'))'
            type: 'Expression'
          }
          ifTrueActivities: [
            {
              name: 'Resume SQL Pool'
              description: ''
              type: 'WebActivity'
              dependsOn: []
              policy: {
                timeout: '7.00:00:00'
                retry: 3
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: [
                {
                  name: 'Azure Synapse Analytics'
                  value: 'Resume or Pause'
                }
              ]
              typeProperties: {
                url: {
                  value: '@concat(\'https://management.azure.com/subscriptions/\',pipeline().parameters.SubscriptionId,\'/resourceGroups/\',pipeline().parameters.ResourceGroupName,\'/providers/Microsoft.Sql/servers/\',pipeline().parameters.ServerName,\'/databases/\',pipeline().parameters.DatabaseName,\'/resume?api-version=2014-04-01-preview\')'
                  type: 'Expression'
                }
                method: 'POST'
                headers: {}
                body: {
                  value: '{}'
                  type: 'Expression'
                }
                authentication: {
                  type: 'MSI'
                  resource: 'https://management.azure.com/'
                }
              }
            }
          ]
        }
      }
      {
        name: 'If Online and command is Pause then Pause'
        type: 'IfCondition'
        dependsOn: [
          {
            activity: 'Check Azure Synapse SQL Pool Status'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@and(equals(activity(\'Check Azure Synapse SQL Pool Status\').output.properties.status,\'Online\'),equals(pipeline().parameters.Command,\'pause\'))'
            type: 'Expression'
          }
          ifTrueActivities: [
            {
              name: 'Pause SQL Pool'
              description: ''
              type: 'WebActivity'
              dependsOn: []
              policy: {
                timeout: '7.00:00:00'
                retry: 3
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: [
                {
                  name: 'Azure Synapse Analytics'
                  value: 'Resume or Pause'
                }
              ]
              typeProperties: {
                url: {
                  value: '@concat(\'https://management.azure.com/subscriptions/\',pipeline().parameters.SubscriptionId,\'/resourceGroups/\',pipeline().parameters.ResourceGroupName,\'/providers/Microsoft.Sql/servers/\',pipeline().parameters.ServerName,\'/databases/\',pipeline().parameters.DatabaseName,\'/pause?api-version=2014-04-01-preview\')'
                  type: 'Expression'
                }
                method: 'POST'
                headers: {}
                body: {
                  value: '{}'
                  type: 'Expression'
                }
                authentication: {
                  type: 'MSI'
                  resource: 'https://management.azure.com/'
                }
              }
            }
          ]
        }
      }
    ]
    policy: {
      elapsedTimeMetric: {}
      cancelAfter: {}
    }
    parameters: {
      SubscriptionId: {
        type: 'String'
        defaultValue: 'd9e68d12-f08a-4932-b051-30c0f30368bf'
      }
      ResourceGroupName: {
        type: 'String'
        defaultValue: 'rg-${project_name}'
      }
      Region: {
        type: 'String'
        defaultValue: 'East US'
      }
      ServerName: {
        type: 'String'
        defaultValue: 'sqldbserver-${project_name}-dev-001'
      }
      DatabaseName: {
        type: 'String'
        defaultValue: 'syndw-${project_name}-dev'
      }
      Command: {
        type: 'String'
      }
    }
    annotations: []
    lastPublishTime: '2022-07-27T05:25:03Z'
  }
  dependsOn: []
}

resource factoryName_PL_ScaleUp_Or_ScaleDown_SQLPool 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${factoryName}/PL_ScaleUp_Or_ScaleDown_SQLPool'
  properties: {
    activities: [
      {
        name: 'Check If Request is For Scale Up or Down'
        type: 'IfCondition'
        dependsOn: []
        userProperties: []
        typeProperties: {
          expression: {
            value: '@equals(pipeline().parameters.Command,\'ScaleUp\')'
            type: 'Expression'
          }
          ifFalseActivities: [
            {
              name: 'Scale Down SQL Pool'
              type: 'Script'
              dependsOn: []
              policy: {
                timeout: '7.00:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              linkedServiceName: {
                referenceName: 'SynapseMasterDB'
                type: 'LinkedServiceReference'
              }
              typeProperties: {
                scripts: [
                  {
                    type: 'Query'
                    text: {
                      value: 'ALTER DATABASE [syndw-${project_name}-dev]\nMODIFY (SERVICE_OBJECTIVE = \'DW100c\');\n\nWHILE\n(\n    SELECT TOP 1 state_desc\n    FROM sys.dm_operation_status\n    WHERE\n        1 = 1\n        AND resource_type_desc = \'Database\'\n        AND major_resource_id = \'syndw-${project_name}-dev\'\n        AND operation = \'ALTER DATABASE\'\n    ORDER BY\n        start_time DESC\n) = \'IN_PROGRESS\'\nBEGIN\n    RAISERROR(\'Scale operation in progress\',0,0) WITH NOWAIT;\n    WAITFOR DELAY \'00:00:05\';\nEND\nPRINT \'Complete\';'
                      type: 'Expression'
                    }
                  }
                ]
              }
            }
          ]
          ifTrueActivities: [
            {
              name: 'Scale Up SQL Pool'
              type: 'Script'
              dependsOn: []
              policy: {
                timeout: '7.00:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              linkedServiceName: {
                referenceName: 'SynapseMasterDB'
                type: 'LinkedServiceReference'
              }
              typeProperties: {
                scripts: [
                  {
                    type: 'Query'
                    text: {
                      value: 'ALTER DATABASE [syndw-${project_name}-dev]\nMODIFY (SERVICE_OBJECTIVE = \'DW200c\');\n\nWHILE\n(\n    SELECT TOP 1 state_desc\n    FROM sys.dm_operation_status\n    WHERE\n        1 = 1\n        AND resource_type_desc = \'Database\'\n        AND major_resource_id = \'syndw-${project_name}-dev\'\n        AND operation = \'ALTER DATABASE\'\n    ORDER BY\n        start_time DESC\n) = \'IN_PROGRESS\'\nBEGIN\n    RAISERROR(\'Scale operation in progress\',0,0) WITH NOWAIT;\n    WAITFOR DELAY \'00:00:05\';\nEND\nPRINT \'Complete\';'
                      type: 'Expression'
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    ]
    policy: {
      elapsedTimeMetric: {}
      cancelAfter: {}
    }
    parameters: {
      Command: {
        type: 'String'
      }
    }
    annotations: []
    lastPublishTime: '2022-07-27T05:25:04Z'
  }
  dependsOn: [
  ]
}
