{#-
  T-18: query tag.
  dbt calls this macro before it builds each model or seed. It sets the Snowflake session QUERY_TAG to
  dbt_healthbridge_<name> and returns the ORIGINAL tag so that dbt can restore it afterwards. The tag lets you
  find each model's queries in query history and attribute cost per model.
-#}
{% macro set_query_tag() -%}

    {%- set new_query_tag = 'dbt_healthbridge_' ~ model.name -%}
    {%- set original_query_tag = get_current_query_tag() -%}

    {{ log("Setting query_tag to '" ~ new_query_tag ~ "'. Will reset to '" ~ original_query_tag ~ "' after materialization.") }}
    {%- do run_query("alter session set query_tag = '{}'".format(new_query_tag)) -%}

    {{ return(original_query_tag) }}

{%- endmacro %}
