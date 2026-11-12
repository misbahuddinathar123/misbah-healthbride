-- T-24, test 3: stg_members must not contain FIRST_NAME, LAST_NAME or DATE_OF_BIRTH.
-- Looks the columns up in the database's information schema and returns any PHI column it finds;
-- passes when it returns no rows.
select
    column_name
from {{ ref('stg_members').database }}.information_schema.columns
where table_schema = upper('{{ ref('stg_members').schema }}')
  and table_name   = upper('{{ ref('stg_members').identifier }}')
  and column_name in ('FIRST_NAME', 'LAST_NAME', 'DATE_OF_BIRTH')
