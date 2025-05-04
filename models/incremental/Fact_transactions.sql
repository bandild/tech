{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    alias='fact_transactions'
) }}

WITH incremental AS (
  SELECT
    transaction_id,
    customer_id,
    transaction_date,
    ROUND(amount, 2) AS amount,
    INITCAP(merchant) AS merchant,
    INITCAP(category) AS category,
    TRIM(UPPER(transaction_type)) AS transaction_type,
    TRIM(UPPER(transaction_status)) AS transaction_status,
    IFF(amount < 0, 1, 0) AS is_negative_amount,
    IFF(amount > 1000, 1, 0) AS is_high_value_txn,
    WEEK(transaction_date) AS transaction_week,
    MONTH(transaction_date) AS transaction_month,
    last_updated,
    ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY last_updated DESC) AS rn
  FROM {{ ref('stg_transactions_clean') }}

  {% if is_incremental() %}
    WHERE last_updated > (SELECT COALESCE(MAX(last_updated), '1900-01-01') FROM {{ this }})
  {% endif %}
),

final2 AS (
  SELECT
    transaction_id,
    customer_id,
    transaction_date,
    amount,
    merchant,
    category,
    transaction_type,
    transaction_status,
    is_negative_amount,
    is_high_value_txn,
    transaction_week,
    transaction_month,
    last_updated,
    CURRENT_TIMESTAMP() AS load_timestamp,
    '{{ invocation_id }}' AS batch_id
  FROM incremental
  WHERE rn = 1
)

SELECT * FROM final2
