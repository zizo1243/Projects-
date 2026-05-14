
import pandas as pd
from kafka import KafkaConsumer
import json
import time

df = pd.DataFrame(columns=['transaction_id','timestamp','customer_id', 'stock_ticker','transaction_type','quantity','average_trade_size','cumulative_portfolio_value','stock_price','total_trade_amount','customer_account_type','day_name','is_weekend','is_holiday', 'stock_liquidity_tier','stock_sector', 'stock_industry'])

# Initialize Kafka consumer
consumer = KafkaConsumer(
    '55_10227_Topic',
    bootstrap_servers='kafka:9092',   # IMPORTANT for Docker
    auto_offset_reset='latest',
    enable_auto_commit=True,
    group_id='stock-consumer-group',
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

print("Listening for messages in '55_10227_Topic'...")




for message in consumer:

    print(f"Received: {message.value}")
    if message.value =='EOF':
        print("EOF received, stopping consumer.")
        break
    print(f"Received: {message.value['transaction_id']}, {message.value['timestamp']}, {message.value['customer_id']}, {message.value['stock_ticker']}, {message.value['transaction_type']}, {message.value['quantity']}, {message.value['average_trade_size']}, {message.value['cumulative_portfolio_value']}, {message.value['stock_price']}, {message.value['total_trade_amount']}, {message.value['customer_account_type']}, {message.value['day_name']}, {message.value['is_weekend']}, {message.value['is_holiday']}, {message.value['stock_liquidity_tier']}, {message.value['stock_sector']}, {message.value['stock_industry']}")
    print('-'*50)


print("Closing consumer...")

consumer.close()