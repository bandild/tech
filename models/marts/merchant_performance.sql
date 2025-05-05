{{ config(materialized='view', alias='star_merchant_performance') }}

SELECT
  tx.merchant,
  tx.category,
  COUNT(tx.transaction_id) AS total_transactions,
  ROUND(SUM(tx.amount),2) AS total_revenue,
  ROUND(AVG(tx.amount),2) AS avg_txn_value,
  COUNT(DISTINCT tx.customer_id) AS unique_customers,
  MAX(tx.transaction_date) AS last_active_date

FROM {{ ref('fact_transactions') }} tx
WHERE tx.transaction_status = 'COMPLETED'
GROUP BY tx.merchant, tx.category
