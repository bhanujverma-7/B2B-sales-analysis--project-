-- ============================================================
-- B2B Sales Analysis — PostgreSQL
-- Purpose: Business-focused analysis of revenue, profit,
--          customers, products, regions, and growth.
-- ============================================================

-- ============================================================
-- 0. DATA PREVIEW
-- ============================================================
SELECT *
FROM sales;


-- ============================================================
-- 1. CUSTOMER ANALYSIS
-- ============================================================

-- 1.1 Top Customers by Revenue, Profit and Average Margin
SELECT
    customer_name,
    SUM("revenue(USD)") AS revenue,
    SUM(profit) AS total_profit,
    AVG("profit_margin(%)") AS avg_profit_margin
FROM sales
GROUP BY customer_name
ORDER BY revenue DESC;


-- 1.2 Top 5 Customers by Profit
SELECT
    customer_name,
    SUM(profit) AS total_profit
FROM sales
GROUP BY customer_name
ORDER BY total_profit DESC
LIMIT 5;


-- 1.3 Customer Purchase Frequency and Revenue
SELECT
    customer_name,
    COUNT(DISTINCT orderdate) AS purchase_days,
    SUM("revenue(USD)") AS revenue
FROM sales
GROUP BY customer_name
ORDER BY purchase_days DESC, revenue DESC;


-- 1.4 Top 10 Customers by Share of Total Revenue
WITH customer_revenue AS (
    SELECT
        customer_name,
        SUM("revenue(USD)") AS revenue
    FROM sales
    GROUP BY customer_name
)
SELECT
    customer_name,
    revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM customer_revenue
ORDER BY revenue_share_pct DESC
LIMIT 10;


-- ============================================================
-- 2. PRODUCT ANALYSIS
-- ============================================================

-- 2.1 Top 10 Products by Average Revenue and Profit Margin
SELECT
    product_name,
    AVG("revenue(USD)") AS avg_revenue,
    AVG("profit_margin(%)") AS avg_profit_margin
FROM sales
GROUP BY product_name
ORDER BY avg_revenue DESC, avg_profit_margin DESC
LIMIT 10;


-- 2.2 Revenue Contribution by Product
SELECT
    product_name,
    SUM("revenue(USD)") AS revenue,
    ROUND(
        SUM("revenue(USD)") * 100.0
        / SUM(SUM("revenue(USD)")) OVER (),
        2
    ) AS revenue_contribution_pct
FROM sales
GROUP BY product_name
ORDER BY revenue_contribution_pct DESC;


-- 2.3 Revenue Concentration by Product
WITH product_revenue AS (
    SELECT
        product_name,
        SUM("revenue(USD)") AS revenue
    FROM sales
    GROUP BY product_name
),
ranked_products AS (
    SELECT
        product_name,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM product_revenue
)
SELECT
    product_name,
    revenue,
    ROUND(
        cumulative_revenue * 100.0 / total_revenue,
        2
    ) AS cumulative_revenue_pct
FROM ranked_products
ORDER BY revenue DESC;


-- ============================================================
-- 3. REGIONAL & GEOGRAPHIC ANALYSIS
-- ============================================================

-- 3.1 Revenue by Region
SELECT
    region,
    SUM("revenue(USD)") AS revenue
FROM sales
GROUP BY region
ORDER BY revenue DESC;


-- 3.2 Revenue per Capita by State
SELECT
    state,
    SUM("revenue(USD)") / NULLIF(AVG(population), 0) AS revenue_per_capita
FROM sales
GROUP BY state
ORDER BY revenue_per_capita DESC;


-- 3.3 Top Product in Every State by Revenue
WITH product_sales AS (
    SELECT
        state,
        product_name,
        SUM("revenue(USD)") AS revenue,
        RANK() OVER (
            PARTITION BY state
            ORDER BY SUM("revenue(USD)") DESC
        ) AS rank
    FROM sales
    GROUP BY state, product_name
)
SELECT
    state,
    product_name,
    revenue
FROM product_sales
WHERE rank = 1
ORDER BY state;


-- 3.4 Top 5 Products in Each Region by Revenue
WITH regional_products AS (
    SELECT
        region,
        product_name,
        SUM("revenue(USD)") AS revenue,
        SUM(profit) AS profit,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY SUM("revenue(USD)") DESC
        ) AS rank
    FROM sales
    GROUP BY region, product_name
)
SELECT
    rank,
    region,
    product_name,
    revenue,
    profit
FROM regional_products
WHERE rank <= 5
ORDER BY region, rank;


-- 3.5 Product Performance Across Regions
SELECT
    product_name,
    region,
    SUM("revenue(USD)") AS revenue,
    SUM(profit) AS profit
FROM sales
GROUP BY product_name, region
ORDER BY product_name, revenue DESC;


-- ============================================================
-- 4. TIME-SERIES & GROWTH ANALYSIS
-- ============================================================

-- 4.1 Running Monthly Revenue
SELECT
    DATE_TRUNC('month', orderdate) AS month,
    ROUND(SUM("revenue(USD)")::numeric, 0) AS revenue,
    ROUND(
        SUM(SUM("revenue(USD)")) OVER (
            ORDER BY DATE_TRUNC('month', orderdate)
        )::numeric,
        0
    ) AS running_revenue
FROM sales
GROUP BY 1
ORDER BY 1;


-- 4.2 Month-over-Month Revenue Growth
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', orderdate) AS month,
        SUM("revenue(USD)") AS revenue
    FROM sales
    GROUP BY 1
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(
        (
            (revenue - LAG(revenue) OVER (ORDER BY month))
            * 100.0
            / NULLIF(LAG(revenue) OVER (ORDER BY month), 0)
        )::numeric,
        2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY month;


-- 4.3 Year-over-Year Revenue Performance by State
WITH yearly_sales AS (
    SELECT
        state,
        EXTRACT(YEAR FROM orderdate) AS year,
        SUM("revenue(USD)") AS revenue
    FROM sales
    GROUP BY state, year
),
sales_with_previous AS (
    SELECT
        state,
        year,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY state
            ORDER BY year
        ) AS previous_year_revenue
    FROM yearly_sales
)
SELECT
    state,
    year,
    revenue,
    previous_year_revenue,
    revenue - previous_year_revenue AS revenue_difference,
    ROUND(
        (
            (revenue - previous_year_revenue)
            * 100.0
            / NULLIF(previous_year_revenue, 0)
        )::numeric,
        2
    ) AS yoy_growth_pct
FROM sales_with_previous
ORDER BY state, year;
