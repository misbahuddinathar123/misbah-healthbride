-- Member 360: one row per member (500). Each fact has a different grain (claim, fill, measure, grievance, call), so each
-- one is summarised to ONE ROW PER MEMBER first and only then joined to the member. Joining the facts directly to each
-- other would repeat rows and inflate every total.
-- Members with no activity stay in the table (LEFT joins) with zeros.
with members as (

    select * from {{ ref('dim_member') }}

),

claims as (

    select
        member_id,
        count(*)                           as total_claims,
        sum(billed_amount)                 as total_billed,
        sum(paid_amount)                   as total_paid,
        count_if(is_denied)                as denied_claims,
        count_if(claim_type = 'INPATIENT') as inpatient_claims,
        max(service_date)                  as last_service_date
    from {{ ref('fct_claims') }}
    group by member_id

),

pharmacy as (

    select
        member_id,
        count(*)                           as rx_fills,
        sum(paid_amount)                   as rx_paid,
        count_if(is_off_formulary)         as off_formulary_fills
    from {{ ref('fct_pharmacy_claims') }}
    group by member_id

),

quality as (

    select
        member_id,
        count_if(care_gap_open)            as open_care_gaps,
        count_if(numerator_met)            as measures_met,
        count_if(denominator_eligible)     as eligible_measures
    from {{ ref('fct_quality_measures') }}
    group by member_id

),

grievances as (

    select
        member_id,
        count(*)                           as total_grievances,
        count_if(is_open)                  as open_grievances,
        avg(satisfaction_score)            as avg_satisfaction_score
    from {{ ref('stg_grievances') }}
    group by member_id

),

calls as (

    select
        member_id,
        count(*)                           as total_calls,
        avg(call_duration_minutes)         as avg_call_minutes
    from {{ ref('stg_call_center_notes') }}
    group by member_id

)

select
    m.member_id,
    m.plan_name,
    m.plan_tier,
    m.county,
    m.region,
    m.age_band,
    m.is_active,
    m.chronic_condition_count,
    m.risk_score,
    m.risk_tier,

    coalesce(c.total_claims, 0)                                                         as total_claims,
    coalesce(c.total_billed, 0)                                                         as total_billed,
    coalesce(c.total_paid, 0)                                                           as total_paid,
    coalesce(c.denied_claims, 0)                                                        as denied_claims,
    coalesce(round(c.denied_claims / nullif(c.total_claims, 0), 4), 0)                  as denial_rate,
    coalesce(c.inpatient_claims, 0)                                                     as inpatient_claims,
    c.last_service_date                                                                 as last_service_date,

    coalesce(r.rx_fills, 0)                                                             as rx_fills,
    coalesce(r.rx_paid, 0)                                                              as rx_paid,
    coalesce(r.off_formulary_fills, 0)                                                  as off_formulary_fills,

    coalesce(q.open_care_gaps, 0)                                                       as open_care_gaps,
    coalesce(q.measures_met, 0)                                                         as measures_met,
    coalesce(q.eligible_measures, 0)                                                    as eligible_measures,
    coalesce(round(100.0 * q.measures_met / nullif(q.eligible_measures, 0), 2), 0)      as closure_rate_pct,

    coalesce(g.total_grievances, 0)                                                     as total_grievances,
    coalesce(g.open_grievances, 0)                                                      as open_grievances,
    coalesce(round(g.avg_satisfaction_score, 2), 0)                                     as avg_satisfaction_score,
    coalesce(k.total_calls, 0)                                                          as total_calls,
    coalesce(round(k.avg_call_minutes, 2), 0)                                           as avg_call_minutes,

    (coalesce(q.open_care_gaps, 0) > 3 and m.risk_score > 2.0)                          as needs_care_outreach
from members m
left join claims     c on c.member_id = m.member_id
left join pharmacy   r on r.member_id = m.member_id
left join quality    q on q.member_id = m.member_id
left join grievances g on g.member_id = m.member_id
left join calls      k on k.member_id = m.member_id
