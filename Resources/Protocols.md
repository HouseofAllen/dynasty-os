# System Protocols & Operational Doctrine

This document outlines the automated, self-governing protocols that ensure the resilience and reliability of the agent's operations. It is the definitive manual for the system's autonomous functions.

---

## 1. PROTOCOL DEFINITION STANDARD

### 1.1. What is a Protocol?
A Protocol is a codified, automated, and autonomous process executed by the system to perform a core operational function. Protocols are designed to be resilient, observable, and operate without human intervention.

### 1.2. Protocol Anatomy (Required Fields)
Each protocol must be documented with the following fields:
-   **ID:** A unique identifier (e.g., CP-001 for Core, MP-001 for Meta).
-   **Schedule:** The cron expression and timezone defining its execution cadence.
-   **Trigger:** The mechanism that initiates the protocol (e.g., Cron job, script call).
-   **Input:** The data or system state it reads from.
-   **Output:** The data, system state, or actions it produces.
-   **Owner:** The entity responsible (typically "System").
-   **Scope:** A clear, concise definition of its responsibilities, including what it should *not* do.
-   **Failure Modes:** A table detailing potential failures, their symptoms, and recovery procedures.
-   **Dependencies:** A list of other systems or data sources required for its operation.
-   **Rollback Procedure:** A step-by-step guide to revert the system to a known good state after a failure.

### 1.3. Protocol Lifecycle
Protocols are created, versioned, and deprecated via updates to this document, which must be committed to the `dynasty-os` repository. A protocol is considered "active" once it is documented here and its trigger mechanism is deployed.

---

## 2. CORE PROTOCOLS (Operational)

### CP-001: The Royal Chronicler (Memory Consolidation)
-   **Schedule:** Daily (04:00 America/Chicago)
-   **Trigger:** Cron job executing `consolidate-memory.ps1`
-   **Input:** All main session transcripts from the last 24 hours.
-   **Output:** Surgical edits to core `.md` files (`MEMORY.md`, `AGENTS.md`, etc.); a Git commit with changes.
-   **Owner:** System (autonomous)
-   **Scope:**
    -   Summarize explicit decisions, facts, and completed work.
    -   Do NOT infer patterns or generate new ideas.
    -   Do NOT edit files in `Archives/Insights/`.
-   **Failure Modes:**
| Failure | Symptom | Recovery |
|---|---|---|
| Sub-agent spawn fails | Script exits with error; no Git commit | MP-001 detects the cron failure; alert sent via MP-002. Manual re-run required. |
| Git commit/push fails | Sub-agent completes, but changes are not pushed | Check Git credentials & remote status; MP-002 escalates. Manual push required. |
| Timeout (>30min) | Process hangs | OpenClaw terminates the sub-agent; logged as a failure; MP-001 detects & MP-002 alerts. |
-   **Dependencies:**
    -   Requires read access to session transcripts.
    -   Requires write access to the `dynasty-os` repository.
    -   Requires Git to be authenticated to the remote.
-   **Rollback Procedure:**
    1.  `git revert <commit_hash>` to undo the Chronicler's last commit.
    2.  Manually inspect transcripts and files to identify the source of error.

### CP-002: The Alchemist (Insight Generation)
-   **Schedule:** Weekly (Sunday 18:00 America/Chicago)
-   **Trigger:** Cron job executing `synthesize-insights.ps1`
-   **Input:** All `memory/*.md` files and session transcripts from the last 7 days.
-   **Output:** New, standalone `.md` files in `Archives/Insights/`.
-   **Owner:** System (autonomous)
-   **Scope:**
    -   Hunt for implicit connections, recurring questions, and emergent themes.
    -   Produce new, thought-provoking insight notes.
    -   Do NOT edit any existing files outside of the `Archives/Insights/` directory.
-   **Failure Modes:**
| Failure | Symptom | Recovery |
|---|---|---|
| Sub-agent spawn fails | Script exits with error; no new insight notes | MP-001 detects the cron failure; alert sent via MP-002. Manual re-run required. |
| Write permission denied | Script cannot create files in `Archives/Insights/` | Check folder permissions; MP-002 escalates. |
| Timeout (>1hr) | Process hangs | OpenClaw terminates the sub-agent; logged as a failure; MP-001 detects & MP-002 alerts. |
-   **Dependencies:**
    -   Requires read access to transcripts and `memory/` directory.
    -   Requires write access to `Archives/Insights/`.
