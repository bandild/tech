WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY account_id
           ORDER BY last_updated DESC
         ) AS rn
  FROM {{ source('public', 'STG_ACCOUNTS') }}
  WHERE
    account_id IS NOT NULL
    AND customer_id IS NOT NULL
    AND TRIM(UPPER(account_type)) IN ('CHECKING', 'SAVINGS')
    AND balance >= 0
    AND last_transaction_date IS NOT NULL
    AND TRIM(UPPER(account_status)) IN ('ACTIVE', 'INACTIVE')
)

SELECT
  account_id,
  customer_id,
  TRIM(UPPER(account_type)) AS account_type,
  ROUND(balance, 2) AS balance,
  last_transaction_date,
  TRIM(UPPER(account_status)) AS account_status,
  last_updated
FROM ranked
WHERE rn = 1
