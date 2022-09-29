# Databricks notebook source
# MAGIC %md #Bronze To Silver
# MAGIC This notebook is for taking the data from bronze to silver layer. Here we will perform the transformation activities to clean the data like removing the unneccesary columns, creating required new columns from existing one and then store that into the silver layer. 

# COMMAND ----------

from pyspark.sql.functions import *
import datetime

# COMMAND ----------

spark.sql("CREATE DATABASE IF NOT EXISTS  silver")

# COMMAND ----------

date = str(datetime.datetime.now()).split(' ')[0]

# COMMAND ----------

#Address Table
AddressDF = spark.read.table("bronze.address")
AddressDF = AddressDF.na.fill("").withColumn("Address",concat(col("Addressline1"),lit(','),col("Addressline2"))).drop("Addressline1").drop("Addressline2")

path = '/mnt/silver/Address/' + '/' + date

spark.sql("DROP TABLE IF EXISTS silver.address")

(AddressDF.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",path)
 .saveAsTable("silver.Address")
)

# COMMAND ----------

#SalesOrderHeader Table

SalesOrderHeaderDF = spark.read.table("bronze.SalesOrderHeader")

SalesOrderHeader = SalesOrderHeaderDF.drop("CreditCardApprovalCode","Comment","rowguid")

SOHpath = '/mnt/silver/SalesOrderHeader/' + '/' + date

spark.sql("DROP TABLE IF EXISTS silver.SalesOrderHeader")

(SalesOrderHeader.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",SOHpath)
 .saveAsTable("silver.SalesOrderHeader")
)

# COMMAND ----------

#SalesOrderDetail Table
    
SalesOrderDetailDF = spark.read.table("bronze.SalesOrderDetail")

SalesOrderDetail = SalesOrderDetailDF.drop("rowguid")

SODpath = '/mnt/silver/SalesOrderDetail/' + '/' + date
spark.sql("DROP TABLE IF EXISTS silver.SalesOrderDetail")

(SalesOrderDetail.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",SODpath)
 .saveAsTable("silver.SalesOrderDetail")
)

# COMMAND ----------

#ProductModel Table
    
ProductModelDF = spark.read.table("bronze.ProductModel")

ProductModel = ProductModelDF.drop("CatalogDescription","rowguid")

ProdModelpath = '/mnt/silver/ProductModel/' + '/' + date
spark.sql("DROP TABLE IF EXISTS silver.ProductModel")

(ProductModel.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",ProdModelpath)
 .saveAsTable("silver.ProductModel")
)

# COMMAND ----------

#ProductDescription Table
    
ProductDescriptionDF = spark.read.table("bronze.ProductDescription")

ProductDescription = ProductDescriptionDF.drop("rowguid")

ProdDpath = '/mnt/silver/ProductDescription/' + '/' + date
spark.sql("DROP TABLE IF EXISTS silver.ProductDescription")

(ProductDescription.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",ProdDpath)
 .saveAsTable("silver.ProductDescription")
)

# COMMAND ----------

#ProductCategory Table
    
ProductCategoryDF = spark.read.table("bronze.ProductCategory")

ProductCategory = ProductCategoryDF.drop("rowguid")

ProdCatpath = '/mnt/silver/ProductCategory/' + '/' + date
spark.sql("DROP TABLE IF EXISTS silver.ProductCategory")

(ProductCategory.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",ProdCatpath)
 .saveAsTable("silver.ProductCategory")
)

# COMMAND ----------

#Product Table
    
ProductDF = spark.read.table("bronze.Product")

Product = ProductDF.withColumn("Profit",(col("ListPrice") - col("StandardCost"))).drop("ThumbNailPhoto","ThumbnailPhotoFileName","rowguid")

Prodpath = '/mnt/silver/Product/' + '/' + date
spark.sql("DROP TABLE IF EXISTS silver.Product")

(Product.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",Prodpath)
 .saveAsTable("silver.Product")
)

# COMMAND ----------

#Customer Table
    
CustomerDF = spark.read.table("bronze.Customer")

Customer = CustomerDF.na.fill("").withColumn("CustomerName",concat(col("Title"),lit(' '),col("FirstName"),lit(' '),col("MiddleName"),lit(' '), col("LastName"))).drop("Title","FirstName","MiddleName","LastName","NameStyle","PasswordHash","PasswordSalt" ,"rowguid")

Customerpath = '/mnt/silver/Customer/' + '/' + date
spark.sql("DROP TABLE IF EXISTS silver.Customer")

(Customer.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",Customerpath)
 .saveAsTable("silver.Customer")
)
