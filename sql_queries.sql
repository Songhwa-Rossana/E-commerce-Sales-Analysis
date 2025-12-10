-- ============================================================================
-- E-COMMERCE SALES ANALYSIS - SQL QUERIES
-- ============================================================================
-- Author: Songhwa-RossanaFile
-- Date: December 2025
-- Purpose: Demonstrate SQL skills for data extraction and analysis
-- ============================================================================

-- QUERY 1: Basic Revenue Analysis by Product
-- Returns top 20 products by total revenue
-- ============================================================================
SELECT 
    product_id,
    product_name,
    category,
    price,
    review_score,
    (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
     sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
     sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_sales,
    price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
             sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
             sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_revenue
FROM ecommerce_sales
ORDER BY total_revenue DESC
LIMIT 20;


-- QUERY 2: Category Performance Summary with Aggregations
-- Shows comprehensive metrics for each category
-- ============================================================================
SELECT 
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(review_count), 0) AS avg_review_count,
    SUM(sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
        sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
        sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_units_sold,
    ROUND(SUM(price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                       sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                       sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12)), 2) AS total_revenue
FROM ecommerce_sales
GROUP BY category
ORDER BY total_revenue DESC;


-- QUERY 3: Monthly Sales Trend Analysis
-- Pivots data to show sales by month across all products
-- ============================================================================
SELECT 
    'Month 1' AS month, SUM(sales_month_1) AS total_sales UNION ALL
SELECT 'Month 2', SUM(sales_month_2) FROM ecommerce_sales UNION ALL
SELECT 'Month 3', SUM(sales_month_3) FROM ecommerce_sales UNION ALL
SELECT 'Month 4', SUM(sales_month_4) FROM ecommerce_sales UNION ALL
SELECT 'Month 5', SUM(sales_month_5) FROM ecommerce_sales UNION ALL
SELECT 'Month 6', SUM(sales_month_6) FROM ecommerce_sales UNION ALL
SELECT 'Month 7', SUM(sales_month_7) FROM ecommerce_sales UNION ALL
SELECT 'Month 8', SUM(sales_month_8) FROM ecommerce_sales UNION ALL
SELECT 'Month 9', SUM(sales_month_9) FROM ecommerce_sales UNION ALL
SELECT 'Month 10', SUM(sales_month_10) FROM ecommerce_sales UNION ALL
SELECT 'Month 11', SUM(sales_month_11) FROM ecommerce_sales UNION ALL
SELECT 'Month 12', SUM(sales_month_12) FROM ecommerce_sales
ORDER BY month;


-- QUERY 4: Review Score Impact Analysis
-- Compares sales performance across different review score segments
-- ============================================================================
SELECT 
    CASE 
        WHEN review_score >= 4.5 THEN 'Excellent (4.5-5.0)'
        WHEN review_score >= 3.5 THEN 'Good (3.5-4.4)'
        WHEN review_score >= 2.5 THEN 'Fair (2.5-3.4)'
        ELSE 'Poor (1. 0-2.4)'
    END AS review_segment,
    COUNT(*) AS product_count,
    ROUND(AVG(sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
              sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
              sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12), 0) AS avg_total_sales,
    ROUND(AVG(price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                       sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                       sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12)), 2) AS avg_revenue
FROM ecommerce_sales
GROUP BY review_segment
ORDER BY avg_revenue DESC;


-- QUERY 5: Top Performers by Category (Using Window Functions)
-- Identifies top 3 products within each category by revenue
-- ============================================================================
WITH product_revenue AS (
    SELECT 
        product_id,
        product_name,
        category,
        price,
        review_score,
        price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                 sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                 sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY 
            price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                     sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                     sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) DESC) AS rank_in_category
    FROM ecommerce_sales
)
SELECT 
    category,
    product_name,
    ROUND(total_revenue, 2) AS total_revenue,
    review_score,
    rank_in_category
FROM product_revenue
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;


-- QUERY 6: Underperforming Products Identification
-- Finds products in bottom 25% of revenue for potential action
-- ============================================================================
WITH revenue_quartiles AS (
    SELECT 
        product_id,
        product_name,
        category,
        price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                 sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                 sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_revenue,
        NTILE(4) OVER (ORDER BY 
            price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                     sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                     sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12)) AS revenue_quartile
    FROM ecommerce_sales
)
SELECT 
    category,
    COUNT(*) AS underperformer_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue_at_risk,
    ROUND(AVG(total_revenue), 2) AS avg_revenue
FROM revenue_quartiles
WHERE revenue_quartile = 1
GROUP BY category
ORDER BY underperformer_count DESC;


-- QUERY 7: Price Optimization Analysis
-- Analyzes average sales by price ranges within each category
-- ============================================================================
SELECT 
    category,
    CASE 
        WHEN price < 100 THEN 'Budget (<$100)'
        WHEN price BETWEEN 100 AND 300 THEN 'Mid-Range ($100-$300)'
        ELSE 'Premium (>$300)'
    END AS price_segment,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
              sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
              sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12), 0) AS avg_total_sales
FROM ecommerce_sales
GROUP BY category, price_segment
ORDER BY category, avg_total_sales DESC;


