use transactions_tables;
-- Customer_summary
CREATE OR REPLACE VIEW customer_summary AS

SELECT
    customer_id,

    -- Customer profile
    MAX(account_age_days) AS account_age_days,
    MAX(credit_score_band) AS credit_score_band,
    MAX(kyc_level) AS kyc_level,

    -- Transaction activity
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(transaction_amount),2) AS total_payment,
    ROUND(AVG(transaction_amount),2) AS average_payment,
    ROUND(AVG(avg_monthly_spend),2) AS avg_monthly_spent,

    -- Fraud metrics
    SUM(is_fraud) AS total_fraud_cases,
    ROUND(
        (SUM(is_fraud) * 100.0) /
        COUNT(transaction_id), 2
    ) AS fraud_rate_percent,

    ROUND(AVG(post_auth_risk_score),2)
        AS avg_post_auth_risk,

    MAX(post_auth_risk_score)
        AS highest_post_auth_risk,

    -- International behavior
    SUM(is_international)
        AS total_international_transactions,

    CASE
        WHEN SUM(is_international) > 0
        THEN 'Yes'
        ELSE 'No'
    END AS traveled_internationally,

    -- Customer behavior
    MAX(failed_txn_count_24h)
        AS max_failed_txn_per_day,

    ROUND(MAX(geo_distance_from_last_txn),2)
        AS max_geo_distance,

    MAX(transaction_amount)
        AS highest_transaction,

    ROUND(AVG(amount_deviation_from_user_mean),2)
        AS avg_spending_deviation,

    -- Time activity
    MAX(transaction_time)
        AS last_transaction_time,

    -- Highest fraud severity (business order)
    CASE
        WHEN MAX(
            CASE
                WHEN fraud_severity = 'Critical' THEN 4
                WHEN fraud_severity = 'High' THEN 3
                WHEN fraud_severity = 'Medium' THEN 2
                ELSE 1
            END
        ) = 4 THEN 'Critical'

        WHEN MAX(
            CASE
                WHEN fraud_severity = 'Critical' THEN 4
                WHEN fraud_severity = 'High' THEN 3
                WHEN fraud_severity = 'Medium' THEN 2
                ELSE 1
            END
        ) = 3 THEN 'High'

        WHEN MAX(
            CASE
                WHEN fraud_severity = 'Critical' THEN 4
                WHEN fraud_severity = 'High' THEN 3
                WHEN fraud_severity = 'Medium' THEN 2
                ELSE 1
            END
        ) = 2 THEN 'Medium'

        ELSE 'Low'
    END AS highest_fraud_severity,

    CASE
    WHEN MAX(
        CASE
            WHEN customer_tenure_segment = 'New Customer' THEN 1
            WHEN customer_tenure_segment = 'Growing Customer' THEN 2
            WHEN customer_tenure_segment = 'Loyal Customer' THEN 3
            WHEN customer_tenure_segment = 'Long-Term Customer' THEN 4
        END
    ) = 4 THEN 'Long-Term Customer'

    WHEN MAX(
        CASE
            WHEN customer_tenure_segment = 'New Customer' THEN 1
            WHEN customer_tenure_segment = 'Growing Customer' THEN 2
            WHEN customer_tenure_segment = 'Loyal Customer' THEN 3
            WHEN customer_tenure_segment = 'Long-Term Customer' THEN 4
        END
    ) = 3 THEN 'Loyal Customer'

    WHEN MAX(
        CASE
            WHEN customer_tenure_segment = 'New Customer' THEN 1
            WHEN customer_tenure_segment = 'Growing Customer' THEN 2
            WHEN customer_tenure_segment = 'Loyal Customer' THEN 3
            WHEN customer_tenure_segment = 'Long-Term Customer' THEN 4
        END
    ) = 2 THEN 'Growing Customer'

    ELSE 'New Customer'
END AS customer_tenure_segment,

    -- Highest velocity risk
    CASE
        WHEN MAX(
            CASE
                WHEN velocity_risk = 'Suspicious' THEN 3
                WHEN velocity_risk = 'Moderate' THEN 2
                ELSE 1
            END
        ) = 3 THEN 'Suspicious'

        WHEN MAX(
            CASE
                WHEN velocity_risk = 'Suspicious' THEN 3
                WHEN velocity_risk = 'Moderate' THEN 2
                ELSE 1
            END
        ) = 2 THEN 'Moderate'

        ELSE 'Normal'
    END AS highest_velocity_risk
    

FROM transactions_master
GROUP BY customer_id ;
 
 
-- fraud analysis
CREATE OR REPLACE VIEW fraud_analysis AS

SELECT
    -- IDs
    transaction_id,
    customer_id,
    merchant_id,

    -- Time
    transaction_time,
    hour,
    day_name,
    month_name,
    day_type,

    -- Transaction Details
    transaction_amount,
    transaction_size_segment,
    payment_channel,
    device_type,
    is_international,

    -- Fraud & Risk
    is_fraud,
    fraud_severity,
    risk_category,
    velocity_risk,
    international_risk_flag,
    merchant_risk_status,

    -- Risk Scores
    post_auth_risk_score,
    merchant_risk_score,
    ip_risk_score,

    -- Behavioral Signals
    txn_count_1h,
    txn_count_24h,
    failed_txn_count_24h,
    geo_distance_from_last_txn,
    amount_deviation_from_user_mean,
    spending_segment,

    -- Customer Segmentation
    customer_tenure_segment,
    credit_score_band,
    kyc_level

