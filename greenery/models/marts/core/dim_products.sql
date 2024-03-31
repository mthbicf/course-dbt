SELECT 
    product_id 
    , product_name 
    , unit_price
    , inventory 
    , change_index 
    , row_valid_from
    , row_valid_to
    , is_current
FROM {{ref('int_product_scd')}}