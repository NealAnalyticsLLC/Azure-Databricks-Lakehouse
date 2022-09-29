param subscriptionId string
// param tenantId string = subscription().tenantId

param adf_name string
// param sqldw_resource_id string
//param sql_db_resource_id string
param adls_name string
param sql_server_name string
param databricks_workspace_name string


var SQLDBContributor = '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'
var BlobDataContributor = '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource adls 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: adls_name
}

resource sql_server 'Microsoft.Sql/servers@2019-06-01-preview' existing = {
  name: sql_server_name
}

resource sqldb_contributor_access 'Microsoft.Authorization/roleAssignments@2018-01-01-preview' = {
  name: guid('ADFSQLDBContributor')
  properties: {
    roleDefinitionId: SQLDBContributor
    principalId: reference(resourceId('Microsoft.DataFactory/factories',adf_name), '2018-06-01', 'Full').identity.principalId
  }
  scope:sql_server

}
 
resource blob_data_contributor_access_adf 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name:guid('ADFBlobDataContributor')
  properties: {
    roleDefinitionId: BlobDataContributor
    principalId: reference(resourceId('Microsoft.DataFactory/factories',adf_name), '2018-06-01', 'Full').identity.principalId
    
  }
  scope:adls
}

resource blob_data_contributor_access_databricks 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name:guid('ADFBlobDataContributor')
  properties: {
    roleDefinitionId: BlobDataContributor
    principalId: reference(resourceId('Microsoft.Databricks/workspaces',databricks_workspace_name), '2018-04-01', 'Full').identity.principalId
    
  }
  scope:adls
}


