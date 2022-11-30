# Databricks notebook source
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
import pandas as pd
import re
from pyspark.sql import functions as F

# COMMAND ----------

# MAGIC %md #Raw to Bronze
# MAGIC 
# MAGIC This notebook is for taking the data from raw zone and land it into the bronze layer in delta format. No major transformation will take place in this layer.

# COMMAND ----------

spark.sql("CREATE DATABASE IF NOT EXISTS bronze")

# COMMAND ----------

dbutils.widgets.text('RawDirectory','')
dbutils.widgets.text('RawTableName','')
dbutils.widgets.text('RawTableFormat','')
dbutils.widgets.text('BronzeDirectory','')
dbutils.widgets.text('BronzeTableName','')
dbutils.widgets.text('RawTablePrimaryKey','')


# COMMAND ----------

RawDirectory = dbutils.widgets.get('RawDirectory')
RawTableName = dbutils.widgets.get('RawTableName')
RawTableFormat = dbutils.widgets.get('RawTableFormat')
BronzeDirectory = dbutils.widgets.get('BronzeDirectory')
BronzeTableName = dbutils.widgets.get('BronzeTableName')
RawTablePrimaryKey = dbutils.widgets.get('RawTablePrimaryKey')

# COMMAND ----------

todays_date = datetime.today()

# COMMAND ----------

readpath = "/mnt/raw/"+RawDirectory
writepath = "/mnt/bronze/"+BronzeDirectory+'/'+BronzeTableName


# COMMAND ----------

sqlconnection = dbutils.secrets.get(scope = "EnterpriseBIScope", key = "adbsqlconnection")

# COMMAND ----------

cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};' + sqlconnection)
cursor = cnxn.cursor()

# COMMAND ----------

watermark = cursor.execute(f"SELECT Max([BronzeWatermark]) FROM [dbo].[RawToBronze] WHERE [RawTableName] = '{RawTableName}'")\
                .fetchall()[0][0]
if watermark.strftime("%Y%m%d") == None or datetime.today().strftime("%Y%m%d"):
    watermark = datetime.today() - timedelta(1)
    
elapsed_days = (datetime.today() - watermark).days
date_list = date_range(watermark+timedelta(1), periods=elapsed_days).strftime("%Y%m%d").tolist()

# COMMAND ----------

watermark = cursor.execute(f"SELECT [BronzeWatermark] FROM [dbo].[RawToBronze] WHERE [RawTableName] = '{RawTableName}'")\
                .fetchall()[0][0]

# COMMAND ----------

dataframe = ""
for date in date_list:
    try:
        df = spark.read.format(RawTableFormat)\
                    .option("header",True)\
                    .option("inferShema",True)\
                    .load(f'{readpath}/{RawTableName}.{RawTableFormat}')
        if dataframe:
                dataframe = dataframe.union(df)
        else:
            dataframe = df
                
    except Exception as err:
            print(err)



update_sub_statement = ','.join(spark.sparkContext.parallelize(dataframe.columns).map(lambda x: x+'=SOURCE.'+x).collect())
final_update_statement='UPDATE SET ' + update_sub_statement

insert_sub_statement = ','.join(spark.sparkContext.parallelize(dataframe.columns).map(lambda x:'SOURCE.'+x).collect())
final_insert_statement='INSERT (' + ','.join(dataframe.columns) +') VALUES(' + insert_sub_statement+')'

spark.conf.set("spark.databricks.delta.defaults.columnMapping.mode", "name")

dataframe = dataframe.toDF(*[re.sub('[ ,;{}()\n\t="]', '_', c) for c in dataframe.columns])

dataframe.createOrReplaceTempView("data")

if not DeltaTable.isDeltaTable(spark, f'{writepath}/{date}'):
   
    dataframe.write.format("delta").mode("overwrite").save(f'{writepath}/{date}/')
    #spark.sql("CONVERT TO DELTA parquet.'dbfs:/mnt/bronze/UK/renewable/20221012/'\\")
    spark.sql(f" CREATE TABLE IF NOT EXISTS bronze.{BronzeTableName} USING DELTA LOCATION '{writepath}/{date}' ")
else:
    merge_statement = f"""MERGE INTO bronze.{BronzeTableName} TARGET
                USING data SOURCE
                ON TARGET.{RawTablePrimaryKey} = SOURCE.{RawTablePrimaryKey}
                WHEN MATCHED THEN {final_update_statement}
                WHEN NOT MATCHED THEN {final_insert_statement}"""

    spark.sql(merge_statement)
    
