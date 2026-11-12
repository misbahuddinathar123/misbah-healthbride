-- T-24, test 2: the total paid in mart_claims_monthly equals the total paid in RAW.CLAIMS within 50 cents.
-- Returns one row when the totals differ (or when either total is missing); passes when it returns no rows.
--
-- What would make this test fail: duplicate claim_ids loaded into RAW.CLAIMS (staging keeps only one row per claim,
-- so the mart would be LOWER than the raw total, for example after a file is loaded twice); claims dropped by a
-- wrong join or filter in fct_claims; rows with a NULL service month or claim type that no longer fall into a
-- reporting group; or an empty mart.
with monthly as (

    select sum(paid_amount) as paid_total from {{ ref('mart_claims_monthly') }}

),

source_total as (

    select sum(paid_amount) as paid_total from {{ source('raw', 'claims') }}

)

select
    monthly.paid_total        as monthly_paid_total,
    source_total.paid_total   as raw_paid_total
from monthly
cross join source_total
where monthly.paid_total is null
   or source_total.paid_total is null
   or abs(monthly.paid_total - source_total.paid_total) > 0.50
