# Week 1

## How many users do we have?
130

```
SELECT COUNT(user_id)
FROM dbt_biandamuthiagmailcom.stg_users
```

## On average, how many orders do we receive per hour? 
7.5 orders

```
SELECT 
    AVG(order_per_hour_daily) AS avg_order_per_hour
FROM (
SELECT 
    DATE(created_at) AS order_date 
    , HOUR(created_at) AS order_hour 
    , COUNT(order_id) AS order_per_hour_daily
FROM dbt_biandamuthiagmailcom.stg_orders
GROUP BY 1,2
)
```

## On average, how long does an order take from being placed to being delivered?
4 days

```
SELECT 
    AVG(days_delivery)
FROM (
SELECT 
    order_id 
    , created_at 
    , delivered_at 
    , TIMESTAMPDIFF(day, created_at, delivered_at) AS days_delivery
FROM dbt_biandamuthiagmailcom.stg_orders
WHERE status = 'delivered'
)
```

## How many users have only made one purchase? Two purchases? Three+ purchases?
```
SELECT 
    CASE WHEN count_order = 1 THEN '1 Purchase'
    WHEN count_order = 2 THEN '2 Purchases'
    ELSE '3+ purchases' END user_purchase_category
    , COUNT(user_id) AS count_user 
FROM (
SELECT 
    user_id 
    , COUNT(order_id) AS count_order
FROM dbt_biandamuthiagmailcom.stg_orders
GROUP BY 1
)
group by 1
```

## On average, how many unique sessions do we have per hour?
16 unique sessions

```
SELECT AVG(session_per_hour)
FROM (
SELECT 
    DATE(created_at) AS order_date 
    , HOUR(created_at) AS order_hour 
    , COUNT(DISTINCT session_id) AS session_per_hour
FROM dbt_biandamuthiagmailcom.stg_events
GROUP BY 1,2
)```
