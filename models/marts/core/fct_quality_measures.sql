-- Quality measures fact: one row per member and measure.
with measures as (

    select * from {{ ref('stg_quality_measures') }}

)

select
    measure_id,
    member_id,
    measure_code,
    measure_name,
    measurement_year,
    numerator_met,
    denominator_eligible,
    care_gap_open,
    last_service_date,
    outreach_count,
    has_service_record,
    outreach_attempted
from measures
