{{ config(
    materialized='incremental',
    unique_key='account_id',
    alias='dim_accounts'
) }}

WITH incremental AS (
  SELECT *,
        
         DATEDIFF(DAY, last_transaction_date, CURRENT_DATE()) AS days_since_last_txn,
         CASE
           WHEN balance < 0 THEN 'NEGATIVE'
           WHEN balance BETWEEN 0 AND 500 THEN 'LOW'
           WHEN balance BETWEEN 500 AND 5000 THEN 'MEDIUM'
           ELSE 'HIGH'
         END AS balance_segment,
         ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY last_updated DESC) AS rn
  FROM {{ ref('stg_accounts_clean') }}

  {% if is_incremental() %}
    WHERE last_updated > (SELECT COALESCE(MAX(last_updated), '1900-01-01') FROM {{ this }})
  {% endif %}
),

final1 AS (
  SELECT
    account_id,
    customer_id,
    INITCAP(account_type) AS account_type,
    ROUND(balance, 2) AS balance,
    last_transaction_date,
    TRIM(UPPER(account_status)) AS account_status,
    days_since_last_txn,
    balance_segment,
    last_updated,
    CURRENT_TIMESTAMP() AS load_timestamp,
    '{{ invocation_id }}' AS batch_id
  FROM incremental
  WHERE rn = 1
)

SELECT * FROM final1
