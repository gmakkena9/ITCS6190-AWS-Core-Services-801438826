-- ============================================================
-- ITCS 6190/8190 - AWS Core Services Assignment
-- Athena SQL Queries (E-Commerce Sales Dataset)
-- Database: ecommerce_db
-- Table:    raw_data
-- ============================================================

-- Query 1: Basic Table Exploration
SELECT *
FROM ecommerce_db.raw_data
LIMIT 10;

-- Query 2: Orders by Product Category
SELECT
    category,
    COUNT(*) AS total_orders
FROM ecommerce_db.raw_data
GROUP BY category
ORDER BY total_orders DESC
LIMIT 10;

-- Query 3: Revenue and Quantity by Fulfilment Method
SELECT
    fulfilment                AS fulfilment_method,
    COUNT(*)                  AS total_orders,
    SUM(qty)                  AS total_units_sold,
    ROUND(SUM(amount), 2)     AS total_revenue
FROM ecommerce_db.raw_data
WHERE LOWER(status) NOT IN ('cancelled', 'pending', 'pending - waiting for pick up')
GROUP BY fulfilment
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 4: Monthly Sales Trend
SELECT
    date_trunc('month', date_parse(date, '%m-%d-%y')) AS sale_month,
    COUNT(*)                                            AS total_orders,
    ROUND(SUM(amount), 2)                               AS total_revenue
FROM ecommerce_db.raw_data
WHERE LOWER(status) NOT IN ('cancelled', 'pending', 'pending - waiting for pick up')
GROUP BY date_trunc('month', date_parse(date, '%m-%d-%y'))
ORDER BY sale_month ASC
LIMIT 10;

-- Query 5: Top 5 Best-Selling SKUs per Category
WITH ranked_skus AS (
    SELECT
        category,
        sku,
        ROUND(SUM(amount), 2) AS total_revenue,
        SUM(qty)               AS total_units_sold,
        RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(amount) DESC
        ) AS sku_rank
    FROM ecommerce_db.raw_data
    WHERE
        LOWER(status) NOT IN ('cancelled', 'pending', 'pending - waiting for pick up')
        AND qty > 0
    GROUP BY category, sku
)
SELECT
    category,
    sku,
    total_revenue,
    total_units_sold,
    sku_rank AS rank
FROM ranked_skus
WHERE sku_rank <= 5
ORDER BY category, sku_rank
LIMIT 10;
