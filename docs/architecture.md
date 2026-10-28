# Architecture and design decisions

The workflow contains 13 nodes. HTTP intake, field mapping, branching, and API calls use explicit n8n configuration. Two LLM chains perform semantic extraction and classification, each with its own structured output parser and OpenRouter model.

## AI boundaries

Extraction returns `test_case_id`, `failing_component`, `failure_domain`, and `extracted_root_cause`. The extracted cause is a hypothesis based on the submitted log.

Classification returns `priority`, `severity`, `bug_title`, `recommended_action`, and `is_flaky`. Priority and severity are restricted to High, Medium, or Low by schema. The classifier receives extracted metadata and the original error type. It does not receive all original fields directly, including environment and execution duration.

Both steps use AI. The earlier decomposition notes describe extraction partly as deterministic, but only the Prepare field mapping is deterministic in this export. JSON parsers constrain structure, not semantic correctness.

## Routing and integration behavior

The switch uses the highest matching level across priority and severity: High first, Medium second, otherwise output 2. With valid parser output, the final branch represents Low. There is no separate switch rule for `is_flaky`.

The high branch creates a Jira Task using a summary prefixed with `Bug:` and a fixed selected Jira priority. It includes metadata, extracted context, and a recommendation in the description. The export does not configure a Bug label, sprint assignment, or raw stack trace in that description.

Medium sends Slack a formatted alert then creates an Airtable record. Low writes directly to the same configured Airtable table via a separate node. The low node's name does not indicate a separate table. High has no Airtable connection.

## Reliability boundaries

No dedicated retry/fallback path, deduplication, confidence threshold, input schema guard, authentication, or CI trigger integration is configured. Serial Slack-to-Airtable delivery couples the medium audit record to Slack success. Model classification can vary between runs.

Before production use, add safe handling of untrusted logs and prompt injection, a deterministic critical-failure guard, human review for ambiguous cases, webhook authentication, idempotency, observability, and an explicit failure-handling path.
