{{ config(
    materialized='view',
    alias='customer_spending_summary'
) }}

SELECT
  cu.customer_id,
  cu.first_name,
  cu.last_name,
  cu.age,
  cu.account_status AS customer_status,
  cu.account_age_days,

  COUNT(tx.transaction_id) AS total_transactions,
  ROUND(SUM(tx.amount),2) AS total_spent,
  ROUND(AVG(tx.amount),2 ) AS avg_transaction_value,
  MAX(tx.amount) AS max_transaction_value,
  MIN(tx.amount) AS min_transaction_value,

  COUNT(DISTINCT tx.merchant) AS unique_merchants,
  COUNT(DISTINCT tx.category) AS unique_categories,

  MAX(tx.transaction_date) AS last_transaction_date,
  CURRENT_DATE() AS snapshot_date

FROM {{ ref('fact_transactions') }} tx
LEFT JOIN {{ ref('dim_customers') }} cu
  ON tx.customer_id = cu.customer_id

WHERE tx.transaction_status = 'COMPLETED' and cu.customer_id IS NOT NULL

GROUP BY
  cu.customer_id,
  cu.first_name,
  cu.last_name,
  cu.age,
  cu.account_status,
  cu.account_age_days
