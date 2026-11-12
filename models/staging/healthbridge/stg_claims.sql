-- Staging for CLAIMS: duplicates removed (latest load_timestamp wins), text standardised, simple flags added.
with source as (

    select * from {{ source('raw', 'claims') }}

),

renamed as (

    select
        claim_id,
        member_id,
        npi,
        service_date,
        discharge_date,
        upper(claim_type)                                              as claim_type,
        primary_dx,
        procedure_code,
        place_of_service,
        billed_amount,
        allowed_amount,
        paid_amount,
        upper(claim_status)                                            as claim_status,
        nullif(trim(denial_reason), '')                                as denial_reason,
        nullif(trim(auth_id), '')                                      as auth_id,
        year(service_date)                                             as service_year,
        date_trunc('month', service_date)::date                        as service_month,
        (upper(claim_status) = 'DENIED')                               as is_denied,
        (nullif(trim(auth_id), '') is not null)                        as has_auth,
        billed_amount - allowed_amount                                 as discount_amount,
        case
            when upper(claim_type) = 'INPATIENT'
                then datediff('day', service_date, discharge_date)
        end                                                            as length_of_stay_days,
        load_timestamp
    from source
    -- keep one row per claim_id: the one loaded last
    qualify row_number() over (partition by claim_id order by load_timestamp desc) = 1

)

select * from renamed
