# HealthBridge dbt project (Snowflake capstone, Module 9: T-18 to T-25)

Bronze (RAW) -> Staging (CURATED) -> Gold (ANALYTICS) in `HEALTHBRIDGE_DB`.
8 sources, 4 seeds, 8 staging models, 5 dimension/fact models, 4 marts (17 models), 3 singular tests.

## Layout
| Folder | Contents |
|---|---|
| `macros/` | `generate_schema_name.sql` (exact CURATED / ANALYTICS names), `set_query_tag.sql` (`dbt_healthbridge_<name>`) |
| `seeds/` | the four mapping CSVs and `seeds.yml` |
| `models/staging/healthbridge/` | `healthbridge_sources.yml`, `healthbridge_staging.yml`, the eight `stg_*` models |
| `models/marts/core/` | `dim_member`, `dim_provider`, `fct_claims`, `fct_pharmacy_claims`, `fct_quality_measures`, `core.yml`, `core.md` |
| `models/marts/reporting/` | `mart_member_360`, `mart_claims_monthly`, `mart_care_gap_summary`, `mart_provider_scorecard`, `reporting.yml` |
| `tests/` | `assert_paid_not_above_allowed`, `assert_monthly_paid_reconciles_to_source`, `assert_stg_members_has_no_phi` |

## Design notes
* `county_fips` is forced to text in `dbt_project.yml` so the leading zeros (04013) survive the seed load.
* Staging reads only from sources; gold reads only staging models, seeds and other gold models, never RAW directly.
* Seeds are LEFT joined so a value missing from a mapping never removes a row.
* `stg_claims` and `stg_pharmacy_claims` keep one row per claim / fill (latest `load_timestamp` wins).
* Each fact is summarised to one row per member before it is joined in `mart_member_360` (different grains).
* Test arguments use the `data_tests:` / `arguments:` syntax of current dbt platform versions.

## Think about it: what would have gone wrong if staging had carried full_name or the exact date of birth?
The T-08 masking policies hide `LAST_NAME` and `DATE_OF_BIRTH` from roles that are not approved (dbt does not run as an
approved PHI role). If the staging layer had carried `full_name` or the exact date of birth, two things would have gone wrong:
1. **The data would be wrong.** dbt would have read the *masked* values (`Robert ***MASKED***`, dates reduced to January 1)
   and stored them in a table, so every downstream model would silently contain junk names and wrong birth dates.
2. **PHI would have been copied.** Masking only protects the source column. A staging table that copied the real values
   (for example if the build ran under an approved role) would be a second, unprotected copy of PHI that every role with
   access to CURATED or ANALYTICS could read, breaking HIPAA's "minimum necessary" standard.

The design avoids both: staging excludes `FIRST_NAME`, `LAST_NAME` and `DATE_OF_BIRTH` entirely, members are identified only
by `member_id`, and age is derived from the *year* of birth (`reference_year - year(date_of_birth)`), which the date-of-birth
mask preserves. The singular test `assert_stg_members_has_no_phi` checks the information schema so that a PHI column can
never be added to `stg_members` unnoticed.

## Running in dbt platform (Partner Connect)
1. Run the grants script from the capstone notes (role `PC_DBT_ROLE`, warehouse `HEALTHBRIDGE_WH`, database `HEALTHBRIDGE_DB`).
2. Project settings -> Connection: database `HEALTHBRIDGE_DB`, warehouse `HEALTHBRIDGE_WH`, role `PC_DBT_ROLE`.
3. Commands in order: `dbt seed`, `dbt run --select staging`, `dbt build`, `dbt docs generate`.
