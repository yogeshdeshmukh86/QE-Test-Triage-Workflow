> Original presentation transcript. Historical claims require the qualifications in [validation notes](../validation.md).

## Slide 1

QE AUTOMATION PIPELINE  |  VOLTA COFFEE ROASTERS

Defect Triage, Automated.

Detect faster. Route instantly. Trace every failure.

AI-powered failure classification that cuts Mean Time to Detect and builds an automatic audit trail for every test run.

Faster detection

Lower MTTD

Instant escalation

Critical failures to Jira in seconds

Full auditability

Every run logged and traceable

Built with n8n  •  LLM (OpenRouter)  •  Jira  •  Slack  •  Airtable

Author: yogesh Deshmukh

## Slide 2

  PROBLEM & CONTEXT

Triage Is the Hidden Bottleneck

Manual log digging

Engineers read stack traces across test runs by hand, burning hours before any fix starts.

Critical failures buried

Crashes and DB timeouts sit among noisy, flaky results, so escalation is delayed.

Inconsistent decisions

Severity and ownership depend on who happens to look, and nothing is logged for trends.

Goal: automatic intake, classification and routing of every failure, with Mean Time to Detect reduced.

Author: yogesh Deshmukh

## Slide 3

    HIGH-LEVEL WORKFLOW

One Webhook, Two AI Steps, Three Routes

1

Webhook

Receives JSON test payload: run, app, error, stack trace

›

2

Prepare

Cleans and maps fields for the AI steps

›

3

Extract

LLM pulls root cause, failure domain, failing component

›

4

Classify

LLM assigns Priority and Severity

›

5

Route

3-way switch sends each failure to its action

Author: yogesh Deshmukh

## Slide 4

2 MIN  |  KEY OUTPUTS

Severity Decides Where Each Failure Goes

HIGH / CRITICAL

Jira Task titled "Bug: …" in active sprint + Slack alert + Airtable log

e.g. OutOfMemoryError, DB timeout

MEDIUM

Slack alert for team triage + Airtable log

Needs a look, not an emergency

LOW / FLAKY

Silent Airtable log for flakiness analytics

Trend data, no noise

Author: yogesh Deshmukh

## Slide 5

ROUTING LOGIC

Switch Node Routing Rules

Author: yogesh Deshmukh

Rule

Condition (first match wins)

Route to

Output

1

Priority is High OR

severity is High

Jira 

ticket creation with bug label

0

2

Rule 1 does not match, AND

priority or severity is Medium

Slack & 

Airtable

1

3

Otherwise (including Low or Flaky)

Airtable Flaky Tracker

2

## Slide 6

  MAIN INSIGHTS

Validated with Simulated Failure Payloads

100%

automated ingestion target: every webhook payload processed, no manual step

High

severity assigned to fatal JVM crash (OutOfMemoryError) and escalated to Jira

< 2 s

end-to-end from webhook to Jira ticket in demo runs

Invoke-RestMethod -Uri "http://localhost:5678/webhook/..." -Method POST \

  -Body '{ "test_case_id": "TC-CRASH-001", "error_type": "java.lang.OutOfMemoryError" }'

Author: yogesh Deshmukh

## Slide 7

  CONCLUSION & LIMITS

Strong Start, Honest Boundaries

What works

• Zero manual effort for first-pass triage

• Consistent, rich Jira tickets in Markdown

• Full audit trail of every run in Airtable

• Critical failures reach engineers immediately

Current limits

• No duplicate-ticket check yet

• Depends on valid LLM structured output

• Needs webhook connectivity; JSON only

• Tested on a small simulated sample

Conclusion: the pipeline turns triage from a chore into an automatic, auditable step.

Author: yogesh Deshmukh

## Slide 8

  WHAT CAN BE ENHANCED

Next Steps to Make It Production-Ready

Duplicate detection

Search Jira before creating, comment on existing tickets instead

CI/CD integration

Connect to real runners (Jenkins, GitHub Actions) beyond simulated payloads

Error handling

Retries and fallback when LLM output or APIs fail

Analytics dashboard

Trend and flakiness reports built on Airtable data

Accuracy evals

Measure classification against labelled failures and tune prompts

Human feedback loop

Let engineers correct severity to improve results

Author: yogesh Deshmukh

## Slide 9

Thank You

Questions and discussion

Author: yogesh Deshmukh