-- Member dimension: all staging member columns plus plan tier/category (plan_mapping), region/FIPS (county_region_mapping),
-- age band, risk tier and the assigned primary care provider's name and specialty.
-- Seeds and providers are LEFT joined so a value missing from a mapping never removes a member.
with members as (

    select * from {{ ref('stg_members') }}

),

providers as (

    select npi, provider_name, specialty from {{ ref('stg_providers') }}

),

plans as (

    select * from {{ ref('plan_mapping') }}

),

counties as (

    select * from {{ ref('county_region_mapping') }}

)

select
    m.*,
    pl.plan_tier,
    pl.plan_category,
    co.region,
    co.county_fips,
    case
        when m.age_years < 65 then 'Under 65'
        when m.age_years < 70 then '65-69'
        when m.age_years < 75 then '70-74'
        when m.age_years < 80 then '75-79'
        when m.age_years < 85 then '80-84'
        else '85+'
    end                                  as age_band,
    case
        when m.risk_score >= 2.5 then 'High'
        when m.risk_score >= 1.5 then 'Medium'
        else 'Low'
    end                                  as risk_tier,
    pr.provider_name                     as pcp_name,
    pr.specialty                         as pcp_specialty
from members m
left join providers pr on pr.npi       = m.pcp_npi
left join plans     pl on pl.plan_id   = m.plan_id
left join counties  co on co.county    = m.county
