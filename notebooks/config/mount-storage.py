# Databricks notebook source
# MAGIC %md #Common Configurations

# COMMAND ----------

# Application (Client) ID
applicationId = dbutils.secrets.get(scope="EnterpriseBIScope",key="ClientID")
 
# Application (Client) Secret Key
authenticationKey = dbutils.secrets.get(scope="EnterpriseBIScope",key="ClientSecret")
 
# Directory (Tenant) ID
tenandId = dbutils.secrets.get(scope="EnterpriseBIScope",key="TenantID")
 
endpoint = "https://login.microsoftonline.com/" + tenandId + "/oauth2/token"

# Connecting using Service Principal secrets and OAuth
configs = {"fs.azure.account.auth.type": "OAuth",
           "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
           "fs.azure.account.oauth2.client.id": applicationId,
           "fs.azure.account.oauth2.client.secret": authenticationKey,
           "fs.azure.account.oauth2.client.endpoint": endpoint}


# COMMAND ----------

# MAGIC %md #Mounting Raw Container

# COMMAND ----------

# Python code to mount and access Azure Data Lake Storage Gen2 Account from Azure Databricks with Service Principal and OAuth
 
# Define the variables used for creating connection strings
adlsAccountName = "adlsndpfdev001"
adlsContainerName = "raw"
mountPoint = "/mnt/raw"

source = "abfss://" + adlsContainerName + "@" + adlsAccountName + ".dfs.core.windows.net/" 
 
# Mount ADLS Storage to DBFS only if the directory is not already mounted
if not any(mount.mountPoint == mountPoint for mount in dbutils.fs.mounts()):
  dbutils.fs.mount(
    source = source,
    mount_point = mountPoint,
    extra_configs = configs)

# COMMAND ----------

# MAGIC %md #Mounting Bronze Container

# COMMAND ----------

# Define the variables used for creating connection strings
adlsAccountName = "adlsndpfdev001"
adlsContainerName = "bronze"
mountPoint = "/mnt/bronze"
 
source = "abfss://" + adlsContainerName + "@" + adlsAccountName + ".dfs.core.windows.net/"
 
# Mount ADLS Storage to DBFS only if the directory is not already mounted
if not any(mount.mountPoint == mountPoint for mount in dbutils.fs.mounts()):
  dbutils.fs.mount(
    source = source,
    mount_point = mountPoint,
    extra_configs = configs)

# COMMAND ----------

# MAGIC %md #Mounting Silver Container

# COMMAND ----------

# Define the variables used for creating connection strings
adlsAccountName = "adlsndpfdev001"
adlsContainerName = "silver"
mountPoint = "/mnt/silver"

source = "abfss://" + adlsContainerName + "@" + adlsAccountName + ".dfs.core.windows.net/"
 
# Mount ADLS Storage to DBFS only if the directory is not already mounted
if not any(mount.mountPoint == mountPoint for mount in dbutils.fs.mounts()):
  dbutils.fs.mount(
    source = source,
    mount_point = mountPoint,
    extra_configs = configs)

# COMMAND ----------

# MAGIC %md #Mounting Gold Container

# COMMAND ----------

# Define the variables used for creating connection strings
adlsAccountName = "adlsndpfdev001"
adlsContainerName = "gold"
mountPoint = "/mnt/gold"
 
source = "abfss://" + adlsContainerName + "@" + adlsAccountName + ".dfs.core.windows.net/"
 
# Mount ADLS Storage to DBFS only if the directory is not already mounted
if not any(mount.mountPoint == mountPoint for mount in dbutils.fs.mounts()):
  dbutils.fs.mount(
    source = source,
    mount_point = mountPoint,
    extra_configs = configs)
