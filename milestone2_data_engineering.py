import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sqlalchemy import create_engine
import psycopg2
import os
from kafka import KafkaConsumer
import json
import time
from sklearn.preprocessing import LabelEncoder
f=pd.read_csv("sample_output.csv")
## Encoding
def encoded_data(df):
    df_encoded = df.copy()
    lookup_rows = []   # will become ONE lookup table
    
    # 1. stock_ticker (Label Encoding)
    le_stock = LabelEncoder()
    df_encoded['stock_ticker_encoded'] = le_stock.fit_transform(
        df_encoded['stock_ticker']
    )

    for orig, enc in zip(le_stock.classes_, range(len(le_stock.classes_))):
        lookup_rows.append(['stock_ticker', orig, enc])

    # 2. transaction_type (Label Encoding)
    le_trans = LabelEncoder()
    df_encoded['transaction_type_encoded'] = le_trans.fit_transform(
        df_encoded['transaction_type']
    )

    for orig, enc in zip(le_trans.classes_, range(len(le_trans.classes_))):
        lookup_rows.append(['transaction_type', orig, enc])
        
    # 3. customer_account_type (One-Hot Encoding)
    one_hot = pd.get_dummies(
        df_encoded['customer_account_type'],
        prefix='account_type'
    )
    df_encoded = pd.concat([df_encoded, one_hot], axis=1)

    for idx, col in enumerate(one_hot.columns):
        lookup_rows.append(['customer_account_type', col, idx])

    # 4. day (Label Encoding)
    le_day = LabelEncoder()
    df_encoded['day_name_encoded'] = le_day.fit_transform(df_encoded['day_name'])

    for orig, enc in zip(le_day.classes_, range(len(le_day.classes_))):
        lookup_rows.append(['day_name', orig, enc])

    # Final lookup table
    lookup_df = pd.DataFrame(
        lookup_rows,
        columns=['Column Name', 'Original Value', 'Encoded Value']
    )

    return df_encoded, lookup_df
df_stream = f.sample(frac=0.05, random_state=42)
df_offline = f.drop(df_stream.index)
df_stream.to_csv("stream.csv",index=False)
df_offline_encoded,lookup_offline=encoded_data(df_offline)
FULL_DF = df_offline_encoded.copy()
## Data streaming   
def process_stream(FULL_DF):
    ff=FULL_DF.copy()
    """
    Consumes streamed data from Kafka,
    encodes it, and appends it to FULL_DF
    """

    consumer = KafkaConsumer(
        '55_10227_Topic',
        bootstrap_servers='localhost:9092',
        auto_offset_reset='latest',
        enable_auto_commit=False,
        group_id=None,
        value_deserializer=lambda x: x.decode('utf-8')  # decode STRING first
    )

    print("[INFO] Kafka consumer started...")

    for message in consumer:
        raw_value = message.value
        data = json.loads(raw_value)
        # -------------------------
        # END OF STREAM CHECK
        # -------------------------
        if data == "EOS":
            print("[INFO] EOS received. Stopping consumer.")
            break

        # -------------------------
        # Decode JSON safely
        # -------------------------
    
        

        print("[STREAMED ROW]", data)

        # Convert dict → DataFrame (single row)
        row_df = pd.DataFrame([data])
    
        # Encode streamed row
        row_df_encoded, _ = encoded_data(row_df)

        # Append to FULL_DF
        ff = pd.concat([ff, row_df_encoded], ignore_index=True)

   
    print("[INFO] Consumer closed.")

    return ff    

FULL_DF=process_stream(FULL_DF)    
FULL_DF.to_csv("Full stock",index=False)
## now we have full stock df that has all the encoded data of the full dataset

 

    
    
    
   


