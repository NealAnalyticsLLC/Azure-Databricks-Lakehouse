# Overview

## Introduction

The Goal of this project is to leverage the data lake house to meet the organizations needs to process or to perform analytics on the data and the proposed architecture will help to accelerate the start-off process.

## Logical Architecture

![Logical Architecture](./images/Technical%20Architecture.png)

- **Azure Data Factory** use the metadata stored in **Azure SQL DB** and pull data from different data sources.
- Azure Data Factory stores all the source data into **Data Lake Raw zone**.
- Then we can move and transform the data from Data Lake Raw zone to Databricks **Bronze**, **Silver** and **Gold** layers.
- Data stored in the Gold layer will be available for Power BI visualization.


# Getting Started
## Prerequisites 
In order to successfully deploy this solution, you will need to have access to and/or provision the following resources:
- [Azure Subscription](https://portal.azure.com/) with owner access - Required to deploy azure resources
- [Azure CLI installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)- Required for deployment scripts to be run locally (optional)

## AZURE RESOURCES DEPLOYMENT
The resources in this folder can be used to deploy the required cloud services into your Azure Subscription. This can be done either via the [Azure Portal](https://portal.azure.com) or by using the [PowerShell script](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/deployment/ARM%20Templates/bicep/resourcedeployment.ps1) included in the deployment folder.

After deployment, you will have an Azure Data Lake Storage Gen 2 Registry, Azure Data Factory, Azure Key Vault, Azure SQL Server, and Azure Databricks along with Log Analytics.

Resources can also be deployed into your Azure Subscription by using this link.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/dev/Sanket/deployment/arm-template/json/main2.json?token=GHSAT0AAAAAABZQO4UQTEDMMRKODHYOQ6Y4YZ6MPJQ)

**NOTE (for deploying using PowerShell script):**

You can use this [link](https://azure.microsoft.com/en-in/global-infrastructure/geographies/#geographies) to choose from and decide deployment locations **<deployment-location>** according to your requirements.

## Deployment Parameters

1. **param deploymentLocation string = '\<deployment-location>'**
This parameter is for the location of the deployment to take place, that is in which Azure region you wish to deploy the resources. Replace <deployment-location> with the value of location you want.
For e.g., if you want to deploy in EAST US then it will be
**param deploymentLocation string = 'eastus'**

2. **param projectName string = '\<project-name>'**
This parameter is for the name of the project that you want to give(can be an abbreviation too). Replace **<project-name>** with the name of project you want.

3. **param Environment string ='\<environment of development>'**
This parameter is for the environment of the development the resources are in. Replace **<environment of development>** with the environment of development for e.g.,
**dev** for Development environment, **uat** for testing environment and **prod** for Production environment.
	
	**NOTE**: The parameters **projectName** and **Environment** value should only have lowercase letters and numbers, no special characters allowed and shouldn't be more than 5-10 letters.


4. **param SqlAdminUser string = '\<sqldbserver-user-id>'**
This parameter is for the username of the SQL db server admin that you want to give. 
Replace **<sqldbserver-user-id>** with any username of your choice.
For e.g.,  **param SqlAdminUser string = 'sqladmin'**

5. **param SqlAdminPassword string = '\<sqldbserver-password>'**
This parameter is for the password of the sql db server that you want to give. 
Replace **<sqldbserver-password>** with any username of your choice. Please follow this [link](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16) to check the password policy for Azure SQL Server.

6. **param SqlServerSID string = '\<sql-sever-admin-sid>'**
It's the Object Id of User/Group and can be obtained from Azure Active Directory -> Users/Groups ->   Replace **<sql-sever-admin-sid>** with the SID of the person that you want to keep as admin.
	* Copy the **Object ID** from below, also known as the **SID** and paste it in the parameter section.
	
		![Overview](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/Overview.png)

7. **param SqlServerAdminName string = '\<sql-server-admin-emailid>'**
This parameter is for the email-id of the SQL Server Admin that is required for setting up Azure Active Directory login for SQL Server. Replace **<sql-server-admin-emailid>** with the email-id of the person that you want to keep as admin.


## Configurations

**The following configurations are required and automatically gets created with deployment:**  
1. **Key vault Secrets:**
The following secrets would be created in key vault with deployment.
    - AzureSQLDBConnection - Required to connect Azure SQL DB
    - ADLSKey - Required to store ADLS keys   
2. **ADF Linked Services (ARM Template):**
Linked services to the following resources will be created through ARM template
    - Key vault
    - Data lake
    - Azure SQL DB

3. **ADF Networking:**
Following Private endpoints will be created for the following resources
    - Private endpoint for SQL DB
    - Private endpoint for Data Lake
    - Private endpoint for the key vault

4. **ADF Permission (ARM template):**
    - SQL DB Contributor access to SQL DB
    - Blob data contributor to the Data Lake

5. **Diagnostic settings:**
    - Enable all services to log data into log analytics

**Note:**
- SQL Credential for Metadata  parameter is used for username/password  
- Provided username/password is used to create the connection string for DBs for ADF linked services  
      
       
**The following configurations are required and needs to be done after deployment:**

1. **Meta Data SQL Database**  
You need to run the SQL script shared with code in Azure SQL DB to create below meta data table.

    ![MetaData Table](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/MetaData%20Table.png)

    - **SourceToRaw** – Purpose of this table is to store source related details and data lake storage details which will be useful in data pipeline to copy data from source to ADLS.
    Example:
        ```
        INSERT INTO [dbo].[SourceToRaw]  ([ServerName], [DatabaseName], [SchemaName], [TableName], [Query], [ConnectionSecret], [DataLakeContainer], [DataLakeDirectory], [DataLakeFileName])
        VALUES ('DESKTOPServer', 'Adventure Works', 'SalesLT', 'Address', 'Select * from SalesLT.Address','ADLSConnection', 'raw', 'AdventureWorks','Address.parquet')
        ```
    - **metadata** – Purpose of this table is to store the information about the files on which we are having the transformations.  
    Example:
        ```
        INSERT INTO [dbo].[metadata]([SourceContainer], [DataLakeDirectory], [DataLakeFileName], [DestinationContainer], [DestinationDirectory], [DestinationFileName])
        VALUES ('raw', '', 'Address', 'bronze','9/29/2022','Address')
        ```

2. **Key vault Secrets**  
You will need to add one more secret for connecting to the data source. For example, if your data source is On-Prem SQL server then value of secret will be in following format:
Server=servername;Database=DBName;User Id=username;Password=Pswd;

3. **Create a Cluster**  
You will have to create a cluster of your preferred after you launch the databricks workspace. There are many cluster configuration options, which are described in detail in cluster configuration.

4. **Install Modules on to the Cluster**  
    Step1: Select the cluster created.  
    Step2: Select Libraries => Install New => Select Library Source = "Maven" => Coordinates => Search Packages => Select Maven Central => Search for the package required. Example: (GDAL) => Select the version (3.0.0) required => Install

## Data Pipelines
### How to build a ADF pipeline
Consider, you are creating pipeline for On Premises SQL server as source, then basic steps of pipeline creation will be as follows:

1. Create Integration Runtime based on access to your source. You can refer following link for creating Integration Runtime.
<https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime>

2. For connecting to the source data server, create Linked Service which will connect to source using credentials stored in azure key vault secret. Fetch the connection secret using Key vault linked service which is created in deployment as shown in below image.

    ![Key vault](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/Key%20vault.png)

    You can refer below link for creation of linked service –  
    <https://docs.microsoft.com/en-us/azure/data-factory/concepts-linked-services?tabs=data-factory>

3. Create new datasets for source and sink. Source dataset will point to the source and use linked service created in previous step. And sink dataset will point to ADLS linked service created through deployment.
Follow below link for more details about creating dataset.
<https://docs.microsoft.com/en-us/azure/data-factory/v1/data-factory-create-datasets>

4. Create a new pipeline by going to Author section of ADF. For more details go through below link.
<https://docs.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory-portal>
You can refer below screenshot to create pipeline to copy data from source and store into Databricks delta tables. In this pipeline data is copied from On-Prem SQL server using input from Azure SQL Db and this data is stored into ADLS. Further data is transformed and stored into different layers of delta tables like Bronze, Silver and Gold.

    ![Master Pipeline](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/Master%20Pipeline.png)


There are 4 types of pipelines that can be build depending on the requirements.

1. Historical Pipelines
2. Incremental Pipelines
3. Archive pipelines
4. Quality Check Pipelines

## Data Bricks Notebooks
To use the containers from ADLS first we have to mount those in Data Bricks. You can refer to the below link to mount your containers.  
[Accessing Azure Data Lake Storage Gen2 and Blob Storage with Azure Databricks - Azure Databricks | Microsoft Docs](https://docs.microsoft.com/en-us/azure/databricks/data/data-sources/azure/azure-storage)

To take a look at different transformations performed in each layer, refer the notebooks attached [here](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/tree/dev/Sanket/notebooks).

# Report Development
## How to use Data Bricks in Power BI
**To connect to Azure Databricks by using the Delta Sharing Connector, complete the following steps:**

1. Open Power BI Desktop.
2. On the Get Data menu, search for Delta Sharing.
3. Select the connector and click Connect.
4. Enter the warehouse URL that you copied from the credentials file into the Delta Sharing Server URL field.
5. Optionally, in the Advanced Options tab, set a Row Limit for the maximum number of rows that you can download. This is set to 1 million rows by default.
6. Click OK.
7. For Authentication, copy the token that you retrieved from the credentials file into Bearer Token.
8. Click Connect.

**Access Azure Databricks data source using the Power BI service**  
When you publish a report to the Power BI service, you can enable users to access the report and underlying Azure Databricks data source using SSO:
1. Publish your Power BI report from Power BI Desktop to the Power BI service.
2. Enable single sign on (SSO) access to the report and underlying data source.
    - Go to the underlying Azure Databricks dataset for the report in the Power BI service, expand Data source credentials, and click Edit credentials.
    - On the configuration dialog, select Report viewers can only access this data source with their own Power BI identities using Direct Query and click Sign in.
    	
        ![Config](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/Power%20BI.png)


With this option selected, access to the data source is handled using DirectQuery and managed using the Azure AD identity of the user who is accessing the report. If you don’t select this option, only you, as the user who published the report, have access to the Azure Databricks data source.

You can refer this [link](https://docs.microsoft.com/en-us/azure/databricks/integrations/bi/power-bi) to connect databricks through different methods.

# Recommendations

## Performance
- **Pipeline Categorization** - Categorize pipelines based on their trigger time and on the type of data source. It is better to reduce dependencies between the master pipeline and child pipelines.
- **Householding Columns** - Use householding columns like pipeline id, triggered, created date, and Updated date. It will be useful to do a better audit trail.
- **Linked Services** - Linked Services should be dynamic enough to handle different source connections. Recommendation is to use dynamic parameters in linked service to make it generic. Access all credentials from Azure Key Vault. So that it will work for all environments.
- **Data Lake File Names** - Instead of deleting files before copying, use DateTimeStamp in file names while storing files in ADLS.
- **Naming conventions recommendations**
    - Pipeline - PL_[Source Name/Phase]_[Destination Phase]_{DestinationObject}|{“ALL”}
    - Dataset - DS_[SRC/INT/DST]_[Data Set Name/Phase]_{Object}|{“ALL”}
    - Linked Service - LS_[Source Name/Phase]
    - Trigger - TR_[Project Group]_[JobID]_[Frequency]
- **Integration runtime nodes** - It is better to start with at least two nodes for integration runtime. If the plan is to increase the number of pipelines which has the same scheduled, then Integration runtime node should also increase.
- **Integration Runtime** - Use same naming convention for Integration Runtime in all environments. Otherwise, it will start creating dependency in ADF pipelines. Once we deploy the pipelines in another environment, it will start searching IR with the different IR name.
- **Pipeline Schedule** - Instead of having the same schedule for all pipelines it can also be categorized by business priority.
- **Use custom functions to simplify complex calculations** - Once you have a custom function, then can be called anytime to perform that specific calculation
- **Use views when creating intermediate tables** - Views are session oriented and minimize storage usage and save costs
- **Enable Adaptive Query Execution** - AQE improves large query performance. By default, AQE is disabled, to enable it use set spark.sql.adaptive.enabled = true
- **Query directly on parquet files from ADLS** - If need to use data from parquet files, do not extract into ADB in intermediate table format, instead query on parquet to save time and storage

## Monitoring and Alert
- **Alerts** - Configure email alerts in azure data factory pipelines on failure of pipeline execution.

## Security
- **RBAC** - Enable Role Based Access Control for containers available in ADLS.
- **Key Vaults** – Use Azure Key vaults for storing credentials or secrets.

## Cost Management
- **Budget alerts** - Use budget alerts. Budget alerts notify you when spending, based on usage or cost, reaches or exceeds the amount defined in the alert condition of the budget. Cost Management budgets are created using the Azure portal or the Azure Consumption API.

## Databricks Cluster
- **Customize Cluster termination time** - Terminating inactive clusters saves costs. Databricks automatically terminates clusters based on a default down time. Customize the down time to avoid premature or delayed termination.
- **Enable cluster autoscaling** - Databricks offers cluster autoscaling, which is disabled by default. Enable this feature to enhance job performance.



<p align="center">
    For any questions, contact support@nealanalytics.com
</p>
