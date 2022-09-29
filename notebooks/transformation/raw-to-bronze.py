# Databricks notebook source
# MAGIC %md #Raw to Bronze
# MAGIC 
# MAGIC This notebook is for taking the data from raw zone and land it into the bronze layer in delta format. No major transformation will take place in this layer.

# COMMAND ----------

spark.sql("CREATE DATABASE IF NOT EXISTS bronze")

# COMMAND ----------

import datetime

tableList = dbutils.fs.ls('dbfs:' + '/mnt/raw')
    
for table in tableList:
    tablename = table.name.split('/')[0]
    date = str(datetime.datetime.now()).split(" ")[0]
    deltapath = "/mnt/bronze/" + tablename +"/" + date
    print(table.name)
    spark.sql("DROP TABLE IF EXISTS bronze."+tablename)
    df = spark.read.format('parquet').option("header",True).option("inferShema",True).load(table.path+date+'/'+tablename+'.parquet')
    df.write.format("delta").mode("overwrite").option("overwriteSchema", "true").option("path",deltapath).saveAsTable("bronze."+tablename)

