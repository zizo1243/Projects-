import pandas as pd
from kafka import KafkaProducer
from kafka import KafkaConsumer
import json
import time

producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

csv_data = pd.read_csv('stream.csv')


print("Sending data to Kafka...")

for index, row in csv_data.iterrows():
    message = row.to_dict()
  
    producer.send('55_10227_Topic', value=message)
    print(f"Sent: {message}")
    time.sleep(0.3)
    
producer.send('55_10227_Topic', value='EOS')
print("Sent EOS message.")


producer.close()
