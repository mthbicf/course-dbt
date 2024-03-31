WITH snapshot AS (
    SELECT 
        product_id 
        , name AS product_name 
        , price AS unit_price 
        , inventory 
        , DATE(dbt_valid_from) AS row_valid_from 
        , DATE(dbt_valid_to) AS row_valid_to 
        , ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY DATE(dbt_valid_from)) AS change_index
    FROM {{ref('inventory_snapshot')}}
)
, adjust_row_valid_from AS (
    SELECT 
        product_id 
        , product_name 
        , unit_price
        , inventory 
        , change_index 
        , CASE 
            WHEN change_index > 1 THEN DATEADD(day,1,row_valid_from) 
            WHEN change_index = 1 THEN DATE('2021-02-09') -- to accommodate ealier events and orders that have been made
            END AS row_valid_from
        , row_valid_to
        , change_index = MAX(change_index) OVER (PARTITION BY product_id) AS is_current
    FROM snapshot 
)
, adjust_row_valid_to AS (
    SELECT 
        product_id 
        , product_name 
        , unit_price
        , inventory 
        , change_index 
        , row_valid_from
        , CASE
            WHEN row_valid_to IS NULL AND CURRENT_DATE >= row_valid_from THEN CURRENT_DATE 
            WHEN row_valid_to IS NULL AND CURRENT_DATE < row_valid_from THEN row_valid_from
            ELSE row_valid_to
          END row_valid_to
        , is_current
    FROM adjust_row_valid_from 
)

SELECT 
    *
FROM adjust_row_valid_to