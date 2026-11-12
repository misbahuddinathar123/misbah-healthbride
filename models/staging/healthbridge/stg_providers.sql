-- Staging for PROVIDERS: all columns except network_status, which becomes the true/false column is_in_network.
with source as (

    select * from {{ source('raw', 'providers') }}

),

renamed as (

    select
        npi,
        provider_name,
        specialty,
        upper(provider_type)                         as provider_type,
        (upper(network_status) = 'IN_NETWORK')       as is_in_network,
        city,
        state,
        accepting_new_patients,
        star_rating
    from source

)

select * from renamed
