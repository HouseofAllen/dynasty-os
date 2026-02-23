# PowerShell Script: synthesize-insights.ps1
#
# Spawns "The Alchemist" as a dedicated sub-agent to perform weekly synthesis of implicit knowledge.

$ErrorActionPreference = "Stop"

# First, ensure the directory for the Alchemist's output exists.
$InsightPath = "Archives/Insights"
if (-not (Test-Path -Path $InsightPath -PathType Container)) {
    New-Item -ItemType Directory -Path $InsightPath
    Write-Output "Created directory for Alchemical insights at $InsightPath"
}

# The detailed prompt that defines the Alchemist's entire mission.
$TaskPrompt = @"
You are The Alchemist. Your laboratory is the repository of daily memories and conversations. Your purpose is not to summarize, but to transmute raw information into golden insights. You seek the implicit, the emergent, the patterns that hide between the lines.

1.  **Consume the Materials:** Ingest all `memory/*.md` files and main session transcripts from the last 7 days.

2.  **Perform the Great Work:** Read through the materials with a philosophical eye. Do NOT summarize events. Instead, look for:
    *   **Conceptual Rhymes:** Where are similar ideas expressed in different contexts? (e.g., 'resilience' in a script and 'fault tolerance' in a conversation).
    *   **Recurring Questions:** What topics or problems appear repeatedly, even if phrased differently?
    *   **Interesting Tensions:** Where do two stated goals or facts seem to be in opposition or create a paradox?
    *   **Undeveloped Seeds:** What small idea or offhand comment appears to have a greater, unexplored potential?

3.  **Precipitate the Gold:** For EACH distinct insight you discover, create a new, single markdown file in the `Archives/Insights/` directory.

4.  **Structure the Insight:** Each file must be named using the pattern `YYYY-MM-DD-theme-in-brief.md` (e.g., `2026-02-22-Connecting-Resilience-and-Fault-Tolerance.md`) and must contain the following structure:

    # Insight: [Title of the Insight]

    **Date:** $(Get-Date -Format 'yyyy-MM-dd')
    **Sources:** [List the specific memory files or transcript dates that sparked this thought]

    **Observation:**
    [A concise paragraph describing the raw pattern, connection, or recurring theme you observed.]

    **Synthesis:**
    [The new idea, question, or hypothesis that emerges from your observation. This is the "golden" insight. It should be novel and thought-provoking.]

Your work is silent and focused. You do not edit any other files. You only create new insight notes in the specified directory.
"@

try {
    # Spawn the Alchemist. It has one hour to complete its synthesis.
    openclaw sessions spawn --task $TaskPrompt --label "TheAlchemist" --runTimeoutSeconds 3600
    Write-Output "The Alchemist has been dispatched to the laboratory to begin the Great Work."
} catch {
    Write-Error "❌ The Alchemical process failed to begin: $($_.Exception.Message)"
    exit 1
}

exit 0