-   **Rollback Procedure:**
    1.  Delete any malformed `.md` files from the `Archives/Insights/` directory.
    2.  Manually re-run the `synthesize-insights.ps1` script.

### CP-003: Weekly Review Trigger
-   **Schedule:** Weekly (Sunday 19:00 America/Chicago)
-   **Trigger:** Cron job via `resilience-dispatcher.ps1`
-   **Input:** The prompt defined in the cron job.
-   **Output:** A new agent task in the main session to begin the Weekly Review.
-   **Owner:** System (autonomous)
-   **Scope:**
    -   To initiate the agent-led Weekly Review process as defined in `Methodology.md`.
-   **Failure Modes:**
| Failure | Symptom | Recovery |
|---|---|---|
| All models unavailable | Resilience dispatcher fails; no prompt appears | MP-001 detects the cron failure; alert sent via MP-002. |
-   **Dependencies:**
    -   Relies on CP-005 (Resilience Dispatcher).
    -   Requires at least one available LLM.
-   **Rollback Procedure:**
    1.  This is a trigger-only protocol. If it fails, the agent simply does not perform the review. The next week's trigger will run as scheduled.

### CP-004: Resilience Dispatcher
-   **Schedule:** On-demand by other protocols.
-   **Trigger:** Direct script call from a cron job (e.g., by CP-003).
-   **Input:** An agent task prompt.
-   **Output:** A successfully executed agent task.
-   **Owner:** System (autonomous)
-   **Scope:**
    -   Provide a fallback mechanism for agent tasks by cycling through available LLMs.
-   **Failure Modes:**
| Failure | Symptom | Recovery |
|---|---|---|
| All models fail | Script exits with an error after trying all models | The calling cron job is logged as a failure; MP-001/MP-002 handle the alert. |
-   **Dependencies:**
    -   Requires a configured list of LLM endpoints.
-   **Rollback Procedure:**
    1.  Not applicable. This protocol does not alter system state directly.

---

## 3. META-PROTOCOLS (Observability & Reliability)

### MP-001: Protocol Health Check
-   **Schedule:** Daily (05:00 America/Chicago)
-   **Trigger:** Cron job executing `run-system-check.ps1`
-   **Input:** OpenClaw's `cron/state.json` log file.
-   **Output:** An alert message sent via MP-002 if failures are detected.
-   **Owner:** System (autonomous)
-   **Scope:**
    -   To monitor the execution status of all critical Core Protocols.
    -   To detect failures and trigger the notification protocol.
-   **Failure Modes:**
| Failure | Symptom | Recovery |
|---|---|---|
| `state.json` unreadable | Script exits with error | This is a critical failure. Manual intervention required to check OpenClaw's health. |
-   **Dependencies:**
    -   Depends on the integrity of OpenClaw's internal cron logging.
    -   Calls MP-002 to send notifications.
-   **Rollback Procedure:**
    1.  Not applicable. This is a read-only check.

### MP-002: Failure Notification System
-   **Schedule:** On-demand by other protocols.
-   **Trigger:** Direct script call from a protocol (e.g., MP-001).
-   **Input:** A formatted alert message.
-   **Output:** A message sent to the user's configured channel (e.g., Telegram).
-   **Owner:** System (autonomous)
-   **Scope:**
    -   To be the single, standardized method for dispatching system alerts.
-   **Failure Modes:**
| Failure | Symptom | Recovery |
|---|---|---|
| Messaging API fails | Script exits with error; alert is not sent | The failure is logged to the console, but the alert is lost. This is the final link in the chain. |
-   **Dependencies:**
    -   Requires a working OpenClaw `message` tool configuration.
-   **Rollback Procedure:**
    1.  Not applicable. This protocol does not alter system state.

### MP-003: Cascade Failure Detection (Not Implemented)
-   **Purpose:** To detect scenarios where multiple, seemingly unrelated protocols fail in a short period, indicating a deeper systemic issue.

### MP-004: System State Audit (Not Implemented)
-   **Purpose:** To periodically audit the state of the repository and system to ensure it aligns with the documented methodologies (e.g., no orphan projects, all insights are correctly formatted).

---

## 4. PROTOCOL DEPENDENCY MAP

```
[Cron Scheduler] -> [CP-001: Chronicler]
[Cron Scheduler] -> [CP-002: Alchemist]

[Cron Scheduler] -> [CP-003: Weekly Review] -> [CP-004: Resilience Dispatcher]

[Cron Scheduler] -> [MP-001: Health Check] -> [MP-002: Notification System]
```