FROM transactions_master; 

-- Merchant_performance
CREATE OR REPLACE VIEW merchant_performance AS

SELECT
    merchant_id,

    -- Transaction KPIs
    COUNT(transaction_id) AS total_transactions,

    ROUND(SUM(transaction_amount),2)
        AS total_revenue,

    ROUND(AVG(transaction_amount),2)
        AS average_transaction_value,

    COUNT(DISTINCT customer_id)
        AS total_unique_customers,

    -- Fraud KPIs
    SUM(is_fraud)
        AS fraud_transactions,

    ROUND(
        (SUM(is_fraud) * 100.0) /
        COUNT(transaction_id),2
    ) AS fraud_rate_percent,

    -- Risk Metrics
    ROUND(AVG(merchant_risk_score),2)
        AS avg_merchant_risk_score,

    MAX(merchant_risk_score)
        AS max_merchant_risk_score,

    MAX(merchant_risk_status)
        AS merchant_risk_status,

    ROUND(AVG(post_auth_risk_score),2)
        AS avg_post_auth_risk,

    ROUND(AVG(ip_risk_score),2)
        AS avg_ip_risk_score,

    -- International Behavior
    SUM(is_international)
        AS international_transaction_count,

    -- Operational Metrics
    ROUND(AVG(failed_txn_count_24h),2)
        AS avg_failed_transactions,

    ROUND(AVG(geo_distance_from_last_txn),2)
        AS avg_geo_distance,

    -- Highest Fraud Severity
    CASE
        WHEN MAX(
            CASE
                WHEN fraud_severity = 'Critical' THEN 4
                WHEN fraud_severity = 'High' THEN 3
                WHEN fraud_severity = 'Medium' THEN 2
                ELSE 1
            END
        ) = 4 THEN 'Critical'

        WHEN MAX(
            CASE
                WHEN fraud_severity = 'Critical' THEN 4
                WHEN fraud_severity = 'High' THEN 3
                WHEN fraud_severity = 'Medium' THEN 2
                ELSE 1
            END
        ) = 3 THEN 'High'

        WHEN MAX(
            CASE
                WHEN fraud_severity = 'Critical' THEN 4
                WHEN fraud_severity = 'High' THEN 3
                WHEN fraud_severity = 'Medium' THEN 2
                ELSE 1
            END
        ) = 2 THEN 'Medium'

        ELSE 'Low'
    END AS highest_fraud_severity,

    -- Ranking
    RANK() OVER (
        ORDER BY SUM(transaction_amount) DESC
    ) AS merchant_revenue_rank

FROM transactions_master
GROUP BY merchant_id;

-- executive kpis
CREATE OR REPLACE VIEW executive_kpis AS

SELECT

    -- Financial KPIs
    COUNT(transaction_id)
        AS total_transactions,

    ROUND(SUM(transaction_amount),2)
        AS total_transaction_value,

    ROUND(AVG(transaction_amount),2)
        AS average_transaction_value,

    -- Fraud KPIs
    SUM(is_fraud)
        AS total_fraud_cases,

    ROUND(
        (SUM(is_fraud) * 100.0) /
        COUNT(transaction_id),2
    ) AS fraud_rate_percent,

    SUM(
        CASE
            WHEN fraud_severity = 'Critical'
            THEN 1
            ELSE 0
        END
    ) AS critical_transactions,

    SUM(
        CASE
            WHEN risk_category = 'High_risk'
            THEN 1
            ELSE 0
        END
    ) AS high_risk_transactions,

    -- Customer KPIs
    COUNT(DISTINCT customer_id)
        AS total_customers,

    ROUND(
        SUM(transaction_amount)
        /
        COUNT(DISTINCT customer_id),2
    ) AS avg_customer_spend,

    COUNT(
        DISTINCT CASE
            WHEN is_international = 1
            THEN customer_id
        END
    ) AS international_customers,

    -- Merchant KPIs
    COUNT(DISTINCT merchant_id)
        AS total_merchants,

    COUNT(
        DISTINCT CASE
            WHEN merchant_risk_status = 'High Risk'
            THEN merchant_id
        END
    ) AS high_risk_merchants,

    -- Most Used Payment Channel
    (
        SELECT payment_channel
        FROM transactions_master
        GROUP BY payment_channel
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_used_payment_channel,

    -- Peak Transaction Hour
    (
        SELECT hour
        FROM transactions_master
        where hour is not null
        GROUP BY hour
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS peak_transaction_hour,

    -- Peak Fraud Hour
    (
        SELECT hour
        FROM transactions_master
        WHERE is_fraud = 1 and hour is not null
        GROUP BY hour
        ORDER BY COUNT(is_fraud) DESC
        LIMIT 1
    ) AS peak_fraud_hour

FROM transactions_master;