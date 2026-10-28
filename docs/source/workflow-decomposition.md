> Historical source document. See [validation notes](../validation.md) for discrepancies and evidence limits.

# I → P → O Workflow Decomposition & Tagging Rationale

---

## 1. High-Level I → P → O Architecture Table

| Phase | Workflow Step | Execution Mechanism | Details & Processing Rules |
| :--- | :--- | :--- | :--- |
| **INPUT** | **1. Webhook Ingestion** | ⚙️ **LOGIC (Deterministic)** | Ingests JSON payload containing test run ID, execution status, failure logs, and stack trace via HTTP POST. |
| **PROCESSING** | **2. Schema Normalization & Extraction** | ⚙️ **LOGIC (Deterministic)** | Extracts key fields (`test_case_id`, `environment`, `error_type`, `stack_trace`) and cleans raw text into structured key-value pairs. |
| **PROCESSING** | **3. Failure Domain & Root Cause Analysis** | 🤖 **AI (LLM Reasoning)** | Evaluates unstructured log semantics to determine failure domain (e.g., Database, Memory, Network, UI) and extract probable root cause. |
| **PROCESSING** | **4. Priority & Severity Classification** | 🤖 **AI (LLM Reasoning)** | Weighs failure impact, operational environment, and error type to classify severity (`High`, `Medium`, `Low`) and routing priority. |
| **PROCESSING** | **5. Route Evaluation & Decision Branching** | ⚙️ **LOGIC (Deterministic)** | Evaluates output from classification against conditional rules via 3-way Switch node (`0: High/Critical`, `1: Medium`, `2: Low`). |
| **OUTPUT** | **6. Output Routing Execution** | ⚙️ **LOGIC (Deterministic)** | Triggers integrations according to route branch:<br>• **Route 0 (High):** Creates Jira Issue + Slack Alert + Airtable Log<br>• **Route 1 (Med):** Posts Slack Message + Airtable Log<br>• **Route 2 (Low):** Creates Airtable Log (`Records for Low Priority_severity`) |

---

## 2. Rationale for AI vs. Deterministic Logic Selection

### ⚙️ Why Deterministic Logic is Used for Steps 1, 2, 5, and 6
* **Predictability & Speed:** Data parsing, payload extraction, conditional switch rules, and API triggers follow clear, fixed business rules.
* **Cost & Latency Efficiency:** Using LLMs for basic data mapping or standard API payloads adds unnecessary latency and token costs without adding intelligence.
* **Reliability:** Deterministic routing guarantees that conditional branches execute consistently every time without model hallucinations or schema drift.

---

### 🤖 Why AI Reasoning is Used for Steps 3 and 4