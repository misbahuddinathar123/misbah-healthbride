-- Claims fact: one row per claim. The authorization and the denial-reason mapping are LEFT joined, so every claim stays
-- in the table (auth_status is empty when the claim has no authorization; denial_category and is_appealable are empty
-- when the claim is not denied).
with claims as (

    select * from {{ ref('stg_claims') }}

),

authorizations as (

    select auth_id, auth_status from {{ ref('stg_authorizations') }}

),

denial_reasons as (

    select denial_reason, denial_category, is_appealable from {{ ref('denial_reason_mapping') }}

)

select
    c.claim_id,
    c.member_id,
    c.npi,
    c.service_date,
    c.service_month,
    c.service_year,
    c.discharge_date,
    c.claim_type,
    c.claim_status,
    c.is_denied,
    c.denial_reason,
    c.primary_dx,
    c.procedure_code,
    c.place_of_service,
    c.billed_amount,
    c.allowed_amount,
    c.paid_amount,
    c.discount_amount,
    c.length_of_stay_days,
    c.auth_id,
    a.auth_status,
    d.denial_category,
    d.is_appealable
from claims c
left join authorizations a on a.auth_id        = c.auth_id
left join denial_reasons d on d.denial_reason  = c.denial_reason
