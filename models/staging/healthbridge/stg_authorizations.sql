-- Staging for AUTHORIZATIONS: text standardised, turnaround and status flags added.
with source as (

    select * from {{ source('raw', 'authorizations') }}

),

renamed as (

    select
        auth_id,
        member_id,
        requesting_npi,
        service_type,
        requested_date,
        decision_date,
        upper(auth_status)                                          as auth_status,
        nullif(trim(denial_reason), '')                             as denial_reason,
        upper(priority)                                             as priority,
        clinical_notes,
        datediff('day', requested_date, decision_date)              as turnaround_days,
        (upper(auth_status) = 'DENIED')                             as is_denied,
        (upper(auth_status) in ('PENDING', 'APPEALED'))             as is_open
    from source

)

select * from renamed
