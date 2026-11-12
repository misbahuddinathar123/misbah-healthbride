-- Monthly claims: one row per service month and claim type (12 months x 3 claim types = 36 rows).
with claims as (

    select * from {{ ref('fct_claims') }}

)

select
    service_month,
    claim_type,
    count(*)                                              as claim_count,
    sum(billed_amount)                                    as billed_amount,
    sum(allowed_amount)                                   as allowed_amount,
    sum(paid_amount)                                      as paid_amount,
    count_if(is_denied)                                   as denied_claims,
    round(count_if(is_denied) / nullif(count(*), 0), 4)   as denial_rate,
    round(sum(paid_amount) / nullif(count(*), 0), 2)      as avg_paid_per_claim
from claims
group by service_month, claim_type
