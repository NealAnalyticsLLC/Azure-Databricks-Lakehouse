targetScope = 'subscription'
param deploymentlocation string = ''
param subscriptionId  string = ''
param tenantId string = ''
param project_name string = ''
param env string =''
param sql_admin_user string = ''
param sql_admin_password string = ''
param sqldw_admin_user string = ''
param sqldw_admin_password string = ''
param servers_admin_sid string = ''
param servers_admin_name string = ''
@description('adding prefix to every resource names')
param adf_config_var string = 'Yes'
var resourceprefix = take(uniqueString(deployment().name),5)



resource rgIngest 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${project_name}-datalanding-dev-001'
  location: deploymentlocation
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

resource rgGovernance 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${project_name}-datagovernance-dev-001'
  location: deploymentlocation
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${project_name}-management-dev-001'
  location: deploymentlocation
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
    location:deploymentlocation
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    sqldb_metadata_name:AzDataFactoryMetadataDeploy.outputs.sql_db_name
    servers_metadata_name:AzDataFactoryMetadataDeploy.outputs.sql_server_name
    vaults_BIKeyVault_name:AzDataFactoryMetadataDeploy.outputs.vaults_BIKeyVault_name
    servers_datawarehouse_name:AzSynapseDeploy.outputs.sqldw_server_name
    storageAccounts_datalake_name:AzDatalakeDeploy.outputs.adls_name
    
  }
  dependsOn:[
    AzMonitoringDeploy
    AzSynapseDeploy
    AzDataFactoryMetadataDeploy
    AzDatalakeDeploy
  ]
}

module AzDataFactoryConfigDeploy 'data-landing-zone/adf-config-template.bicep' = if (adf_config_var == 'Yes'){
  name: 'adf-config-${resourceprefix}'
  scope: rgIngest
  params:{
    project_name : project_name
    sqldb_connection_secret:AzDataFactoryMetadataDeploy.outputs.sqldb_connection_secret
    sqldw_connection_secret: AzDataFactoryMetadataDeploy.outputs.sqldw_connection_secret
    sqldwmasterDB_connection_secret:AzDataFactoryMetadataDeploy.outputs.sqldwmasterDB_connection_secret
    adlskey_secret: AzDataFactoryMetadataDeploy.outputs.adlskey_secret
    
  }
  dependsOn:[
    AzDataFactoryDeploy
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
    sqldw_admin_user:sqldw_admin_user
    sqldw_admin_password:sqldw_admin_password
    sqldw_server_name:AzSynapseDeploy.outputs.sqldw_server_name
    sqldw_name:AzSynapseDeploy.outputs.sqldw_server_name
    subscriptionId : subscriptionId
    location:deploymentlocation
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    adls_resource_id:AzDatalakeDeploy.outputs.adls_resource_id
    
    
  }
  dependsOn:[
    AzMonitoringDeploy
  ]
}


module AzSynapseDeploy 'data-landing-zone/synapse-template.bicep' = {
  name: 'synapse-${resourceprefix}'
  scope:rgIngest
  params:{
    project_name : project_name
    env : env
    sqldw_admin_user:sql_admin_user
    sqldw_admin_password:sqldw_admin_password
    location:deploymentlocation
    servers_admin_name:servers_admin_name
    servers_admin_sid:servers_admin_sid
    tenantId:tenantId
    //adls_resource_id:AzDatalakeDeploy.outputs.adls_resource_id
    //adls_name:AzDatalakeDeploy.outputs.adls_name
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
    location:deploymentlocation
  }
  
}

module AzDatalakeDeploy 'data-landing-zone/datalake-template.bicep' = {
  name: 'storage-${resourceprefix}'
  scope:rgIngest
  params:{
    project_name : project_name
    location:deploymentlocation
    env: env
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    
  }
  
}

module AzPurviewDeploy 'data-management-zone/governance-template.bicep' = {
  name: 'purview-${resourceprefix}'
  scope: rgGovernance
  params:{
        
        project_name : project_name
        location:deploymentlocation
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
      }
  
}


