> Historical source document. See [validation notes](../validation.md) for discrepancies and evidence limits.

# Project Brief: Automated QE Test Failure Triage Engine

## 1\. Executive Summary \& Purpose

The **Automated QE Test Failure Triage Engine** is an intelligent quality engineering pipeline designed to automate the intake, classification, and routing of automated test suite failures. By utilizing structured extraction and LLM-driven classification, the engine replaces manual, fragmented error log reviews with automated severity-based triage, reducing Mean Time to Detect (MTTD) and accelerating defect logging.

\---

## 2\. Trigger Mechanics \& Pipeline Architecture

* **Trigger Source:** HTTP Webhook receiving automated test execution payloads (simulated via batch scripts or continuous integration test runners).
* **Payload Contents:** Standardized JSON containing `test\_run\_id`, `environment`, `application`, `test\_case\_id`, `test\_name`, `error\_type`, `error\_message`, and raw `stack\_trace`.
* **Processing Steps:**

  1. **Extraction:** Standardizes raw log data into structured components and failure domains using JSON output parsers.
  2. **LLM Classification:** Evaluates failure semantics to assign precise `Priority` and `Severity` classifications.
  3. **Conditional Routing:** Evaluates priority matrix scores via a 3-way Switch node to trigger downstream actions.

\---

## 3\. Workflow Outputs \& Routing Rules

|Priority / Severity|Primary Action|Target Systems \& Artifacts|
|-|-|-|
|**High / Critical (Output 0)**|Instant Engineering Escalation|Creates a Jira Issue (Task in active Sprint, marked as Bug), posts a high-priority Slack alert, and logs the incident in Airtable.|
|**Medium (Output 1)**|Operational Notification|Posts an alert to Slack for team triage and logs the entry in Airtable.|
|**Low / Flaky (Output 2)**|Silent Tracking \& Analytics|Logs execution metrics directly to Airtable (`Records for Low Priority\_severity`) for pattern and flakiness analysis.|

\---

## 4\. Definition of Success (KPIs)

* **100% Automated Ingestion:** Successful processing of all webhook test failure payloads without manual intervention.
* **Accurate Severity Routing:** Zero misclassifications of critical system crashes (e.g., `OutOfMemoryError`, database timeouts) ensuring immediate Jira escalation.
* **Rich Contextual Jira Escalation:** Jira tickets automatically populated with test metadata, stack traces, identified components, and actionable root-cause recommendations formatted in Markdown.
* **Comprehensive Audit Trail:** 100% logging of test failure runs across all severity tiers in Airtable for historical trends.

\---

## 5\. Scope Boundaries

### In Scope

* Ingestion of JSON-formatted test execution logs via Webhook.
* Extraction of root cause, failure domain, and failing component.
* LLM-driven severity and priority classification.
* Routing across Jira, Slack, and Airtable integrations.

### Out of Scope

* **Auto-healing or Automated Code Fixes:** The pipeline triages and reports issues; it does not automatically commit code or fix scripts.
* **Direct Customer Communication:** Workflow outputs are strictly internal (Jira, Slack, internal DBs).
* **Non-JSON Log Ingestion:** Unstructured raw log files (e.g., raw `.log` text blobs) without a Webhook wrapper are excluded.

