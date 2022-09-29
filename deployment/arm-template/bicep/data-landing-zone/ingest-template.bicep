param subscriptionId string
param location string = resourceGroup().location
param project_name string = 'enterprisebi'
param vaults_BIKeyVault_name string 
param dataFactories_adf_name string = 'adf-${project_name}-${env}'
param storageAccounts_datalake_name string 
param version string = 'V2'
param vNetEnabled bool = true
param log_analytics_workspace_id string
param privateEndpoints_adls_private_endpoint_name string = 'adls-private-endpoint-${env}'


@description('Deployment environment')
param env string = 'dev'

@description('Name of the resource')
param databricks_workspace string
param sqldb_metadata_name string
param servers_metadata_name string 
param akvbaseURL string = 'https://${vaults_BIKeyVault_name}.vault.azure.net'
param adlsURL string = 'https://${storageAccounts_datalake_name}.dfs.core.windows.net'


resource dataFactories_adf_name_resource 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactories_adf_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource diagnostic_log_dev_resource_name 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={
  name:'diagnostic'
  properties:{
    workspaceId:log_analytics_workspace_id
  }
  scope:dataFactories_adf_name_resource
}



resource dataFactories_adf_vnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if ((version == 'V2') && vNetEnabled) {
  parent: dataFactories_adf_name_resource
  name: 'default'
  properties: {}
}

resource dataFactories_adf_name_AutoResolveIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if ((version == 'V2') && vNetEnabled) {
  parent: dataFactories_adf_name_resource
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
  dependsOn: [
    dataFactories_adf_vnet
  ]
}

resource dataFactories_adls_managed_endpoint 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  parent: dataFactories_adf_vnet
  name: privateEndpoints_adls_private_endpoint_name
  properties: {
    groupId: 'blob'
    privateLinkResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Storage/storageAccounts/${storageAccounts_datalake_name}'
  }

}

resource dataFactories_adf_name_default_sqldb_metadata_name 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  parent: dataFactories_adf_vnet
  name: sqldb_metadata_name
  properties: {
    groupId: 'sqlServer'
    privateLinkResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Sql/servers/${servers_metadata_name}'
  }

}

resource dataFactories_adf_name_default_vaults_BIKeyVault_name 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  parent: dataFactories_adf_vnet
  name: vaults_BIKeyVault_name
  properties: {
    groupId: 'vault'
    privateLinkResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.KeyVault/vaults/${vaults_BIKeyVault_name}'
  }

}

resource dataFactories_adf_name_default_Synapse 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  parent: dataFactories_adf_vnet
  name: databricks_workspace
  properties: {
    groupId: 'sqlServer'
    privateLinkResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Databricks/workspaces/${databricks_workspace}'
  }
 
}

resource akvlinkedservice 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'AzureKeyVaultLinkedService'
  parent: dataFactories_adf_name_resource
  properties: {
    annotations: [
      
    ]
    description: 'string'
    parameters: {}
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: akvbaseURL    
  }
  }
}


resource adlslinkedservice 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'ADLS2LinkedService'
  parent: dataFactories_adf_name_resource
  properties: {
    annotations: [
      
    ]
    
    description: 'string'
    parameters: {}
    type: 'AzureBlobFS'
    typeProperties: {
      accountKey: {
        type: 'AzureKeyVaultSecret'
        store: {
            referenceName: 'AzureKeyVaultLinkedService'
            type: 'LinkedServiceReference'
        }
        secretName: 'ADLSKey'
    }
      url: adlsURL
    }
  }
  dependsOn: [
    akvlinkedservice
  ]
  }
  resource sqldblinkedservice 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
    name: 'AzureSQLDBLinkedService'
    parent: dataFactories_adf_name_resource
    properties: {
      annotations: [  
      ]
      description: 'string'
      parameters: {}
      type: 'AzureSqlDatabase'
      typeProperties: {
          connectionString: {
              type: 'AzureKeyVaultSecret'
              store: {
                  referenceName: 'AzureKeyVaultLinkedService'
                  type: 'LinkedServiceReference'
              }
              secretName: 'AzureSQLDBConnection'
          }
      }
    }
    dependsOn: [
      akvlinkedservice
    ]
  }


  
output adf_name string = dataFactories_adf_name
output dataFactories_adls_managed_endpoint string = dataFactories_adls_managed_endpoint.name
output dataFactories_adf_name_resource string = dataFactories_adf_name_resource.name
