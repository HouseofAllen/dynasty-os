# PowerShell Script: run-system-check.ps1
#
# Protocol P-003: System Heartbeat
# This script provides meta-reliability by checking the health of other critical cron jobs.

$ErrorActionPreference = "Stop"

# Define the location of the OpenClaw cron job state file.
# This file contains the history and status of recent job runs.
$CronStateFile = "C:\Users\User\.openclaw\cron\state.json"

if (-not (Test-Path -Path $CronStateFile)) {
    Write-Error "CRITICAL: Cron state file not found at $CronStateFile. Cannot perform system check."
    exit 1
}

# Load the job history from the state file.
$CronState = Get-Content -Path $CronStateFile | ConvertFrom-Json

# Define the names of critical jobs to monitor.
$CriticalJobs = @(
    "morning-briefing",
    "night-watch",
    "evening-briefing",
    "daily-backup-and-sanitize",
    "nightly-memory-consolidation",
    "TheAlchemist-WeeklySynthesis"
)

# Look for failures in the last 24 hours (86,400,000 milliseconds).
$24HoursAgoMs = (Get-Date).AddDays(-1).ToUniversalTime().Subtract((Get-Date "1970-01-01")).TotalMilliseconds
$FailedJobs = @()

foreach ($job in $CronState.history) {
    if ($job.lastRunAtMs -ge $24HoursAgoMs -and $CriticalJobs -contains $job.name) {
        if ($job.lastStatus -ne "ok") {
            $FailedJobs += [PSCustomObject]@{
                Name       = $job.name
                Status     = $job.lastStatus
                Error      = $job.lastError
                FinishedAt = [datetimeoffset]::FromUnixTimeMilliseconds($job.lastRunAtMs).ToLocalTime().ToString("g")
            }
        }
    }
}

if ($FailedJobs.Count -gt 0) {
    # If failures are found, construct a detailed alert message.
    $AlertMessage = "🚨 **SYSTEM ALERT: Critical Protocol Failure Detected** `n`"
    $AlertMessage += "The following automated jobs have failed within the last 24 hours:`n`"
    
    foreach ($failure in $FailedJobs) {
        $AlertMessage += "`n- **Job:** $($failure.Name)"
        $AlertMessage += "`n  - **Status:** $($failure.Status)"
        $AlertMessage += "`n  - **Finished:** $($failure.FinishedAt)"
        $AlertMessage += "`n  - **Error:** $($failure.Error)"
    }

    try {
        # Dispatch the alert via the messaging tool.
        openclaw message send --to "telegram:5606217485" --message $AlertMessage
        Write-Output "Alert successfully dispatched."
    } catch {
        Write-Error "Failed to dispatch system alert: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Output "System check complete. All critical protocols are nominal."
}

exit 0
