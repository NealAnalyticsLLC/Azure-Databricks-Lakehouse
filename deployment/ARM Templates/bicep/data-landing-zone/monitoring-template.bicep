param log_analytics_workspace_name string = 'log-${project_name}-dev'
param project_name string = 'enterprisebi'
param location string = resourceGroup().location

resource workspaces_log_dev_resource_name 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
    name:log_analytics_workspace_name
    location: location
    properties: {
        sku: {
            name: 'PerGB2018'
        }
        retentionInDays: 30
        features: {
            enableLogAccessUsingOnlyResourcePermissions: true
        }
        workspaceCapping: {
            dailyQuotaGb: -1
        }
        publicNetworkAccessForIngestion: 'Enabled'
        publicNetworkAccessForQuery: 'Enabled'
    }
    
  }

  output log_analytics_workspace_id  string = workspaces_log_dev_resource_name.id
