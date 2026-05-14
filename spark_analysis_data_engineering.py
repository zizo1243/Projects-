from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.sql.functions import col

spark = SparkSession.builder \
    .appName("StockAnalysis") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

print("Spark started")

df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("/app/data/FULL_STOCKS.csv")

print("Schema:")
df.printSchema()
## visualizing first 10 rows in the data set 
print("Sample data:")
df.show(10)


##Total trading volume per stock ticker 
print("Total trading volume per stock ticker")
df.groupBy("stock_ticker") \
  .sum("quantity") \
  .withColumnRenamed("sum(quantity)", "total_volume") \
  .show()
  
  
##Average stock price by sector
df = df.withColumn(
    "stock_price",
    col("stock_price").cast("double")
)
print("Average stock price by sector")
df.groupBy("stock_sector") \
 .avg("stock_price") \
  .withColumnRenamed("avg(stock_price)", "avg_price") \
  .show()
  
  
  ##Buy vs Sell on weekends
print("Buy vs Sell on weekends")
df.filter(col("is_weekend") == True) \
  .groupBy("transaction_type") \
  .count() \
  .show()


##Customers with >10 transactions
print("Customers with >10 transactions")
df.groupBy("customer_id") \
  .count() \
  .filter(col("count") > 10) \
  .show()
  
  
##Total trade amount per day
df = df.withColumn(
    "total_trade_amount",
    col("total_trade_amount").cast("double")
)

print("Total trade amount per day")
df.groupBy("day_name") \
  .sum("total_trade_amount") \
  .withColumnRenamed("sum(total_trade_amount)", "total_amount") \
  .orderBy(col("total_amount").desc()) \
  .show()


### spark SQL

df.createOrReplaceTempView("stocks")

##SQL Top 5 traded stocks"
print("SQL Top 5 traded stocks")
spark.sql("""
SELECT stock_ticker, SUM(quantity) AS total_qty
FROM stocks
GROUP BY stock_ticker
ORDER BY total_qty DESC
LIMIT 5
""").show()

## SQL Avg trade amount by account type
print("SQL Avg trade amount by account type")
spark.sql("""
SELECT customer_account_type, AVG(total_trade_amount) AS avg_trade
FROM stocks
GROUP BY customer_account_type
""").show()

##SQL Holiday vs non-holiday
print("SQL Holiday vs non-holiday")
spark.sql("""
SELECT is_holiday, COUNT(*) AS transactions
FROM stocks
GROUP BY is_holiday
""").show()


##SQL Weekend volume by sector
print("SQL Weekend volume by sector")
spark.sql("""
SELECT stock_sector, SUM(quantity) AS total_qty
FROM stocks
WHERE is_weekend = true
GROUP BY stock_sector
ORDER BY total_qty DESC
""").show()


##SQL Buy vs Sell by liquidity tier
print("SQL Buy vs Sell by liquidity tier")
spark.sql("""
SELECT stock_liquidity_tier, transaction_type,
       SUM(total_trade_amount) AS total_amount
FROM stocks
GROUP BY stock_liquidity_tier, transaction_type
""").show()

spark.stop()


