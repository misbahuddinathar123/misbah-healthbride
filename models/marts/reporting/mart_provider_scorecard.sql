-- Provider scorecard: one row per provider (all 100). Providers without claims are kept (LEFT join) and show zeros.
with providers as (

    select * from {{ ref('dim_provider') }}

),

claims as (

    select
        npi,
        count(*)                       as claim_count,
        count(distinct member_id)      as distinct_members,
        sum(paid_amount)               as paid_amount,
        count_if(is_denied)            as denied_claims
    from {{ ref('fct_claims') }}
    group by npi

)

select
    p.npi,
    p.provider_name,
    p.specialty,
    p.provider_type,
    p.star_rating,
    p.rating_band,
    p.is_in_network,
    coalesce(c.claim_count, 0)                                                  as claim_count,
    coalesce(c.distinct_members, 0)                                             as distinct_members,
    coalesce(c.paid_amount, 0)                                                  as paid_amount,
    coalesce(c.denied_claims, 0)                                                as denied_claims,
    coalesce(round(c.denied_claims / nullif(c.claim_count, 0), 4), 0)           as denial_rate
from providers p
left join claims c on c.npi = p.npi
