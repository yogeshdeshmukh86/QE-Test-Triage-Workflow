# Validation evidence and limitations

## Supplied evidence

The historical HTML report dated 2026-10-06 contains ten webhook submissions: seven ACCEPTED and three FAILED. TC-002, TC-003, and TC-006 failed with HTTP 404. Accepted means the HTTP request returned successfully to the script. The script does not assert the AI classification, selected route, or creation of Jira/Slack/Airtable objects.

The source validation log describes an early ingestion/extraction phase, contains one partial payload, and ends before completing its JSON fence or recording a result. It is preserved as historical material, not a passing test record.

## Source discrepancies

| Source statement | Export/evidence finding |
| --- | --- |
| High sends Jira + Slack + Airtable | High connects only to Jira |
| Full audit trail for every run | High has no Airtable write; medium logging depends on Slack success |
| Jira bug label and active sprint | Task type and Bug-prefixed summary; no label or sprint assignment configured |
| Jira includes raw stack traces | Stack trace feeds extraction but is absent from the Jira description |
| Low has its own tracker/table | Both Airtable nodes select the same original table |
| Extraction is deterministic | Prepare maps fields; Extract is an LLM chain |
| Less than two seconds to Jira | No supporting end-to-end timing evidence supplied |
| 100% ingestion or zero misclassification | Targets, not established results |

The original presentation remains available with these qualifications. Its wording has not been rewritten. The README and architecture describe the current exported graph.

## Classification concerns

The classifier groups network timeouts as Low while some scenarios expect business-critical timeouts to be High or Medium. Functional assertions are described as Medium, while cosmetic assertion examples expect Low. Resolve these overlaps and define impact-based precedence before reporting accuracy.

The `is_flaky` output is a model suggestion based on a single failure, not measured repeatability. Priority and severity are currently largely aligned by the prompt and need separate definitions for a broader QE use case.

## Changes made for public sharing

Removed credential bindings, pinned data, workflow/instance metadata, and node webhook IDs. Replaced Airtable IDs, Jira resource IDs, and the Slack channel with placeholders. Left prompts, node wiring, and the implemented routing behavior intact.

The runner now accepts URL/report parameters, defaults to a production webhook path for batch execution, and names the current High route accurately. Its expected routes remain design expectations, not assertions. Sample report results were preserved.

The live Airtable link was excluded. Contigo customer-support prompts were excluded because they describe a separate financial-services support scenario, not QE triage. Contigo is a dummy company, as declared by the author.

## Recommended evaluation

1. Establish human-labelled expected classifications for all ten examples and resolve conflicting prompt rules.
2. Run against sandbox destinations and capture output, route, destination IDs, and errors for each case.
3. Assert destination creation independently from HTTP acceptance, including negative assertions for routes that should not run.
4. Test malformed payloads, model/API failures, duplicate submissions, and hostile instructions inside logs.
5. Repeat model runs and measure classification agreement and end-to-end latency on a larger representative sample.

Repository preparation included static JSON, graph, link, and sanitization checks. No credentials were used to execute the workflow, and no live n8n, Jira, Slack, Airtable, or OpenRouter validation was performed.

Operational-looking environment labels and a sample database username were replaced with explicit demo values before public upload. Database messages are synthetic test fixtures.
