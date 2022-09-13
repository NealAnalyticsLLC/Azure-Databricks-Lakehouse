
param project_name string = 'enterprisebi'
param location string
param storageAccounts_datalake_name string = 'dls${project_name}${env}'
param log_analytics_workspace_id string
@description('Deployment environment')
param env string

@description('Name of the resource')


resource storageAccounts_datalake_name_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccounts_datalake_name
  location: location
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
    publicNetworkAccess:'Enabled'
  }
}



resource diagnostic_log_dev_resource_name 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={
  name:'diagnostic'
  properties:{
    workspaceId:log_analytics_workspace_id
  }
  scope:storageAccounts_datalake_name_resource
}

resource storageAccounts_datalake_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  parent: storageAccounts_datalake_name_resource
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
resource storageAccounts_container_bronze_name 'containers@2021-08-01' = {
  name:'raw'
  properties:{
    publicAccess:'None'
  }
}
resource storageAccounts_container_silver_name 'containers@2021-08-01' = {
  name:'staging'
  properties:{
    publicAccess:'None'
  }
}
}
resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_datalake_name_default 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  parent: storageAccounts_datalake_name_resource
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}


resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_datalake_name_default 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = {
  parent: storageAccounts_datalake_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_datalake_name_default 'Microsoft.Storage/storageAccounts/tableServices@2021-08-01' = {
  parent: storageAccounts_datalake_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}



output adls_resource_id string = storageAccounts_datalake_name_resource.id
output adls_name string = storageAccounts_datalake_name_resource.name

