# System Protocols

This document outlines the automated, self-governing protocols that ensure the resilience and reliability of the agent's operations. A Protocol is an automated system that executes a core function without requiring manual intervention.

---

## 1. Protocol: Resilient Execution

-   **ID:** P-001
-   **Purpose:** To prevent agent-based cron job failures due to API rate-limiting or single-model outages.
-   **Mechanism:** The `resilience-dispatcher.ps1` script. Instead of invoking an agent task directly, cron jobs call this dispatcher.
-   **Process:**
    1.  The dispatcher receives the agent task prompt.
    2.  It attempts to execute the task using the primary (default) model.
    3.  If the execution fails with a recognized rate-limit or API error, the script automatically cycles to the next model in a predefined list of free/fallback LLMs.
    4.  It continues this process until the task succeeds or the model list is exhausted.
-   **Failure Condition:** The task cannot be successfully completed by any model in the list.
-   **Current Recovery:** None. The job fails silently. This is a known vulnerability to be addressed by Protocol P-002.

---

## 2. Protocol: Sub-Agent Delegation

-   **ID:** P-002
-   **Purpose:** To ensure complex, high-level cognitive tasks are performed in isolated, focused, and reliable environments.
-   **Mechanism:** Standardized PowerShell scripts (`consolidate-memory.ps1`, `synthesize-insights.ps1`) that use the `openclaw sessions spawn` command.
-   **Process:**
    1.  A cron job executes the delegator script.
    2.  The script provides a highly-detailed, role-specific prompt to a new, isolated sub-agent session.
    3.  The sub-agent executes its task with a defined timeout and then terminates.
-   **Failure Condition:** The `openclaw sessions spawn` command fails, or the sub-agent itself errors out or hits its execution timeout.
-   **Current Recovery:** None. The job fails silently.

---

## 3. Protocol: System Heartbeat (IN DEVELOPMENT)

-   **ID:** P-003
-   **Purpose:** To provide meta-reliability. This protocol monitors the health and successful execution of all other core protocols.
-   **Mechanism:** A daily "dead man's switch" script (`run-system-check.ps1`) that runs after all other critical tasks.
-   **Process:**
    1.  The script will access the OpenClaw cron job execution logs.
    2.  It will scan the logs from the last 24 hours for any entries marked with a "failure" or "error" status.
    3.  If no errors are found, it exits silently.
    4.  If any critical job has failed (e.g., The Chronicler, The Alchemist, any resilient task), it will immediately dispatch a high-priority alert message to the King, detailing which protocol failed and when.
-   **Failure Condition:** This script itself fails to run. (This represents the lowest possible level of systemic failure.)
-   **Recovery:** Manual intervention.
