{{ config(
    materialized='incremental',
    unique_key='customer_id',
    alias='dim_customers'
) }}

WITH ranked AS (
  SELECT *,
         DATEDIFF(YEAR, DOB, CURRENT_DATE()) AS age,
         DATEDIFF(DAY, ACCOUNT_OPEN_DATE, CURRENT_DATE()) AS account_age_days,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY last_updated DESC) AS rn
  FROM {{ ref('stg_customers_clean') }}

  {% if is_incremental() %}
    WHERE last_updated > (SELECT COALESCE(MAX(last_updated), '1900-01-01') FROM {{ this }})
  {% endif %}
),

final AS (
  SELECT
    customer_id,
    INITCAP(first_name) AS first_name,
    INITCAP(last_name) AS last_name,
    LOWER(email) AS email,
    phone_cleaned AS phone,
    dob,
    account_open_date,
    age,
    account_age_days,
    TRIM(UPPER(account_status)) AS account_status,
    last_updated,
    CURRENT_TIMESTAMP() AS load_timestamp,
    '{{ invocation_id }}' AS batch_id
  FROM ranked
  WHERE rn = 1
)

SELECT * FROM final
