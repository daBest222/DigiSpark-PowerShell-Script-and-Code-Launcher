# ============================================================
# DigiSpark Project - Windows Uninstallation Script
# ============================================================
#
# This script removes scheduled tasks created by the DigiSpark project,
# uninstalls dependencies installed by the setup script, and cleans up project files.

# ============================================================

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

# Directory containing this PowerShell script.
$projectDirectory = $PSScriptRoot

# Log file.
$logFile = Join-Path $projectDirectory "uninstall.log"

# Configuration file (JSONC format).
$configFile = Join-Path $projectDirectory "config.jsonc"

# Uninstall configuration file (JSON format).
$uninstallConfigFile = Join-Path $projectDirectory "uninstall_config.json"


# ------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------

# Log levels:
# INFO     - General information
# WARNING  - Unexpected conditions
# ERROR    - Operation failed
# SUCCESS  - Operation completed

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"

    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}


# ------------------------------------------------------------
# LOAD CONFIGURATION
# ------------------------------------------------------------

if (-Not (Test-Path $configFile)) {
    Write-Log "Configuration file not found: $configFile" "ERROR"
    exit 1
}

$config = Get-Content -Raw -Path $configFile | ConvertFrom-Json

if (-Not (Test-Path $uninstallConfigFile)) {
    Write-Log "Uninstall configuration file not found: $uninstallConfigFile" "ERROR"
    exit 1
}

$uninstallConfig = Get-Content -Raw -Path $uninstallConfigFile | ConvertFrom-Json


# ------------------------------------------------------------
# INITIALISE
# ------------------------------------------------------------

Write-Log "Uninstall script started."
Write-Log "Project directory: $projectDirectory"
Write-Log "Configuration file: $configFile"
Write-Log "Log file: $logFile"
Write-Log "Uninstalling scheduled tasks and cleaning up files."

# ------------------------------------------------------------
# REMOVE SCHEDULED TASKS
# ------------------------------------------------------------

foreach ($task in $config.tasks) {
    $taskName = $task.name

    try {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction Stop
        Write-Log "Successfully stopped scheduled task: $taskName" "SUCCESS"
    } catch {
        Write-Log "Could not stop scheduled task: $taskName. It may not be running. Error: $_" "WARNING"
    }

    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
        Write-Log "Successfully removed scheduled task: $taskName" "SUCCESS"
    } catch {
        Write-Log "Failed to remove scheduled task: $taskName. Error: $_" "ERROR"
    }
}


# ------------------------------------------------------------
# UNINSTALL DEPENDENCIES
# ------------------------------------------------------------

foreach ($dependency in $uninstallConfig.dependenciesToUninstall) {
    Write-Log "Attempting to uninstall dependency: $($dependency.name)"
    try {
        winget uninstall --id $($dependency.id) --silent --accept-source-agreements
        Write-Log "Successfully uninstalled dependency: $($dependency.name)" "SUCCESS"
    } catch {
        Write-Log "Failed to uninstall dependency: $($dependency.name). Error: $_" "ERROR"
    }
}


# ------------------------------------------------------------
# CLEAN UP FILES
# ------------------------------------------------------------

$parentFolder = Split-Path -Parent $projectDirectory
Write-Log "Removing project folder: $parentFolder"
Write-Log "After this is done, you will not be able to view the log file but you can see the following output in the terminal."

Remove-Item -Path $projectDirectory -Recurse -Force
Write-Log "Successfully cleaned up project files." "SUCCESS"


# ------------------------------------------------------------
# FINISH
# ------------------------------------------------------------

Write-Host "Uninstallation completed. The project folder has been removed and the scheduled tasks have been cleaned up."
