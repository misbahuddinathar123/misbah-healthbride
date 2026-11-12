-- Staging for CALL_CENTER_NOTES: call reason standardised, long-call flag and note length added.
-- SENTIMENT and SUMMARY are not carried: they are empty in the source.
with source as (

    select * from {{ source('raw', 'call_center_notes') }}

),

renamed as (

    select
        note_id,
        member_id,
        call_date,
        agent_id,
        upper(call_reason)                       as call_reason,
        call_duration_minutes,
        notes,
        (call_duration_minutes >= 30)            as is_long_call,
        length(notes)                            as note_length
    from source

)

select * from renamed
