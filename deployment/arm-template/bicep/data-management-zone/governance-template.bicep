param project_name string


@description('Deployment environment')
param env string = 'dev'

@description('Name of the resource')
param purviewName string = 'pview-${project_name}-${env}'
param settingName string = 'diagnostics'
param log_analytics_workspace_id string
param vaults_BIKeyVault_name string = 'kvpurview${env}104'
param tenantId string = subscription().tenantId
param location string = resourceGroup().location


resource purviewName_resource 'Microsoft.Purview/accounts@2020-12-01-preview' = {
  name: purviewName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  sku: {
    name: 'Standard'
    capacity: '4'
  }
  tags: {}
  dependsOn: []
}

resource purviewName_Microsoft_Insights_settingName 'Microsoft.Purview/accounts/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${purviewName}/Microsoft.Insights/${settingName}'
  properties: {
    workspaceId: log_analytics_workspace_id
    logs: [
      {
        category: 'ScanStatusLogEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
  dependsOn: [
    purviewName_resource
  ]
}

resource vaults_kvpurview_name_resource 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaults_BIKeyVault_name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: [
            ]
    }
    accessPolicies: [
      
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    
    enabledForTemplateDeployment: true
    // enableSoftDelete: false
    enableRbacAuthorization: false
    vaultUri: 'https://${vaults_BIKeyVault_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
    softDeleteRetentionInDays:7
  }
}
