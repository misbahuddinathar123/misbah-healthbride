{% docs risk_tier %}
Risk tier derived from the member's risk score (higher score = more complex, costlier member):

- **High**: risk score 2.5 or more
- **Medium**: risk score from 1.5 up to, but not including, 2.5
- **Low**: risk score below 1.5
{% enddocs %}

{% docs needs_care_outreach %}
TRUE when the member has **more than 3 open care gaps** AND a **risk score above 2.0** (the same rule used in the
natural-language question in T-12). These members are the priority group for care-manager outreach.
{% enddocs %}
