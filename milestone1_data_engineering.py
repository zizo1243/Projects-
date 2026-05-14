##importing the data 
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sqlalchemy import create_engine
import psycopg2
import os
print("Current directory:", os.getcwd())
print("Files:", os.listdir())

##Reading the data 
vg = pd.read_csv("daily_trade_prices.csv")
tr=pd.read_csv("trades.csv")
cu = pd.read_csv("dim_customer.csv")
da = pd.read_csv("dim_date.csv")
st = pd.read_csv("dim_stock.csv")
## function to handel the missing data
def handle_missing_data(vg, tr):
    """
    The Missing data will be handeled in 2 stages 
    1- To see the missing stock price, we go to the trade dataset and check if there is a user who bought this stock on that day. 
    Then, we look at the user’s portfolio cumulative price and determine whether the user bought or sold it, as well as the quantity of
    the stocks. If any user is found (which is our case), we will take the cumulative portfolio of the user and subtract it from the previous 
    last time if his status is "BUY"; otherwise, it will be added, then divided by the quantity. This will be the correct price of the stock 
    on that day.
    2- If the missing value corresponds to a day when no user bought the stock, we will calculate the mean, but not the normal mean of all data.
    Instead, we will use a rolling function to calculate the mean for a small period of time (7 days) and observe the fluctuation of prices during these 7 days.
    If the fluctuation is high (above the threshold of 5%), we will take the rolling median instead of the rolling mean.
    If there is still any other missing data, we will calculate the interpolation.
    """
    #Stage 1
    missing_data = []
    for _, row in vg.iterrows():
        date = row['date']
        for stock in vg.columns[1:]:
            if pd.isna(row[stock]):
                missing_data.append({'Date': date, 'Stock': stock})
    missing_df = pd.DataFrame(missing_data)

    results = []
    for _, miss in missing_df.iterrows():
        date = miss['Date']
        stock = miss['Stock']
        buyers = tr[
            (tr['timestamp'] == date) &
            (tr['stock_ticker'] == stock) &
            (tr['transaction_type'] == 'BUY')
        ]
        if not buyers.empty:
            for customer_id in buyers['customer_id'].unique():
                results.append({'Date': date, 'Stock': stock, 'Customer_ID': customer_id})
        else:
            results.append({'Date': date, 'Stock': stock, 'Customer_ID': pd.NA})
    buyers_df = pd.DataFrame(results)
    unique_buyers_df = buyers_df.drop_duplicates(subset=['Date', 'Stock'], keep='first')

    results = []
    for _, row in unique_buyers_df.iterrows():
        customer_id = row['Customer_ID']
        date = row['Date']
        stock = row['Stock']
        if pd.isna(customer_id):
            continue
        user_trades = tr[tr['customer_id'] == customer_id].sort_values(by='timestamp')
        current_idx = user_trades[
            (user_trades['timestamp'] == date) &
            (user_trades['stock_ticker'] == stock)
        ].index
        if len(current_idx) == 0:
            continue
        current_pos = user_trades.index.get_loc(current_idx[0])
        current_trade = user_trades.loc[current_idx[0]]
        x1 = current_trade['cumulative_portfolio_value']
        q = current_trade['quantity']
        ttype = current_trade['transaction_type']
        x2 = user_trades.iloc[current_pos - 1]['cumulative_portfolio_value'] if current_pos > 0 else 0
        if pd.isna(x2):
            result_value = pd.NA
        else:
            result_value = (x2 - x1) / q if ttype.upper() == 'SELL' else (x1 - x2) / q
        results.append({
            'Date': date,
            'Stock': stock,
            'Customer_ID': customer_id,
            'Transaction_Type': ttype,
            'x1': x1,
            'x2': x2,
            'Quantity': q,
            'Result': result_value
        })
    calc_df = pd.DataFrame(results)
    updated_df = vg.copy()
    for _, row in calc_df.iterrows():
        date = row['Date']
        stock = row['Stock']
        value_to_fill = row['Result']
        if pd.isna(value_to_fill):
            continue
        mask = (updated_df['date'] == date)
        if stock in updated_df.columns:
            updated_df.loc[mask, stock] = updated_df.loc[mask, stock].fillna(value_to_fill)
    # Stage 2
    updated_df['date'] = pd.to_datetime(updated_df['date'])
    updated_df = updated_df.sort_values(by='date').reset_index(drop=True)
    rolling_window = 7
    stability_threshold = 0.05
    numeric_df = updated_df.set_index('date')
    rolling_mean = numeric_df.rolling(window=rolling_window, min_periods=1).mean()
    rolling_var = numeric_df.rolling(window=rolling_window, min_periods=1).var()
    stability_mask = rolling_var < (stability_threshold * rolling_mean)
    filled_df = numeric_df.copy()

    for stock in filled_df.columns:
        missing_dates = filled_df[stock][filled_df[stock].isna()].index
        for date in missing_dates:
            start = date - pd.Timedelta(days=rolling_window)
            end = date + pd.Timedelta(days=rolling_window)
            stable_period = filled_df.loc[start:end, stock][stability_mask.loc[start:end, stock]]
            unstable_period = filled_df.loc[start:end, stock][~stability_mask.loc[start:end, stock]]
            if not stable_period.empty:
                filled_df.at[date, stock] = stable_period.mean()
            elif not unstable_period.empty:
                filled_df.at[date, stock] = unstable_period.median()
            if pd.isna(filled_df.at[date, stock]):
                filled_df[stock] = filled_df[stock].interpolate(method='linear')
    final_df = filled_df.reset_index()
    print(" Missing data handled successfully!\n")
    return final_df
