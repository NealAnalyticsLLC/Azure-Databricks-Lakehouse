# Databricks notebook source
# MAGIC %md #Bronze To Silver
# MAGIC This notebook is for taking the data from bronze to silver layer. Here we will perform the transformation activities to clean the data like removing the unneccesary columns, creating required new columns from existing one and then store that into the silver layer. 

# COMMAND ----------

# MAGIC %sh
# MAGIC curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# MAGIC curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list 
# MAGIC apt-get update
# MAGIC ACCEPT_EULA=Y apt-get install msodbcsql17
# MAGIC apt-get -y install unixodbc-dev
# MAGIC sudo apt-get install python3-pip -y
# MAGIC pip3 install --upgrade pyodbc

# COMMAND ----------

from datetime import datetime, timedelta
import pyodbc
from pandas import date_range
from pyspark.sql.functions import *
from delta.tables import *

# COMMAND ----------

spark.sql("CREATE DATABASE IF NOT EXISTS silver")

# COMMAND ----------

dbutils.widgets.text('BronzeDirectory','')
dbutils.widgets.text('BronzeTableName','')
dbutils.widgets.text('SilverDirectory','')
dbutils.widgets.text('SilverTableName','')
dbutils.widgets.text('BronzeTablePrimaryKey','')


# COMMAND ----------

BronzeDirectory = dbutils.widgets.get('BronzeDirectory')
BronzeTableName = dbutils.widgets.get('BronzeTableName')
SilverDirectory = dbutils.widgets.get('SilverDirectory')
SilverTableName = dbutils.widgets.get('SilverTableName')
BronzeTablePrimaryKey = dbutils.widgets.get('BronzeTablePrimaryKey')

# COMMAND ----------

readpath = "/mnt/bronze/"+BronzeDirectory+'/'+BronzeTableName
writepath = "/mnt/silver/"+SilverDirectory+'/'+SilverTableName

# COMMAND ----------

todays_date = datetime.today()

# COMMAND ----------

server_name = "sqldbserver-dlhdemo8-uat.database.windows.net"
database_name = "sqldb-dlhdemo8-uat"
db_admin_username = "sqladmin"
db_admin_password = "Snktm@43"

# COMMAND ----------

cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=' + 
                        server_name + ';DATABASE='+ database_name +';UID=' + db_admin_username + 
                        ';PWD='+ db_admin_password)
cursor = cnxn.cursor()

# COMMAND ----------

watermark = cursor.execute(f"SELECT Max([SilverWatermark]) FROM [dbo].[BronzeToSilver] WHERE [BronzeTableName] = '{BronzeTableName}'")\
                .fetchall()[0][0]
if watermark == None or watermark.strftime("%Y%m%d") == datetime.today().strftime("%Y%m%d"):
    watermark = datetime.today() - timedelta(1)
    
elapsed_days = (datetime.today() - watermark).days
date_list = date_range(watermark+timedelta(1), periods=elapsed_days).strftime("%Y%m%d").tolist()

# COMMAND ----------

dataframe = ""
for date in date_list:
    try:
        df = spark.read.format('delta')\
                    .load(f'{readpath}/{date}')
        
        if dataframe:
                dataframe = dataframe.union(df)
        else:
            dataframe = df
                
    except Exception as err:
            print(err)

#=========================================================================================================================

# Drop rows which have more than 50% NAs
dataframe = dataframe.dropna(thresh=int(0.5 * len(dataframe.columns)))

# fill null values
dataframe = dataframe.na.fill(value='NA')

# drop duplicate rows 
dataframe = dataframe.dropDuplicates()

#=========================================================================================================================
update_sub_statement = ','.join(spark.sparkContext.parallelize(dataframe.columns).map(lambda x: x+'=SOURCE.'+x).collect())
final_update_statement='UPDATE SET ' + update_sub_statement

insert_sub_statement = ','.join(spark.sparkContext.parallelize(dataframe.columns).map(lambda x:'SOURCE.'+x).collect())
final_insert_statement='INSERT (' + ','.join(dataframe.columns) +') VALUES(' + insert_sub_statement+')'

dataframe.createOrReplaceTempView("data")

if not DeltaTable.isDeltaTable(spark, f'{writepath}/{date}'):
    dataframe.write.format("delta")\
        .mode("overwrite")\
        .option("overwriteSchema", "true")\
        .save(f'{writepath}/{date}')

    spark.sql(f" CREATE TABLE IF NOT EXISTS silver.{SilverTableName} USING DELTA LOCATION '{writepath}/{date}' ")
else:
    merge_statement = f"""MERGE INTO silver.{SilverTableName} TARGET
                USING data SOURCE
                ON TARGET.{BronzeTablePrimaryKey} = SOURCE.{BronzeTablePrimaryKey}
                WHEN MATCHED THEN {final_update_statement}
                WHEN NOT MATCHED THEN {final_insert_statement}"""

    spark.sql(merge_statement)
    

