-- T-24, test 1: a claim is never paid more than its allowed amount (one cent allowed for rounding).
-- Returns the failing claims; the test passes when it returns no rows.
select
    claim_id,
    allowed_amount,
    paid_amount
from {{ ref('fct_claims') }}
where paid_amount > allowed_amount + 0.01