## function to handel the outliers
def handle_outliers_log(df, threshold=10):
    """
    The outliers were handeled using log method 
    """
    transformed_df = df.copy()
    
    summary_records = []

    for stock in df.columns:
        data = df[stock]

        # Skip non-numeric columns (like 'date')
        
        if not np.issubdtype(data.dtype, np.number):
            continue
        Q1, Q3 = data.quantile([0.25, 0.75])
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR
        # Detect outliers
        outliers = data[(data < lower_bound) | (data > upper_bound)]
        outlier_percentage = (len(outliers) / len(data)) * 100
        # Apply log(1 + x) transformation if above threshold
        if outlier_percentage > threshold:
            transformed_data = np.log(data) 
            transformed_df.loc[data.index, stock] = transformed_data

        # Record summary info
        summary_records.append({
            "Stock": stock,
            "Outlier % (Before)": round(outlier_percentage, 2),
         
        })

    # Compute new outlier percentages after transformation
    post_outlier_perc = {}
    for stock in transformed_df.columns:
        data = transformed_df[stock]
        if np.issubdtype(data.dtype, np.number):
            Q1, Q3 = data.quantile([0.25, 0.75])
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            outliers = data[(data < lower_bound) | (data > upper_bound)]
            post_outlier_perc[stock] = round((len(outliers) / len(data)) * 100, 2)

    # Merge before/after summary
    summary_df = pd.DataFrame(summary_records)
    summary_df["Outlier % (After)"] = summary_df["Stock"].map(post_outlier_perc)
    print(f"Outliers handeled successfully")
    return transformed_df, summary_df
##function to handel the inconsistencies
def handle_inconsistencies(df, tr):
    """
    Cleans the given DataFrame by handling structural and logical inconsistencies,
    without modifying missing values or outliers.

    Steps handled:
      1. Remove duplicate rows
      2. Ensure numeric columns are of correct type
      3. Sort data by date
      4. Replace impossible values (e.g., <= 0 in stock prices) with NaN
    """
    
    cleaned_df = df.copy()
    date_col='date'
    # 1- Remove duplicate rows
    cleaned_df = cleaned_df.drop_duplicates()    
    # 2- Fix data types for numeric columns
    for col in cleaned_df.columns:
        if col != date_col:
            cleaned_df[col] = pd.to_numeric(cleaned_df[col], errors='coerce')
    
    #3- Sort by date if it exists
    if date_col in cleaned_df.columns:
        cleaned_df = cleaned_df.sort_values(by=date_col)    
    #4- Handle impossible (inconsistent) values
    for col in cleaned_df.columns:
        if col != date_col:
            num_invalid = (cleaned_df[col] <= 0).sum()
            
            if num_invalid > 0:
                cleaned_df.loc[cleaned_df[col] <= 0, col] = np.nan
                cleaned_df=handle_missing_data(cleaned_df,tr)
            
    print("Inconsistencies handled successfully")
    return cleaned_df
