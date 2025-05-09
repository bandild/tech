WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY transaction_id
           ORDER BY last_updated DESC
         ) AS rn
  FROM {{ source('public', 'STG_TRANSACTIONS') }}
  WHERE
    transaction_id IS NOT NULL
    AND customer_id IS NOT NULL
    AND amount >= 0
    AND TRIM(UPPER(transaction_status)) IN ('COMPLETED', 'FAILED')
)

SELECT
  transaction_id,
  customer_id,
  transaction_date,
  amount,
  merchant,
  category,
  transaction_type,
  TRIM(UPPER(transaction_status)) AS transaction_status,
  last_updated
FROM ranked
WHERE rn = 1
