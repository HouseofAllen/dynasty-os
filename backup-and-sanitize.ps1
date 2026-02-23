# PowerShell Script: backup-and-sanitize.ps1
#
# 1. Defines all critical file paths for OpenClaw configuration and personality.
# 2. Creates a temporary, isolated directory to stage the backup.
# 3. Copies all critical files into the staging directory.
# 4. Scans the staged files for known secret patterns (API keys, tokens) and replaces them with placeholders.
# 5. Initializes a Git repository in the staging area, commits the sanitized files, and pushes to the 'dynasty-os' remote.
# 6. Cleans up the temporary directory after completion.
# 7. Sends a confirmation or error message to Telegram.

param (
    [string]$TelegramChatId = "5606217485"
)

# --- Configuration ---
$ErrorActionPreference = "Stop"
$OCBaseDir = "C:\Users\User\.openclaw"
$WorkspaceDir = "$OCBaseDir\workspace"
$TempBackupDir = Join-Path $OCBaseDir "temp-backup-staging"
$RepoUrl = "https://github.com/HouseofAllen/dynasty-os.git"

$CriticalFiles = @(
    "$OCBaseDir\openclaw.json",
    "$OCBaseDir\cron\jobs.json",
    "$WorkspaceDir\SOUL.md",
    "$WorkspaceDir\MEMORY.md",
    "$WorkspaceDir\AGENTS.md",
    "$WorkspaceDir\USER.md",
    "$WorkspaceDir\TOOLS.md",
    "$WorkspaceDir\IDENTITY.md",
    "$WorkspaceDir\HEARTBEAT.md"
)

# --- Functions ---

function Send-TelegramMessage {
    param ([string]$Message)
    try {
        openclaw message send --channel telegram --target $TelegramChatId --message $Message
    } catch {
        Write-Error "Failed to send Telegram message: $_"
    }
}

function Cleanup {
    if (Test-Path $TempBackupDir) {
        Remove-Item -Recurse -Force $TempBackupDir
    }
}

# --- Main Execution ---

try {
    # 1. Setup staging area
    Cleanup
    New-Item -ItemType Directory -Force $TempBackupDir
    cd $TempBackupDir
    git clone $RepoUrl .

    # 2. Copy critical files
    foreach ($file in $CriticalFiles) {
        if (Test-Path $file) {
            Copy-Item -Path $file -Destination $TempBackupDir -Force
        } else {
            throw "Critical file not found: $file"
        }
    }

    # 3. Sanitize secrets in staged files
    $FilesToSanitize = @("openclaw.json", "jobs.json")
    foreach ($fileName in $FilesToSanitize) {
        $filePath = Join-Path $TempBackupDir $fileName
        $content = Get-Content $filePath -Raw
        
        # Replace Discord Bot Token
        $content = $content -replace '"(botToken|token)": ".*?"', '"$1": "[DISCORD_BOT_TOKEN]"'
        # Replace Telegram Bot Token
        $content = $content -replace '"botToken": ".*?"', '"botToken": "[TELEGRAM_BOT_TOKEN]"'
        # Replace Google API Key
        $content = $content -replace '"apiKey": "AIzaSy.*?"', '"apiKey": "[GOOGLE_API_KEY]"'
        # Replace Generic Tokens
        $content = $content -replace '"token": ".*?"', '"token": "[GENERIC_AUTH_TOKEN]"'

        Set-Content -Path $filePath -Value $content
    }

    # 4. Commit and Push
    git config user.name "OpenClaudio Backup Bot"
    git config user.email "bot@houseofallen.local"
    git add .
    
    $status = git status --porcelain
    if ($status) {
        $commitMessage = "Automated Backup: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git commit -m $commitMessage
        git push origin master
        Send-TelegramMessage "✅ Daily backup complete. Changes pushed to dynasty-os."
    } else {
        Send-TelegramMessage "✅ Daily backup check complete. No changes detected."
    }

} catch {
    $errorMessage = "❌ Daily backup FAILED: $($_.Exception.Message)"
    Write-Error $errorMessage
    Send-TelegramMessage $errorMessage
} finally {
    # 5. Cleanup
    Cleanup
}