## function to merge the final data to get the final data set
def merge_full_data(tr, final_df_transformed2, cu, da, st):
    """
    Merges trade, customer, day, and stock data into a unified DataFrame.
    Parameters:
        tr (pd.DataFrame): Trades data with 'timestamp', 'stock_ticker', 'quantity', 'customer_id'.
        final_df_transformed2 (pd.DataFrame): Stock prices with 'date' and stock columns.
        cu (pd.DataFrame): Customer data with 'customer_id' and 'account_type'.
        da (pd.DataFrame): Day info with 'date', 'day_name', 'is_weekend', 'is_holiday'.
        st (pd.DataFrame): Stock info with 'stock_ticker', 'liquidity_tier', 'sector', 'industry'.

    Returns:
        pd.DataFrame: Fully merged and cleaned dataset ready for analysis.
    """

    # 1️- Create a working copy
    tr1 = tr.copy()

    # 2- Normalize timestamp formats
    tr1['timestamp'] = pd.to_datetime(tr1['timestamp'], errors='coerce').dt.normalize()
    final_df_transformed2['date'] = pd.to_datetime(final_df_transformed2['date'], errors='coerce').dt.normalize()
    da['date'] = pd.to_datetime(da['date'], errors='coerce').dt.normalize()

    # 3- Define lookup function for stock price
    def get_stock_price(row):
        date = row['timestamp']
        stock_col = row['stock_ticker'].lower()  # lowercase column name to match
        try:
            price_series = final_df_transformed2.loc[
                final_df_transformed2['date'] == date, stock_col
            ]
            return price_series.values[0] if not price_series.empty else None
        except KeyError:
            return None  # stock column doesn't exist

    # 4- Apply stock price lookup
    tr1['stock_price'] = tr1.apply(get_stock_price, axis=1)

    # 5- Compute total trade amount
    tr1['total_trade_amount'] = tr1['stock_price'] * tr1['quantity']

    # 6- Merge customer account type
    tr1 = tr1.merge(
        cu[['customer_id', 'account_type']],
        on='customer_id',
        how='left'
    ).rename(columns={'account_type': 'customer_account_type'})

    #7- Merge day info ---
    tr1 = tr1.merge(
        da[['date', 'day_name', 'is_weekend', 'is_holiday']],
        left_on='timestamp',
        right_on='date',
        how='left'
    ).drop(columns=['date'], errors='ignore')

    # 8- Merge stock info ---
    tr1 = tr1.merge(
        st[['stock_ticker', 'liquidity_tier', 'sector', 'industry']],
        on='stock_ticker',
        how='left'
    ).rename(columns={
        'liquidity_tier': 'stock_liquidity_tier',
        'sector': 'stock_sector',
        'industry': 'stock_industry'
    })

    # 9- Cleanup duplicated columns ---
    tr1.columns = tr1.columns.str.replace(r'_x$|_y$', '', regex=True)
    tr1 = tr1.loc[:, ~tr1.columns.duplicated()].copy()
    return tr1
## connecting to PGSQL
def export_to_postgres(df, table_name, username, password,host,port, database,if_exists='replace'):
    """
    Exports a pandas DataFrame to a PostgreSQL table using SQLAlchemy.
    
    Parameters:
        df (pd.DataFrame): DataFrame to export.
        table_name (str): Name of the table to write into PostgreSQL.
        username (str): PostgreSQL username (default: 'postgres').
        password (str): PostgreSQL password (default: '123456').
        host (str): Database host (default: 'localhost').
        port (str): Database port (default: '5432').
        database (str): Target database name (default: 'data_project').
        if_exists (str): What to do if the table already exists. 
                         Options: 'fail', 'replace', or 'append'.
    
    Returns:
        bool: True if export succeeds, False otherwise.
    """

    try:
        #1- Create connection string ---
        connection_string = f'postgresql://{username}:{password}@{host}:{port}/{database}'
        
        #2- Create SQLAlchemy engine ---
        engine = create_engine(connection_string)
        print(f"Connecting to PostgreSQL database '{database}'...")

        # 3- Export DataFrame ---
        df.to_sql(table_name, engine, index=False, if_exists=if_exists)
        print(f" Successfully exported DataFrame to table '{table_name}'.")

        #4- Close connection ---
        engine.dispose()
        print(" Connection closed.")
        return True

    except Exception as e:
        print(f" Error while exporting to PostgreSQL: {e}")
        return False
vg_handeled_missing=handle_missing_data(vg,tr)
vg_handeld_outliers, summary_outliers=handle_outliers_log(vg_handeled_missing,10)
vg_handeled_inconsistencies=handle_inconsistencies(vg_handeld_outliers,tr)
final_data_set=merge_full_data(tr,vg_handeled_inconsistencies,cu,da,st)
#export_to_postgres(final_data_set,"The fully dataset",'postgres','123456', 'postgres','5432','data_project_final_one')
## give first 10 columns as sampel
sample_df=final_data_set
sample_df.to_csv("sample_output.csv",index=False)
