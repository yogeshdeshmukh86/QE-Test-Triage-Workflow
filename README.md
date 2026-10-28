# Automated QE Test Failure Triage Workflow

![n8n](https://img.shields.io/badge/n8n-EA4B71?style=flat-square) ![OpenRouter](https://img.shields.io/badge/OpenRouter-6467F2?style=flat-square) ![Google Gemini](https://img.shields.io/badge/Google%20Gemini-4285F4?style=flat-square) ![Jira](https://img.shields.io/badge/Jira-0052CC?style=flat-square) ![Slack](https://img.shields.io/badge/Slack-4A154B?style=flat-square) ![Airtable](https://img.shields.io/badge/Airtable-18BFFF?style=flat-square) ![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat-square)

**An n8n workflow for AI-assisted triage of automated test failures: identifying failures that need attention and routing them to engineering tools.**

## Purpose and intent

Automated regression suites can produce a mixture of critical failures, functional defects, cosmetic issues, and intermittent timeouts. Manually reading each stack trace delays the first triage decision and makes prioritization inconsistent.

I built this project to demonstrate how n8n can orchestrate a practical Quality Engineering workflow: receive a test failure, extract technical context, suggest priority and severity with an LLM, and route the result into engineering tools. The intended benefit is faster first-pass triage and less repetitive log review. Time savings, classification accuracy, and production impact have not been measured.

## Implementation and portability

This project was designed, developed, and implemented using **n8n**. n8n coordinates webhook intake, AI extraction and classification, conditional routing, and integrations with Jira, Slack, and Airtable. PowerShell provides the demonstration runner.

The same automation approach could also be implemented with **Zapier, Make, or similar workflow automation platforms**, using appropriate integrations or API calls. Those implementations would require rebuilding the workflow and validating their behavior. This repository provides the n8n implementation only; its workflow JSON cannot be imported directly into those platforms.

## Workflow video

A short walkthrough will be added here once recorded and published on YouTube or Loom.

Suggested walkthrough, approximately 3–5 minutes:

1. Explain the testing problem and show the n8n workflow.
2. Submit a synthetic failure payload and inspect the extraction and classification outputs.
3. Follow a High example to Jira, a Medium example to Slack and Airtable, and a Low example to Airtable.
4. Show the resulting issue or record, then explain the current limitations and planned improvements.

The recording should demonstrate actual destination results alongside n8n execution details. Keep credentials, tokens, private account URLs, and unrelated personal information out of view.

## Demo context and account disclosure

- This is an independent portfolio demonstration using simulated test failures, not a client delivery or production deployment.
- **Contigo is a dummy company in the supplied materials.** Its customer-support prompts belong to a separate scenario and are not part of the QE workflow.
- The QE examples and presentation use **Volta / Volta Coffee Roasters as the demonstration application context**. Those names do not imply an employment, client, or endorsement relationship.
- Airtable and Jira were configured using my personal trial accounts. The Slack channel belongs to me.
- The public workflow removes credential references, account-specific resource IDs, pinned data, and instance metadata. Configure your own credentials and destinations before running it.

All example payloads use synthetic demonstration environment labels. Database errors and stack traces are illustrative fixtures, not operational logs.

## Workflow overview

![Current n8n test failure triage workflow](assets/n8n-workflow-overview.png)

The screenshot shows the current implementation: webhook intake, field preparation, AI extraction and classification with structured parsers, then three severity-based routes. The simplified diagram below shows the same flow.

## What the workflow does

1. Receives a JSON test failure through an HTTP POST webhook.
2. Maps the test metadata, error message, and stack trace in `Prepare`.
3. Uses an OpenRouter chat model to extract the failing component, failure domain, and probable root cause.
4. Uses a second model to suggest priority, severity, a bug title, an action, and a flakiness flag.
5. Validates the AI output structure with JSON schema parsers.
6. Applies a three-way priority/severity switch and calls the configured integrations.

```mermaid
flowchart TD
    A["Test failure JSON"] --> B["Webhook and field mapping"]
    B --> C["AI extraction and classification"]
    C --> D{"Priority / severity"}
    D -->|"High"| E["Jira task"]
    D -->|"Medium"| F["Slack alert"]
    F --> G["Airtable record"]
    D -->|"Low"| H["Airtable record"]
```

### Current exported routing

| Condition, evaluated in order | Output | Implemented action |
| --- | --- | --- |
| Priority OR severity is `High` | 0 | Create a Jira issue |
| Otherwise, priority OR severity is `Medium` | 1 | Send Slack message, then create Airtable record |
| Otherwise | 2 | Create Airtable record |

**The current export sends high-priority failures to Jira only.** The original brief and presentation describe a broader target of Jira + Slack + Airtable. That fan-out remains a planned enhancement. The Jira configuration uses a Task issue type with `Bug:` in its summary, rather than a verified Bug issue type, label, or active-sprint assignment.

## Skills demonstrated

| Capability | Evidence in this project |
| --- | --- |
| QE process design | Failure intake, severity routing, and escalation scenarios |
| n8n orchestration | Webhook, field mapping, model chains, parsers, switch, integrations |
| Applied AI | Separate extraction and classification prompts with structured schemas |
| API integration | OpenRouter, Jira, Slack, and Airtable nodes |
| Test design | Ten synthetic failure scenarios and a PowerShell batch runner |
| Engineering judgment | Explicit distinction between expected behavior, observed evidence, and future work |

## Explore the project

| File or folder | Contents |
| --- | --- |
| [Workflow JSON](workflows/qe-test-failure-triage.json) | Sanitized importable n8n definition |
| [Setup guide](docs/setup.md) | Credentials, destination configuration, and execution |
| [Architecture](docs/architecture.md) | AI boundaries, schemas, and implementation details |
| [Cloud scaling roadmap](docs/cloud-scaling-roadmap.md) | Proposed serverless architecture and future enhancements |
| [Validation notes](docs/validation.md) | Actual report findings and known limitations |
| [Examples](examples/) | Ten standalone JSON failure payloads |
| [PowerShell runner](scripts/runtests.ps1) | Batch webhook submission and HTML report generation |
| [Sample report](reports/sample-execution-report.html) | Historical HTTP submission results |
| [Presentation](docs/presentation/automated-qe-test-triage.pptx) | Original presentation with historical claims qualified by validation notes |
| [Slide transcript](docs/presentation/slide-text.md) | Searchable text from the presentation |
| [Original source notes](docs/source/) | Brief, partial baseline log, and design rationale |

## Quick start

1. Import `workflows/qe-test-failure-triage.json` into an n8n instance that supports the included nodes. The original n8n version was not supplied.
2. Configure your OpenRouter, Jira, Slack, and Airtable credentials and replace destination placeholders. Follow the [setup guide](docs/setup.md).
3. Keep the workflow inactive while reviewing it. Enable the production webhook only after configuring your sandbox integrations.
4. Send one sample to your webhook, for example on a local instance:

   ```bash
   curl -X POST http://localhost:5678/webhook/qe-test-triage \
     -H 'Content-Type: application/json' \
     --data-binary @examples/failure-01.json
   ```

5. Inspect the n8n execution and the destination record or issue. HTTP acceptance alone does not prove successful triage.
6. To submit all ten examples with PowerShell:

   ```powershell
   ./scripts/runtests.ps1 -WebhookUrl "http://localhost:5678/webhook/qe-test-triage" -ReportPath "./QE_Test_Triage_Report.html"
   ```

Running the workflow can create real Jira tasks, Slack messages, Airtable records, and model usage charges in your configured accounts.

## Validation and limitations

The supplied historical report records **10 submissions: 7 accepted and 3 failed with HTTP 404**. It does not assert actual route selection or destination creation. The earlier validation log is incomplete. No live end-to-end revalidation was performed when preparing this repository.

The models suggest a probable root cause and classification. Structured JSON validation does not establish factual accuracy. Prompt rules overlap in places, and a single timeout is insufficient evidence that a test is flaky. Human review remains necessary.

The original presentation mentions sub-two-second Jira creation and full auditability. The supplied evidence does not establish those claims. See [validation notes](docs/validation.md) before quoting results.

## Further scope and scaling roadmap

The current project runs locally in Docker. Future work includes:

- **Reliable triage:** complete High fan-out, log every outcome, add deduplication, retries, and independent delivery to each destination.
- **Better testing decisions:** evaluate human-labelled failures, resolve classification conflicts, track flakiness across runs, and capture human feedback.
- **CI/CD integration:** receive failure events from automated test runners using validated payloads and stable event IDs.
- **Scalable n8n hosting:** use queue mode with Redis, PostgreSQL, and additional workers on managed container infrastructure.
- **Cloud serverless alternative:** rebuild the processing logic as authenticated API intake, a durable queue, serverless functions, persistent state, and independent delivery workers.
- **Operational readiness:** add monitoring, dead-letter handling, secure secret storage, retention policies, cost controls, and load testing.

**The cloud architecture is proposed future work, not an implemented deployment.** The serverless path requires a rebuild; the n8n JSON is not directly deployable as a cloud function.

See the [cloud architecture and scaling roadmap](docs/cloud-scaling-roadmap.md) for the serverless diagram, component responsibilities, and phased implementation plan.

## Feedback and contributions

Working on software testing, QE, or workflow automation? Help develop this idea further.

- **Fork the repository** to experiment with your own synthetic test scenarios and integrations.
- **Open an issue** to suggest a use case, report a problem, or challenge a classification rule.
- **Submit a pull request** with a focused improvement and details of how you verified it.
- **Star the repository** if you find it useful and want to find it again.

Contributions around CI integration, duplicate detection, classification evaluation, reliable delivery, and cloud scaling are especially welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the process.

## Author

[Yogesh Deshmukh](https://github.com/yogeshdeshmukh86) . Quality Engineering and Test Management

Built to demonstrate practical n8n automation for software testing and to invite discussion about AI-assisted QE workflows.
