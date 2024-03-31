WITH users AS (
    SELECT 
        *
    FROM {{ref('stg_users')}}
)
, events AS (
    SELECT 
        user_id 
        , MAX(DATE(created_at)) AS last_website_visit_at
    FROM {{ref('stg_events')}}
    GROUP BY 1
)
, orders AS (
    SELECT 
        user_id 
        , COUNT(order_id) AS num_orders
        , COUNT(promo_id) AS num_order_used_promo
        , SUM(order_cost) AS total_order_spend
        , SUM(shipping_cost) AS total_shipping_cost
        , MIN(DATE(created_at)) AS first_order_date
        , MAX(DATE(created_at)) AS last_order_date
    FROM {{ref('stg_orders')}}
    GROUP BY 1
)
SELECT 
    u.user_id 
    , u.first_name
    , u.email 
    , DATE(u.created_at) AS user_created_date
    , e.last_website_visit_at
    , o.num_orders
    , o.num_order_used_promo
    , o.total_order_spend
    , o.total_shipping_cost
    , o.first_order_date
    , o.last_order_date
FROM users AS u
LEFT JOIN events AS e ON e.user_id = u.user_id 
LEFT JOIN orders AS o ON o.user_id = u.user_id