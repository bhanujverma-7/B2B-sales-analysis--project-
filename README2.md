# B2B Sales & Customer Purchase Analytics 🛒
> An end-to-end analytics project analyzing Business to Business sales, customer purchasing behaviour from the commencement of business of the company till last financial year.

> Revenue, profitability, and product performance using Python,
> PostgreSQL, and Power BI.

- Python - For data cleaning and preprocessing as multiple sheets with different data were given.

- PostgreSQL - To answer major business problem questions that lead to finding solutions and take decisions for upcoming years.

- Power BI - Shows visual representation of the statistics and comparisons between data to understand the intensity of any problem, ultimately leading to decision making.

## Business Problem

There was a need to understand the trends and statistics of business from commencing year till last year, to get a consolidated view
of customer purchasing behavior, revenue trends, and product profitability.

**The analysis aims to answer:**

 Which customers generate the most revenue and most profit?

- Accordingly, customers can be classified for VIP programs, special benefits and for recommendations.

Which products contribute most to revenue and which the least?

- For specifying marketing techniques and bundling of productsfor schemes.

 Which regions perform better, also high revenue/low profit regions and vice-versa?

- To identify patterns and causes of sales like population, median income etc.

 Are sales driven by recurring customers or one-time bulk purchases?

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
|**Python**| Data cleaning, transformation, manipulation and EDA | 
| **Power BI Desktop** | 5-page interactive dashboard — DAX, measures, field parameters, Power Query|
| **PostgreSQL** | SQL analysis and aggregation |

## Dataset

The dataset contains B2B sales transactions from 2022–2025.
There are **30 distinct products** divided into 5 categories,distributed to **175 MNCs** in this period.

### INFO
- Rows: 64,104
- Columns: 21
- Period: Jan 2022 – Dec 2025
- Granularity: One row represents an order line


## Project Workflow

Excel files with multiple sheets

             ↓

Python
(Data Cleaning + Transformation + EDA)

             ↓

PostgreSQL
(Data Storage + SQL Analysis)
 
             ↓

Power BI
(Data Modeling + Visualization)
 
             ↓

Business Insights & Recommendations

## Python — Data Cleaning & Feature Engineering

This notebook prepares the B2B sales dataset for further analysis using **Python and Pandas**. The main objective is to transform the raw multi-table Excel dataset into a clean, analysis-ready sales dataset that can later be used with **PostgreSQL and Power BI**.

### What This Notebook Does

#### 1. Data Import & Initial Inspection

* Imports the sales Excel workbook using Pandas.
* Loads the relevant sheets:

  * Sales Orders
  * Customers
  * Regions
  * Products
  * State Regions
* Inspects dataframe structure, columns, data types, and sample records.
* Converts the order date into a standardized datetime format.

#### 2. Data Cleaning

The dataset is checked and prepared for analysis by:

* Checking missing/null values.
* Standardizing the tables so that they can be merged. 
* Removing unnecessary columns.

* Converting column names to lowercase.

* Renaming columns to more descriptive for better understanding.
  The resulting sales dataframe contains **18 core columns** before additional engineered features are added.

#### 3. Data Integration

Multiple tables are combined using `merge()` operation.

Final table consists:-

* Customer information
* Product and category information
* Delivery-region information
* State information
* Regional classification
* Population and median-income information
* Warehouse information

#### 4. Feature Engineering

Additional business metrics are created from the existing fields:

| Feature            | Calculation                         | Purpose                                    |
| ------------------ | ----------------------------------- | ------------------------------------------ |
| `total_mfg_cost`   | Manufacturing Cost × Order Quantity | Total cost of fulfilling an order          |
| `profit`           | Revenue − Total Manufacturing Cost  | Measures order-level profitability         |
| `profit_margin(%)` | Profit ÷ Revenue × 100              | Measures profitability relative to revenue |



* `Previous_Purchase_Date`
* `Gap_Days`

These are calculated by sorting transactions by customer and date and using `groupby()` with `shift()` to identify the previous purchase.

A customer-level summary is then created containing:

* Total orders
* Average gap between purchases
* Minimum purchase gap
* Maximum purchase gap

These coumns calculates an overall average purchase gap of approximately **4.24 days** across the customer summaries.

#### 5. Export & Database Preparation

The cleaned dataframe is exported for further use and prepared for integration with **PostgreSQL** using:

* `psycopg`
* SQLAlchemy
* Pandas `to_sql()`

The dataframe is intended to be loaded into a PostgreSQL `sales` table for subsequent SQL analysis and dashboard development.

## 📊 Dashboard Pages

### Page 1 — Home
![HOME](DB_SS/Capture0.png)
Navigation landing page with links to all pages.

### Page 2 — Executive Summary
![Executive Overview](DB_SS/Capture.png)

### Page 3 — Customer Analysis
![Customer Analysis](DB_SS/Capture2.5.png)

### Page 4 — Revenue/Profit Analysis
![Revenue/Profit Analysis](DB_SS/Capture2.png)
