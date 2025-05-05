SELECT *
FROM {{ ref('customer_spending_summary') }}
WHERE total_spent > 10000 OR avg_transaction_value > 500
