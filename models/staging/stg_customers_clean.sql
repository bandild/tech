WITH ranked AS (
  SELECT *,
         REGEXP_REPLACE(phone, '[^0-9]', '') AS phone_cleaned,
         ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY last_updated DESC
         ) AS rn
  FROM {{ source('public', 'STG_CUSTOMERS') }}
  WHERE
    customer_id IS NOT NULL
    AND first_name IS NOT NULL
    AND last_name IS NOT NULL
    AND email IS NOT NULL
    AND dob IS NOT NULL
    AND LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 10 AND 12
    AND TRIM(UPPER(account_status)) IN ('ACTIVE', 'INACTIVE')
)

SELECT
  customer_id,
  INITCAP(first_name) AS first_name,
  INITCAP(last_name) AS last_name,
  LOWER(email) AS email,
  phone_cleaned,
  dob,
  account_open_date,
  TRIM(UPPER(account_status)) AS account_status,
  last_updated
FROM ranked
WHERE rn = 1
