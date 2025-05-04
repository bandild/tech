{{ config(materialized='view', alias='star_customer_monthly_spending') }}

SELECT
  cu.customer_id,
  cu.first_name,
  cu.age,
  cu.account_status,
  ac.account_type,
  ac.balance_segment,
  DATE_TRUNC('MONTH', tx.transaction_date) AS spend_month,
  COUNT(tx.transaction_id) AS txn_count,
  ROUND(SUM(tx.amount) , 2 ) AS total_spent,
  Round(AVG(tx.amount) , 2)  AS avg_txn_value,
  MAX(tx.amount) AS max_txn

FROM {{ ref('fact_transactions') }} tx
LEFT JOIN {{ ref('dim_customers') }} cu ON tx.customer_id = cu.customer_id 
LEFT JOIN {{ ref('dim_accounts') }} ac ON tx.customer_id = ac.customer_id  

WHERE tx.transaction_status = 'COMPLETED' AND cu.customer_id IS NOT NULL
GROUP BY cu.customer_id, cu.first_name, cu.age, cu.account_status,
         ac.account_type, ac.balance_segment, spend_month













models
/
marts
/
customer_monthly_spending.sql

Save
910118121314151617181920212223
  COUNT(tx.transaction_id) AS txn_count,
  SUM(tx.amount) AS total_spent,
  AVG(tx.amount) AS avg_txn_value,
  MAX(tx.amount) AS max_txn

FROM {{ ref('fact_transactions') \}\} tx
LEFT JOIN {{ ref('dim_customers') \}\} cu ON tx.customer_id = cu.customer_id 
LEFT JOIN {{ ref('dim_accounts') \}\} ac ON tx.customer_id = ac.customer_id  

WHERE tx.transaction_status = 'COMPLETED' AND cu.customer_id IS NOT NULL

3SELECT

Enter dbt command
dbt build --select <model_name>
$0