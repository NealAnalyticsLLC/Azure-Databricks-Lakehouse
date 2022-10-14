# Databricks notebook source
spark.sql("CREATE DATABASE IF NOT EXISTS  gold")

# COMMAND ----------

from datetime import datetime
from pyspark.sql.functions import col

uk_renewable_energy = spark.read.table("silver.renewable_energy")

uk_renewable_energy = uk_renewable_energy.select([col('Year'),
                                       col('Energy_from_renewable_waste_sources'),
                                       col('Total_energy_consumption_of_primary_fuels_and_equivalents'),
                                       col('Fraction_from_renewable_sources_and_waste'),
                                       col('Hydroelectric_power'),
                                       col('Wind_wave_tidal'),
                                       col('Solar_photovoltaic'),
                                       col('Biomass'),
                                       col('Cross_boundary_Adjustment')
                                       
             ])

#display(JoinedDF)
adlsPath = '/mnt/gold/uk_renewable_energy/' + datetime.now().strftime("%Y%m%d")

uk_renewable_energy.write.format("delta")\
        .mode("overwrite")\
        .option("overwriteSchema", "true")\
        .save(f'{adlsPath}')

spark.sql(f" CREATE TABLE IF NOT EXISTS gold.uk_renewable_energy USING DELTA LOCATION '{adlsPath}' ")


# COMMAND ----------


