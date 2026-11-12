-- Provider dimension: all staging provider columns plus a rating band.
with providers as (

    select * from {{ ref('stg_providers') }}

)

select
    p.*,
    case
        when p.star_rating >= 4.5 then 'Excellent'
        when p.star_rating >= 4.0 then 'Good'
        when p.star_rating >= 3.0 then 'Fair'
        else 'Poor'
    end as rating_band
from providers p