-- QUERY 8: Seasonal Performance by Category
-- Identifies peak months for each category
-- ============================================================================
WITH monthly_category_sales AS (
    SELECT category, 'Jan' AS month, SUM(sales_month_1) AS sales FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Feb', SUM(sales_month_2) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Mar', SUM(sales_month_3) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Apr', SUM(sales_month_4) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'May', SUM(sales_month_5) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Jun', SUM(sales_month_6) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Jul', SUM(sales_month_7) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Aug', SUM(sales_month_8) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Sep', SUM(sales_month_9) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Oct', SUM(sales_month_10) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Nov', SUM(sales_month_11) FROM ecommerce_sales GROUP BY category
    UNION ALL
    SELECT category, 'Dec', SUM(sales_month_12) FROM ecommerce_sales GROUP BY category
),
ranked_months AS (
    SELECT 
        category,
        month,
        sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS month_rank
    FROM monthly_category_sales
)
SELECT 
    category,
    month AS peak_month,
    sales AS peak_sales
FROM ranked_months
WHERE month_rank = 1
ORDER BY sales DESC;


-- QUERY 9: Product Performance Matrix (Stars, Cash Cows, etc.)
-- BCG Matrix style analysis
-- ============================================================================
WITH product_metrics AS (
    SELECT 
        product_id,
        product_name,
        category,
        review_score,
        price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                 sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                 sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_revenue
    FROM ecommerce_sales
),
medians AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_revenue) AS median_revenue,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY review_score) AS median_review
    FROM product_metrics
)
SELECT 
    pm.category,
    CASE 
        WHEN pm. total_revenue > m.median_revenue AND pm.review_score > m. median_review THEN 'Star'
        WHEN pm.total_revenue <= m.median_revenue AND pm. review_score > m.median_review THEN 'Question Mark'
        WHEN pm.total_revenue > m.median_revenue AND pm. review_score <= m.median_review THEN 'Cash Cow'
        ELSE 'Dog'
    END AS performance_segment,
    COUNT(*) AS product_count,
    ROUND(AVG(pm.total_revenue), 2) AS avg_revenue,
    ROUND(AVG(pm.review_score), 2) AS avg_review_score
FROM product_metrics pm
CROSS JOIN medians m
GROUP BY pm.category, performance_segment
ORDER BY pm.category, product_count DESC;


-- QUERY 10: Revenue Growth Opportunity Analysis
-- Identifies categories and products with highest growth potential
-- ============================================================================
WITH product_performance AS (
    SELECT 
        product_id,
        product_name,
        category,
        price,
        review_score,
        review_count,
        (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
         sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
         sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_sales,
        price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                 sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                 sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) AS total_revenue
    FROM ecommerce_sales
)
SELECT 
    product_name,
    category,
    ROUND(total_revenue, 2) AS current_revenue,
    review_score,
    review_count,
    CASE 
        WHEN review_score >= 4 AND review_count < 500 THEN 'Get more reviews'
        WHEN review_score < 3.5 AND total_sales > 5000 THEN 'Improve product quality'
        WHEN price < 100 AND review_score >= 4.5 THEN 'Test price increase'
        WHEN total_sales < 3000 THEN 'Marketing boost needed'
        ELSE 'Performing well'
    END AS growth_opportunity,
    CASE 
        WHEN review_score >= 4 AND review_count < 500 THEN ROUND(total_revenue * 1.10, 2)
        WHEN review_score < 3.5 AND total_sales > 5000 THEN ROUND(total_revenue * 1.15, 2)
        WHEN price < 100 AND review_score >= 4.5 THEN ROUND(total_revenue * 1.08, 2)
        ELSE total_revenue
    END AS potential_revenue
FROM product_performance
WHERE total_revenue > 1000  -- Focus on products with meaningful revenue
ORDER BY (potential_revenue - total_revenue) DESC
LIMIT 30;


-- QUERY 11: Customer Review Velocity Analysis
-- Analyzes relationship between review count and sales velocity
-- ============================================================================
SELECT 
    CASE 
        WHEN review_count < 100 THEN 'Low (<100)'
        WHEN review_count BETWEEN 100 AND 500 THEN 'Medium (100-500)'
        WHEN review_count BETWEEN 501 AND 800 THEN 'High (501-800)'
        ELSE 'Very High (>800)'
    END AS review_volume,
    COUNT(*) AS product_count,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG((sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
               sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
               sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) / 12. 0), 0) AS avg_monthly_sales,
    ROUND(AVG(price * (sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + 
                       sales_month_5 + sales_month_6 + sales_month_7 + sales_month_8 + 
                       sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12)), 2) AS avg_total_revenue
FROM ecommerce_sales
GROUP BY review_volume
ORDER BY avg_total_revenue DESC;


-- QUERY 12: Year-over-Year Style Comparison (First Half vs Second Half)
-- Compares H1 and H2 performance
-- ============================================================================
SELECT 
    category,
    SUM(sales_month_1 + sales_month_2 + sales_month_3 + 
        sales_month_4 + sales_month_5 + sales_month_6) AS h1_sales,
    SUM(sales_month_7 + sales_month_8 + sales_month_9 + 
        sales_month_10 + sales_month_11 + sales_month_12) AS h2_sales,
    ROUND(
        ((SUM(sales_month_7 + sales_month_8 + sales_month_9 + sales_month_10 + sales_month_11 + sales_month_12) - 
          SUM(sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + sales_month_5 + sales_month_6)) * 100.0 / 
         NULLIF(SUM(sales_month_1 + sales_month_2 + sales_month_3 + sales_month_4 + sales_month_5 + sales_month_6), 0)), 
    2) AS growth_percentage
FROM ecommerce_sales
GROUP BY category
ORDER BY growth_percentage DESC;
