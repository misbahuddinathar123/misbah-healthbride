-- Staging for QUALITY_MEASURES: measure code standardised, service and outreach flags added.
with source as (

    select * from {{ source('raw', 'quality_measures') }}

),

renamed as (

    select
        measure_id,
        member_id,
        upper(measure_code)                                  as measure_code,
        measure_name,
        measurement_year,
        numerator_met,
        denominator_eligible,
        care_gap_open,
        last_service_date,
        outreach_count,
        (last_service_date is not null)                      as has_service_record,
        (coalesce(outreach_count, 0) > 0)                    as outreach_attempted
    from source

)

select * from renamed
