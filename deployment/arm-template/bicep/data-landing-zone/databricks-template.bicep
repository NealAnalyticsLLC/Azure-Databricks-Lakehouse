param project_name string
param env string
param log_analytics_workspace_id string
@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool = false
@description('The name of the Azure Databricks workspace to create.')
param workspaceName string = 'adb${project_name}${env}'
@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'
@description('Location for all resources.')
param location string

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

resource workspaceName_resource 'Microsoft.Databricks/workspaces@2018-04-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
    parameters: {
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
  }
}

resource diagnostic_log_dev_resource_name 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={
  name:'diagnostic'
  properties:{
    workspaceId:log_analytics_workspace_id
  }
  scope:workspaceName_resource
}



output databricks_workspace string = workspaceName_resource.name


