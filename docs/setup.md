# Setup and execution

## Requirements

Use an n8n instance supporting the exported node types, PowerShell for the optional runner, an OpenRouter API account, a Jira project where you can create issues, a Slack channel accessible to your integration, and an Airtable base/table where you can create records. No n8n version or lockfile was supplied, so import compatibility must be checked on your instance.

## Import and configure

1. Import `workflows/qe-test-failure-triage.json`. It is saved inactive and without credential bindings.
2. Select an OpenRouter credential on both model nodes. The original model identifiers are `google/gemini-2.5-flash` for extraction and `google/gemini-2.5-flash-lite` for classification. Check availability in your account and select alternatives if necessary. Re-evaluate classifications after model changes.
3. Configure Jira credentials. Replace `REPLACE_JIRA_PROJECT_ID`, `REPLACE_JIRA_ISSUE_TYPE_ID`, and `REPLACE_JIRA_PRIORITY_ID` by selecting resources from your account. The original configuration selected Task and Highest. Changing issue type to Bug is an intentional behavior change.
4. Configure Slack credentials and replace `#your-qe-triage-channel`. Give the integration access to that channel.
5. Configure Airtable credentials and replace `REPLACE_AIRTABLE_BASE_ID` and `REPLACE_AIRTABLE_TABLE_ID` in **both** Airtable nodes.
6. Create the Airtable columns below and refresh the node schema if needed.
7. Inspect each node and resolve any import warnings before execution.

| Airtable column | Suggested type |
| --- | --- |
| Test Case ID | Single line text |
| Bug Title | Single line text |
| Priority | Single select: High, Medium, Low |
| Severity | Single select: High, Medium, Low |
| Failing Component | Single line text |
| Failure Domain | Single line text |
| Extracted Root Cause | Long text |
| Recommended Action | Long text |
| Is Flaky | Checkbox |
| Environment | Single line text |
| Triage Timestamp | Created time, optional and not mapped by the workflow |

## Payload contract

The files in `examples/` contain synthetic demonstration payloads. Use their field names and JSON structure as a reference, then create your own payloads relevant to your application, test framework, and failure scenarios. The example structure is not a universal test-report standard.

If your test runner uses a different schema, either transform its output into the reference structure before submission or update the Prepare mappings and any affected AI prompts, output schemas, and integration mappings. Verify the updated workflow with your own expected classifications and destination results.

The Prepare node maps `test_run_id`, `environment`, `application`, `test_case_id`, `test_name`, `execution_status`, `error_type`, `error_message`, and `stack_trace` from the incoming request body. Examples also contain `execution_time_ms`, which the current Prepare node does not forward. Intake does not explicitly reject missing fields or filter passed tests. Submit failure payloads only until such validation is added.

## Webhook modes

Use the URL shown by your own Webhook node. The original runner used a local `/webhook-test/` endpoint, which requires n8n to be listening for a test event and is unsuitable for an unattended batch. The repository runner defaults to the local `/webhook/` endpoint. This requires an enabled/published workflow. Change `-WebhookUrl` for a hosted instance.

For a manual test, start listening in n8n and send one request to its displayed test URL. For a batch, configure sandbox integrations, enable/publish the workflow, and use its production URL. Do not expose the exported unauthenticated webhook publicly without adding authentication and validating inputs.

## Inspect results

For each example, inspect Webhook, Extract, Classify, Switch, and all selected destination nodes. Record the model output, route, created object ID, and any API error. The PowerShell script prints expected routes but does not compare them with observed routes. It pauses 30 seconds between submissions and opens the generated HTML report locally.

The high branch currently ends at Jira. Medium continues from Slack to Airtable, so a Slack failure can prevent Airtable logging. An accepted webhook response can occur before later nodes finish or fail.

## Troubleshooting

- HTTP 404: verify instance URL, webhook mode, workflow activation, and whether the test listener is armed.
- Resource not found: replace placeholders and verify account permissions.
- Parser failure: inspect model output and schema, then review the failure manually.
- Missing Airtable fields: refresh schema and check exact column names/types.
- Repeated Jira tasks: submissions are not deduplicated. Use a sandbox and clean up after demonstrations.
