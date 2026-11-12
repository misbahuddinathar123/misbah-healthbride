-- Staging for PHARMACY_CLAIMS: duplicates removed (latest load wins), flags and paid-per-day added.
with source as (

    select * from {{ source('raw', 'pharmacy_claims') }}

),

renamed as (

    select
        rx_claim_id,
        member_id,
        prescriber_npi,
        fill_date,
        date_trunc('month', fill_date)::date                    as fill_month,
        ndc_code,
        drug_name,
        drug_class,
        days_supply,
        billed_amount,
        paid_amount,
        round(paid_amount / nullif(days_supply, 0), 2)          as paid_per_day,
        upper(formulary_status)                                 as formulary_status,
        (upper(formulary_status) = 'OFF_FORMULARY')             as is_off_formulary,
        (upper(formulary_status) = 'PRIOR_AUTH')                as requires_prior_auth,
        generic_available,
        load_timestamp
    from source
    qualify row_number() over (partition by rx_claim_id order by load_timestamp desc) = 1

)

select * from renamed
