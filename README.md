# Overview

## Introduction

The Goal of this project is to leverage the data lake house to meet the organizations needs on the type of data on which they want to process or to perform analytics and the proposed architecture will help to accelerate the start-off process.

## Logical Architecture –

![Logical Architecture](./images/Technical%20Architecture.png)


# Getting Started
## Prerequisites 
In order to successfully deploy this solution, you will need to have access to and/or provision the following resources:
- [Azure Subscription](https://portal.azure.com/) with owner access - Required to deploy azure resources
- [Azure CLI installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)- Required for deployment scripts to be run locally (optional)

## AZURE RESOURCES DEPLOYMENT
The resources in this folder can be used to deploy the required cloud services into your Azure Subscription. This can be done either via the [Azure Portal](https://portal.azure.com) or by using the [PowerShell script](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/deployment/ARM%20templates/bicep/resourcedeployment.ps1) included in the deployment folder.

After deployment, you will have an Azure Data Lake Storage Gen 2 Registry, Azure Data Factory, Azure Key Vault, Azure SQL Server, and Azure SQL Dedicated Pool along with Log Analytics.

Resources can also be deployed into your Azure Subscription by using this link.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]()

**NOTE (for deploying using PowerShell script):**

You can use this [link](https://azure.microsoft.com/en-in/global-infrastructure/geographies/#geographies) to choose from and decide deployment locations **<deployment-location>** according to your requirements.

**Before deploying the code, you’ll have to edit the parameters in the code**

Below are the steps to edit the parameters in the main.bicep file.	

Step 1: 
Open the main.bicep file from the downloaded package.
On the top you’ll see several parameters defined as follows:

## Configuration
The following configurations are required and needs to be done after deployment-

1. Meta Data SQL Database  
You need to run the SQL script shared with code in Azure SQL DB to create below meta data tables.

    ER Diagram –
    ![MetaData Tables](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/MetaData%20Tables.png)

    1. SourceToStaging – Purpose of this table is to store source related details and data lake storage details which will be useful in data pipeline to copy data from source to ADLS.
    Example:
        ```
        INSERT INTO [dbo].[SourceToStaging]  ([ServerName], [DatabaseName], [SchemaName], [TableName], [Query], [ConnectionSecret], [DataLakeContainer], [DataLakeDirectory], [DataLakeFileName])
        VALUES ('DESKTOPServer', 'Adventure Works', 'SalesLT', 'Address', 'Select * from SalesLT.Address','ADLSConnection', 'Staging', 'AdventureWorks','Address.parquet')
        ```

    2. StagingToCleansed – The Purpose of this table is to store the details about the tables from staging stage to cleansed stage.
    Example:
        ```
        INSERT INTO [dbo].[StagingToCleansed]([ConnectionSecret], [SourceDataLakeContainer], [SourceDataLakeDirectory], [SourceDataLakeFileName], [DestinationDataLakeContainer], [DestinationDataLakeDirectory], [DestinationDataLakeFileName])
        VALUES ('ADLSConnection', 'Staging', 'AdventureWorks', 'Address.parquet', 'Cleansed', 'AdventureWorks', 'Address.parquet')
        ```
    3. **CleansedToSynapse** – This table will store synapse database details like synapse table name, schema, columns, column name for incremental pull etc. Also, it will store ADLS details in the fields for Cleansed data.
    Example:
        ```
        INSERT INTO [dbo].[CleansedToSynapse]([PrimaryKey], [Columns], [IncColumnName], [LoadType], [DataLakeContainer], [DataLakeDirectory],  [DataLakeFileName], [DataLakeConnection], [DestinationSchemaName], [DestinationTableName], [DestinationConnection], [DimensionType])
        VALUES ('AddressID', 'AddressLine1,City,StateProvince,CountryRegion', 'DateModified', 'Incremental',
        'Cleansed', 'AdventureWorks', 'Address.parquet', 'ADLSConnection', 'dim', 'Address', 'SynapseConnection','1')
        ```
    4. **DataValidation** – This table will store all the data required for validation of data copied from source.
    Example:
        ```
        INSERT INTO [dbo].[DataValidation] ([Id], [DataSource], [ValidationRule], [ValidationCondition], [ColumnName], [FileName], [DirectoryName], [ContainerName], [TableName])
        VALUES ('1', 'SQL', 'primary key column cannot be null or blank ',"toString(isNull(toString(byName('AddressId'))))", 'AddressId', 'Address.parquet', 'AdventureWorks', 'Cleansed', 'Address')
        ```
    5. ActivityLogs – This table will store the logs of copy activities used to copy data from the source and logs of pipeline execution.
    Example:
        ```
        INSERT INTO [dbo].[ActivityLogs] ([activity_id], [activity_name], [activity_type], [pipeline_id], [pipeline_name], [pipeline_run_id], [trigger_id], [event_status], [pipeline_exe_status], [rows_processed], [started_dttm], [finished_dttm], [datetime_created], [datetime_modified], [updated_by])
        VALUES ('f2068677-4d6e-45bc-b9d2-5a2bcd730a87', 'cp_sql_data_to_staging', 'copy activity', 'fe6b50cc-07c4-4043-abb5-c976996db009', 'PL_SQL_Source_To_Synapse', 'd774c88b-3ddd-4305-b54b-1382d056b407', 'b54f5cf6-9853-4422-9562-f8e15718dc5f', 'Succeeded', 'Succeeded', '15', '2022-04-07 05:40:59.363', '2022-04-07 05:40:59.363', '2022-04-07 05:40:59.363', '2022-04-07 05:40:59.363','org\user1')
        ```

2. Key vault Secrets
You will need to add one more secret for connecting to the data source. For example, if your data source is On-Prem SQL server then value of secret will be in following format:
Server=servername;Database=DBName;User Id=username;Password=Pswd;

3. Create a Cluster
You will have to create a cluster of your preferred after you launch the databricks workspace. There are many cluster configuration options, which are described in detail in cluster configuration.

4. Install Modules on to the Cluster  
    Step1: Select the cluster created.  
    Step2: Select Libraries => Install New => Select Library Source = "Maven" => Coordinates => Search Packages => Select Maven Central => Search for the package required. Example: (GDAL) => Select the version (3.0.0) required => Install

## Data Pipelines
### How to build a ADF pipeline -
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
We will be using the Data Bricks notebook to transform our data over 3 phases which will be bronze, silver, gold. But before that we need to mount our raw container from where we will be taking out data. To mount Data Bricks to a container you can refer to the below link.  

Accessing Azure Data Lake Storage Gen2 and Blob Storage with Azure Databricks - Azure Databricks | Microsoft Docs

After we mounted the container from where we are going to take the data and the container where we are going to store the data.  

First step is to create a notebook for taking the data from raw zone and landing it into the bronze layer in delta format. No major transformation will take place in this layer. 

Second step is to create a notebook for taking the data from bronze layer to silver layer. Here we can perform the transformation activities to clean the data and store that into the silver layer. So that the silver layer can provide the enterprise view of all its key business entities, concept and transactions.  

The third step is to create a notebook for taking the data from silver layer to the gold layer. Here we select the project or report specific data that we require by applying joins and aggregations for the final data transformation and the data quality rules and the store it in the gold layer. This data is now ready for consumption and then we can take this final form of data and use it to create report etc.

# Report Development
## How to use Data Bricks in Power BI
To connect to Azure Databricks by using the Delta Sharing Connector, complete the following steps:

1. Open Power BI Desktop.
2. On the Get Data menu, search for Delta Sharing.
3. Select the connector and click Connect.
4. Enter the warehouse URL that you copied from the credentials file into the Delta Sharing Server URL field.
5. Optionally, in the Advanced Options tab, set a Row Limit for the maximum number of rows that you can download. This is set to 1 million rows by default.
6. Click OK.
7. For Authentication, copy the token that you retrieved from the credentials file into Bearer Token.
8. Click Connect.

Access Azure Databricks data source using the Power BI service
When you publish a report to the Power BI service, you can enable users to access the report and underlying Azure Databricks data source using SSO:
1. Publish your Power BI report from Power BI Desktop to the Power BI service.
2. Enable single sign on (SSO) access to the report and underlying data source.
    - Go to the underlying Azure Databricks dataset for the report in the Power BI service, expand Data source credentials, and click Edit credentials.
    - On the configuration dialog, select Report viewers can only access this data source with their own Power BI identities using Direct Query and click Sign in.
    	
        ![Config](https://github.com/NealAnalyticsLLC/Azure-Databricks-Lakehouse/blob/dev/Sanket/images/Power%20BI.png)


With this option selected, access to the data source is handled using DirectQuery and managed using the Azure AD identity of the user who is accessing the report. If you don’t select this option, only you, as the user who published the report, have access to the Azure Databricks data source.

# Recommendations

## Performance
- Pipeline Categorization - Categorize pipelines based on their trigger time and on the type of data source. It is better to reduce dependencies between the master pipeline and child pipelines.
- Householding Columns - Use householding columns like pipeline id, triggered, created date, and Updated date. It will be useful to do a better audit trail.
- Linked Services - Linked Services should be dynamic enough to handle different source connections. Recommendation is to use dynamic parameters in linked service to make it generic. Access all credentials from Azure Key Vault. So that it will work for all environments.
- Data Lake File Names - Instead of deleting files before copying, use DateTimeStamp in file names while storing files in ADLS.
- Naming conventions recommendations
    - Pipeline - PL_[Source Name/Phase]_[Destination Phase]_{DestinationObject}|{“ALL”}
    - Dataset - DS_[SRC/INT/DST]_[Data Set Name/Phase]_{Object}|{“ALL”}
    - Linked Service - LS_[Source Name/Phase]
    - Trigger - TR_[Project Group]_[JobID]_[Frequency]
- Integration runtime nodes - It is better to start with at least two nodes for integration runtime. If the plan is to increase the number of pipelines which has the same scheduled, then Integration runtime node should also increase.
- Integration Runtime - Use same naming convention for Integration Runtime in all environments. Otherwise, it will start creating dependency in ADF pipelines. Once we deploy the pipelines in another environment, it will start searching IR with the different IR name.
- Pipeline Schedule - Instead of having the same schedule for all pipelines it can also be categorized by business priority.
- Use custom functions to simplify complex calculations - Once you have a custom function, then can be called anytime to perform that specific calculation
- Use views when creating intermediate tables - Views are session oriented and minimize storage usage and save costs
- Enable Adaptive Query Execution - AQE improves large query performance. By default, AQE is disabled, to enable it use set spark.sql.adaptive.enabled = true
- Query directly on parquet files from ADLS - If need to use data from parquet files, do not extract into ADB in intermediate table format, instead query on parquet to save time and storage

## Monitoring and Alert
- Alerts - Configure email alerts in azure data factory pipelines on failure of pipeline execution.

## Security
- RBAC - Enable Role Based Access Control for containers available in ADLS.
- Key Vaults – Use Azure Key vaults for storing credentials or secrets.

## Cost Management
- Budget alerts - Use budget alerts. Budget alerts notify you when spending, based on usage or cost, reaches or exceeds the amount defined in the alert condition of the budget. Cost Management budgets are created using the Azure portal or the Azure Consumption API.

## Databricks Cluster
- Customize Cluster termination time - Terminating inactive clusters saves costs. Databricks automatically terminates clusters based on a default down time. Customize the down time to avoid premature or delayed termination.
- Enable cluster autoscaling - Databricks offers cluster autoscaling, which is disabled by default. Enable this feature to enhance job performance.

For any questions, contact support@nealanalytics.com
