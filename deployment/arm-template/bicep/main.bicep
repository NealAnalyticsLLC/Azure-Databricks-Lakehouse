targetScope = 'subscription'

param subscriptionId string = subscription().subscriptionId
param tenantId string = subscription().tenantId
param deployment_location string = 'eastus'
param project_name string = 'ebidb'
param env string ='dev'
param sql_admin_user string = 'sqladmin'
@secure()
param sql_admin_password string = 'SASql1234!'
param servers_admin_sid string = '356cbc1d-a189-4950-957b-3460e4714eb6'
param servers_admin_name string = 'piyush@nealanalytics.com'
@description('adding prefix to every resource names')
var resourceprefix = take(uniqueString(deployment().name),5)



resource rgIngest 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${project_name}-datalanding-dev-001'
  location: deployment_location
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

resource rgGovernance 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${project_name}-datagovernance-dev-001'
  location: deployment_location
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${project_name}-management-dev-001'
  location: deployment_location
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

module AzDataFactoryDeploy 'data-landing-zone/ingest-template.bicep' = {
  name: 'adf-${resourceprefix}'
  scope: rgIngest
  params:{
    project_name : project_name
    env : env
    subscriptionId : subscriptionId
    location:deployment_location
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    sqldb_metadata_name:AzDataFactoryMetadataDeploy.outputs.sql_db_name
    servers_metadata_name:AzDataFactoryMetadataDeploy.outputs.sql_server_name
    vaults_BIKeyVault_name:AzDataFactoryMetadataDeploy.outputs.vaults_BIKeyVault_name
    databricks_workspace:AzDatabricksDeploy.outputs.databricks_workspace
    storageAccounts_datalake_name:AzDatalakeDeploy.outputs.adls_name
    
  }
  dependsOn:[
    AzMonitoringDeploy
    AzDatabricksDeploy
    AzDataFactoryMetadataDeploy
    AzDatalakeDeploy
  ]
}

module AzDataFactoryMetadataDeploy 'data-landing-zone/metadata-template.bicep' = {
  name: 'metadata-${resourceprefix}'
  scope: rgIngest
  params:{
    servers_admin_sid:servers_admin_sid
    servers_admin_name: servers_admin_name
    tenantId : tenantId
    project_name : project_name
    env : env
    sql_admin_user:sql_admin_user
    sql_admin_password:sql_admin_password
    subscriptionId : subscriptionId
    location:deployment_location
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    adls_resource_id:AzDatalakeDeploy.outputs.adls_resource_id
    
  }
  dependsOn:[
    AzMonitoringDeploy
  ]
}


module AzDatabricksDeploy 'data-landing-zone/databricks-template.bicep' = {
  name: 'synapse-${resourceprefix}'
  scope:rgIngest
  params:{
    project_name : project_name
    env : env
    location:deployment_location
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
  }
  dependsOn:[
    AzMonitoringDeploy
    AzDatalakeDeploy
  ]
  
}

module AzMonitoringDeploy 'data-landing-zone/monitoring-template.bicep' = {
  name: 'monitoring-${resourceprefix}'
  scope:rgManagement
  params:{
    project_name : project_name
    location:deployment_location
  }
  
}

module AzDatalakeDeploy 'data-landing-zone/datalake-template.bicep' = {
  name: 'storage-${resourceprefix}'
  scope:rgIngest
  params:{
    project_name : project_name
    location:deployment_location
    env: env
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    
  }
  
}

module AzPurviewDeploy 'data-management-zone/governance-template.bicep' = {
  name: 'purview-${resourceprefix}'
  scope: rgGovernance
  params:{
        
        project_name : project_name
        location:deployment_location
        env : env
        log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
      
    }
    dependsOn:[
      AzMonitoringDeploy
    ]
}

module AzContributorAccessDeploy 'data-landing-zone/contributor-access-template.bicep' = {
  name: 'contributor-${resourceprefix}'
  scope:rgIngest
  params:{
    subscriptionId:subscriptionId
    adf_name:AzDataFactoryDeploy.outputs.adf_name
    adls_name:AzDatalakeDeploy.outputs.adls_name
    sql_server_name: AzDataFactoryMetadataDeploy.outputs.sql_server_name
    databricks_workspace_name:AzDatabricksDeploy.outputs.databricks_workspace
      }
  
}


