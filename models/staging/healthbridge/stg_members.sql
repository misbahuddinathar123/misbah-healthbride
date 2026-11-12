-- Staging for MEMBERS: one row per member, no PHI.
-- FIRST_NAME, LAST_NAME and DATE_OF_BIRTH are deliberately NOT carried into this model. Age is derived from the YEAR
-- of birth only (the masked date of birth keeps its year, so this works for roles that cannot see the real date).
with source as (

    select * from {{ source('raw', 'members') }}

),

renamed as (

    select
        member_id,
        plan_id,
        plan_name,
        county,
        state,
        case upper(trim(gender))
            when 'M' then 'M'
            when 'F' then 'F'
            else 'U'
        end                                                           as gender,
        enrollment_date,
        disenrollment_date,
        (disenrollment_date is null)                                  as is_active,
        {{ var('reference_year') }} - year(date_of_birth)             as age_years,
        chronic_conditions,
        case
            when chronic_conditions is null or trim(chronic_conditions) = '' then 0
            else length(chronic_conditions) - length(replace(chronic_conditions, ',', '')) + 1
        end                                                           as chronic_condition_count,
        coalesce(chronic_conditions ilike '%E11%', false)             as has_diabetes,
        coalesce(chronic_conditions ilike '%I10%', false)             as has_hypertension,
        coalesce(chronic_conditions ilike '%N18%', false)             as has_ckd,
        coalesce(chronic_conditions ilike '%J44%', false)             as has_copd,
        coalesce(chronic_conditions ilike '%I50%', false)             as has_heart_failure,
        coalesce(chronic_conditions ilike '%F32%', false)             as has_depression,
        coalesce(chronic_conditions ilike '%E78%', false)             as has_hyperlipidemia,
        risk_score,
        pcp_npi,
        language_preference
    from source

)

select * from renamed
