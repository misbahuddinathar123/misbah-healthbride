-- Staging for GRIEVANCES: text standardised, status flags and days to resolve added.
with source as (

    select * from {{ source('raw', 'grievances') }}

),

renamed as (

    select
        grievance_id,
        member_id,
        filed_date,
        upper(category)                                         as category,
        description,
        upper(status)                                           as status,
        resolution_date,
        satisfaction_score,
        (upper(status) <> 'RESOLVED')                           as is_open,
        (upper(status) = 'ESCALATED')                           as is_escalated,
        datediff('day', filed_date, resolution_date)            as days_to_resolve
    from source

)

select * from renamed
