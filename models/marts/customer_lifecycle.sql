{{ config(materialized='view', alias='star_customer_lifecycle') }}

SELECT
  cu.customer_id,
  cu.first_name,
  cu.age,
  cu.account_open_date,
  cu.account_age_days,
  ac.account_type,
  COUNT(tx.transaction_id) AS total_txns,
  SUM(tx.amount) AS total_spent,
  MAX(tx.transaction_date) AS last_txn_date

FROM {{ ref('dim_customers') }} cu
LEFT JOIN {{ ref('dim_accounts') }} ac ON cu.customer_id = ac.customer_id
LEFT JOIN {{ ref('fact_transactions') }} tx ON cu.customer_id = tx.customer_id
GROUP BY cu.customer_id, cu.first_name, cu.age, cu.account_open_date,
         cu.account_age_days, ac.account_type
