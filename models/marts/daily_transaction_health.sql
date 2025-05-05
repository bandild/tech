{{ config(materialized='view', alias='star_daily_transaction_health') }}

SELECT
  DATE(tx.transaction_date) AS txn_day,
  COUNT(*) AS txn_count,
  SUM(tx.amount) AS total_volume,
  COUNT_IF(tx.is_negative_amount = 1) AS negative_txns,
  COUNT_IF(tx.transaction_status = 'FAILED') AS failed_txns

FROM {{ ref('fact_transactions') }} tx
GROUP BY txn_day
