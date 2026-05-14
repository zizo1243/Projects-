# 📘 Dataset Description: Final Merged Trades and Stock Data

This dataset represents the cleaned, merged, and processed stock trading information combining customer transactions and stock metadata.  
Each column below is described in one concise sentence.

---

### 🧩 Column Descriptions

- **transaction_id**: A unique identifier assigned to each trade transaction.
- **timestamp**: The exact date and time when the transaction occurred.
- **customer_id**: The unique ID of the customer who executed the trade.
- **stock_ticker**: The symbol representing the traded stock (e.g., AAPL, MSFT).
- **transaction_type**: Indicates whether the trade was a ‘BUY’ or ‘SELL’ operation.
- **quantity**: The number of stock units bought or sold in the transaction.
- **average_trade_size**: The average value of trades made by the customer on that day.
- **cumulative_portfolio_value**: The total value of a customer’s portfolio after this transaction.
- **stock_price**: The market price of the stock at the time of the transaction.
- **total_trade_amount**: The total monetary value of the transaction (quantity × stock price).
- **customer_account_type**: The type of customer account, such as “retail” or “institutional”.
- **day_name**: The name of the day when the trade took place (e.g., Monday, Friday).
- **is_weekend**: Boolean value indicating whether the trade occurred on a weekend.
- **is_holiday**: Boolean value indicating whether the trade date coincided with a public holiday.
- **stock_liquidity_tier**: The liquidity classification of the stock (e.g., High, Medium, Low).
- **stock_sector**: The economic sector to which the stock belongs (e.g., Technology, Healthcare).
- **stock_industry**: The specific industry category within the broader sector (e.g., Semiconductors, Banking).

---

### 🧠 Prompt Used to Generate This Document

> “Generate a dataset description document for the following dataframe columns, each described in one sentence:
> ['transaction_id', 'timestamp', 'customer_id', 'stock_ticker', 'transaction_type', 'quantity', 'average_trade_size', 'cumulative_portfolio_value', 'stock_price', 'total_trade_amount', 'customer_account_type', 'day_name', 'is_weekend', 'is_holiday', 'stock_liquidity_tier', 'stock_sector', 'stock_industry']”

---

### ✅ Output Generated Using
AI Tool: **ChatGPT (GPT-5)**  
Purpose: To automatically generate concise, clear metadata for the final dataset used in the ETL pipeline.

---
