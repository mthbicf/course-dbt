WITH page_view_add_to_cart_daily AS (
    SELECT 
        e.product_id
        , p.product_name
        , p.unit_price
        , DATE(e.created_at) AS date
        , SUM(CASE WHEN e.event_type = 'page_view' THEN 1 ELSE 0 END) AS num_page_view
        , SUM(CASE WHEN e.event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS num_add_to_cart
    FROM {{ref('stg_events')}} AS e
    JOIN {{ref('int_product_scd')}} AS p ON 
        p.product_id = e.product_id
        AND DATE(e.created_at) BETWEEN p.row_valid_from AND p.row_valid_to
    WHERE e.event_type IN ('page_view','add_to_cart')
    GROUP BY 1,2,3,4
)
, product_order_quantity AS (
    SELECT 
        oi.product_id 
        , DATE(o.created_at) AS order_date
        , COUNT(DISTINCT oi.order_id) AS num_order
        , SUM(oi.quantity) AS num_sold_quantity
        , SUM(oi.quantity * p.unit_price) AS total_before_discount
        , SUM(oi.quantity * p.unit_price * (1 - COALESCE(promo.discount,0)/100) ) AS total_after_discount
    FROM {{ref('stg_order_items')}} AS oi 
    JOIN {{ref('stg_orders')}} AS o ON oi.order_id = o.order_id
    JOIN {{ref('int_product_scd')}} AS p ON 
        p.product_id = oi.product_id
        AND DATE(o.created_at) BETWEEN p.row_valid_from AND p.row_valid_to
    LEFT JOIN {{ref('stg_promos')}} AS promo 
        ON promo.promo_id = o.promo_id
    GROUP BY 1,2
)
SELECT 
    e.product_id
    , e.date
    , e.product_name
    , e.unit_price
    , e.num_page_view
    , e.num_add_to_cart
    , COALESCE(p.num_order, 0) AS num_order
    , COALESCE(p.num_sold_quantity, 0) AS num_sold_quantity
    , COALESCE(p.total_before_discount, 0) AS total_before_discount
    , COALESCE(p.total_after_discount, 0) AS total_after_discount
    , (COALESCE(p.num_order, 0)/e.num_page_view) AS conversion_rate
FROM page_view_add_to_cart_daily AS e 
LEFT JOIN product_order_quantity AS p 
    ON p.product_id = e.product_id 
    AND p.order_date = e.date

