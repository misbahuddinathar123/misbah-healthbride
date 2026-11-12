-- Care gap summary: one row per quality measure (8 rows).
with measures as (

    select * from {{ ref('fct_quality_measures') }}

)

select
    measure_code,
    measure_name,
    count_if(denominator_eligible)                                                            as eligible_members,
    count_if(numerator_met)                                                                   as measures_met,
    count_if(care_gap_open)                                                                   as open_gaps,
    round(100.0 * count_if(numerator_met) / nullif(count_if(denominator_eligible), 0), 2)     as closure_rate_pct,
    round(avg(case when care_gap_open then outreach_count end), 2)                            as avg_outreach_attempts_on_open_gaps
from measures
group by measure_code, measure_name
