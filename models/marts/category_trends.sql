
{{ config(
    materialized='view',
    alias='star_category_trends'
) }}

SELECT
  DATE_TRUNC('MONTH', tx.transaction_date) AS spend_month,
  tx.category,
  COUNT(tx.transaction_id) AS txn_count,
  ROUND(SUM(tx.amount), 2) AS total_spent,
  ROUND(AVG(tx.amount), 2) AS avg_txn_value

FROM {{ ref('fact_transactions') }} tx

WHERE tx.transaction_status = 'COMPLETED'

GROUP BY spend_month, tx.category
