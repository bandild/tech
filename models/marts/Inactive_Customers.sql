SELECT *
FROM {{ ref('customer_spending_summary') }}
WHERE DATEDIFF(DAY, last_transaction_date, CURRENT_DATE()) > 90
