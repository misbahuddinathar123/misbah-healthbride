{#-
  T-18: custom schema name.
  dbt's built-in macro joins the target schema and the custom schema (for example DBT_MISBAH_CURATED).
  This override returns the custom schema name EXACTLY as configured (CURATED or ANALYTICS) and falls back to the
  target (profile) schema when no custom schema is configured.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
