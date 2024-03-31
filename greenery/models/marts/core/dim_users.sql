SELECT 
    usr.user_id 
    , usr.first_name
    , usr.last_name
    , usr.email 
    , usr.phone_number 
    , usr.created_at
    , usr.updated_at
    , adr.address 
    , adr.zipcode 
    , adr.state 
    , adr.country
FROM {{ref('stg_users')}} AS usr
LEFT JOIN {{ref('stg_addresses')}} AS adr
    ON adr.address_id = usr.address_id