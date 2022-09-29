# Databricks notebook source
# MAGIC %md #Silver to Gold
# MAGIC This notebook is for taking the data from silver to gold layer. Here we create the project or report specific data that we require by applying joins and aggregations as the final data transformation. This data will be provided to reports for visualization.

# COMMAND ----------

spark.sql("CREATE DATABASE IF NOT EXISTS  gold")

# COMMAND ----------

import datetime
from pyspark.sql.functions import col

SalesOrderDetailDF = spark.read.table("silver.SalesOrderDetail")
SalesOrderHeaderDF = spark.read.table("silver.SalesOrderHeader")
ProductDF = spark.read.table("silver.Product")
ProdCatDF = spark.read.table("silver.ProductCategory")
ProdModelDF = spark.read.table("silver.ProductModel")
CustDF = spark.read.table("silver.Customer")

JoinedDF = SalesOrderDetailDF.alias('SOD').join(SalesOrderHeaderDF.alias('SOH'),col('SOD.SalesOrderID') == col('SOH.SalesOrderID'))\
    .join(ProductDF.alias('p'),col('p.ProductID') == col('SOD.ProductID'))\
    .join(ProdCatDF.alias('prodcat'),col('prodcat.ProductCategoryID') == col('p.ProductCategoryID'))\
    .join(ProdModelDF.alias('prodmod'),col('p.ProductModelID') == col('prodmod.ProductModelID'))\
    .join(CustDF.alias('cust'),col('cust.CustomerID') == col('SOH.CustomerID'))\
    .select([col('p.Name').alias('Product'),
             col('p.ProductNumber'),
             col('p.Color'),
             col('p.StandardCost'),
             col('p.ListPrice'),
             col('prodcat.Name').alias('ProductCategory'),
             col('prodmod.Name').alias('ProductModel'),
             col('p.SellStartDate'),
             col('p.SellEndDate'),
             col('SOD.OrderQty'),
             col('SOD.UnitPrice'),
             col('SOD.UnitPriceDiscount'),
             col('SOD.LineTotal'),
             col('SOH.RevisionNumber'),
             col('SOH.OrderDate'),
             col('SOH.DueDate'),
             col('SOH.ShipDate'),
             col('SOH.Status'),
             col('SOH.SalesOrderNumber'),
             col('SOH.PurchaseOrderNumber'),
             col('SOH.AccountNumber'),
             col('SOH.SubTotal'),
             col('SOH.TaxAmt'),
             col('SOH.Freight'),
             col('SOH.TotalDue'),
             col('cust.CustomerName')])

#display(JoinedDF)
adlsPath = '/mnt/gold/ProductSalesOrderDetails/' + str(datetime.datetime.now()).split(" ")[0]

spark.sql("DROP TABLE IF EXISTS gold.ProductSalesOrderDetails")

(JoinedDF.write
 .format("delta")
 .mode("overwrite")
 .option("overwriteSchema", "true")
 .option("path",adlsPath)
 .saveAsTable("gold.ProductSalesOrderDetails")
)  
