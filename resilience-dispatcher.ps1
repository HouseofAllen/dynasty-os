# PowerShell Script: resilience-dispatcher.ps1
#
# Operation Resilience: Smart dispatcher to cycle through free models on API rate limit errors.
# 1. Defines an ordered list of free models.
# 2. Accepts a task message as a parameter.
# 3. Loops through the models, attempting to spawn a sub-agent for the task.
# 4. If a rate limit error is detected, it tries the next model.
# 5. If any other error occurs, it fails immediately.
# 6. If all models fail with rate limits, it sends a final failure notification.

param (
    [Parameter(Mandatory=$true)]
    [string]$Task,
    [string]$TelegramChatId = "5606217485"
)

# --- Configuration ---
$ErrorActionPreference = "Stop"

# Ordered list of models to try, from most to least preferred.
$ModelPreference = @(
    "openrouter/qwen/qwen3-coder-480b:free",
    "openrouter/openai/gpt-oss-120b:free",
    "openrouter/stepfun/step-3.5-flash:free",
    "openrouter/z-ai/glm-4.5-air:free"
)

# --- Functions ---

function Send-TelegramMessage {
    param ([string]$Message)
    try {
        openclaw message send --channel telegram --target $TelegramChatId --message $Message
    } catch {
        Write-Error "CRITICAL: Failed to send Telegram failure notification: $_"
    }
}

# --- Main Execution ---

$taskCompleted = $false
$lastError = ""

foreach ($model in $ModelPreference) {
    try {
        Write-Host "Attempting task with model: $model"
        
        # Execute the task in an isolated, background session.
        # Timeout after 10 minutes (600 seconds).
        openclaw sessions spawn --task $Task --model $model --runTimeoutSeconds 600
        
        Write-Host "Task completed successfully with model: $model"
        $taskCompleted = $true
        break # Exit the loop on success
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -match "rate limit" -or $errorMessage -match "quota") {
            Write-Warning "Rate limit hit for model $model. Trying next model."
            $lastError = "Rate limit on $model"
            continue # Go to the next model
        } else {
            # This is a non-recoverable error, fail immediately.
            $fatalError = "❌ Operation Resilience FAILED with a fatal error on model '$model': $errorMessage"
            Write-Error $fatalError
            Send-TelegramMessage $fatalError
            exit 1 # Exit with a non-zero status code
        }
    }
}

if (-not $taskCompleted) {
    $finalFailureMessage = "❌ Operation Resilience FAILED: All models hit API rate limits. The task '$Task' could not be completed."
    Write-Error $finalFailureMessage
    Send-TelegramMessage $finalFailureMessage
    exit 1
}

Write-Host "Operation Resilience finished successfully."
exit 0
