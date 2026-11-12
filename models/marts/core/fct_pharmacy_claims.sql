-- Pharmacy claims fact: one row per fill, with the therapeutic area from drug_class_mapping (LEFT join, no fill is lost).
with fills as (

    select * from {{ ref('stg_pharmacy_claims') }}

),

drug_classes as (

    select drug_class, therapeutic_area from {{ ref('drug_class_mapping') }}

)

select
    f.rx_claim_id,
    f.member_id,
    f.prescriber_npi,
    f.fill_date,
    f.fill_month,
    f.drug_name,
    f.drug_class,
    d.therapeutic_area,
    f.days_supply,
    f.billed_amount,
    f.paid_amount,
    f.paid_per_day,
    f.formulary_status,
    f.is_off_formulary,
    f.requires_prior_auth,
    f.generic_available
from fills f
left join drug_classes d on d.drug_class = f.drug_class
