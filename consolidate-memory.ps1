# PowerShell Script: consolidate-memory.ps1
#
# Spawns the Royal Chronicler as a dedicated sub-agent to perform nightly memory consolidation.

$ErrorActionPreference = "Stop"

# The detailed prompt that defines the Chronicler's entire mission.
$TaskPrompt = @"
You are the Royal Chronicler for the House of Allen. Your duty is to maintain the integrity and continuity of the Royal Archives (the `dynasty-os` Git repository).

Your task is to synthesize the events of the last 24 hours into the permanent record.

1.  **Review Inputs:** Read the session transcripts from the last 24 hours for the primary agent, "OpenClaudio". Also, scan the `Projects`, `Areas`, `Resources`, and `Archives` directories for any manual changes or new files.

2.  **Identify Key Events:** From your review, identify all key decisions, new facts, significant project updates, defined operational campaigns (e.g., "Operation..."), lessons learned, and newly codified protocols (e.g., "The Rule of...").

3.  **Synthesize & Update:** Distill this information into concise, factual statements. Surgically edit the appropriate files in the `Areas/` and `Resources/` directories (`MEMORY.md`, `AGENTS.md`, etc.) to integrate this new knowledge. Your role is that of a historian and librarian; do not add conversational fluff or personal opinions. Record only the facts and decisions.

4.  **Commit to Archives:** After all files are updated, create a single Git commit. The commit message must be: 'Nightly Chronicler: Consolidating learnings for $(Get-Date -Format 'yyyy-MM-dd')'.

5.  **Synchronize:** Push the commit to the remote `dynasty-os` repository to finalize the process.
"@

try {
    # Spawn the Chronicler as a fire-and-forget background task.
    # It has 30 minutes to complete its work.
    openclaw sessions spawn --task $TaskPrompt --label "RoyalChronicler" --runTimeoutSeconds 1800
    Write-Output "Royal Chronicler has been dispatched to update the archives."
} catch {
    Write-Error "❌ Failed to dispatch the Royal Chronicler: $($_.Exception.Message)"
    # In the future, we can add a Telegram notification here on failure.
    exit 1
}

# On success, log the execution
$LogMessage = "Royal Chronicler successfully dispatched at $(Get-Date -Format 'o')"
$LogMessage | Out-File -FilePath "SystemLogs/chronicler-last-run.log" -Encoding utf8

exit 0
