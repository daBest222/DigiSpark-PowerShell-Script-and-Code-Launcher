# ============================================================
# DigiSpark Project - Windows Setup
# ============================================================
#
# Automatically checks and installs selected dependencies,
# then downloads project files beside this PowerShell script.
#
# Requirements:
# - Windows 10/11
# - PowerShell
# - winget
#
# ============================================================


# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

# Directory containing this PowerShell script.
$projectDirectory = $PSScriptRoot

# Log file.
$logFile = Join-Path $projectDirectory "setup.log"

# Configuration file (JSONC format).
$configFile = Join-Path $projectDirectory "config.jsonc"


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


# ------------------------------------------------------------
# INITIALISE
# ------------------------------------------------------------

Write-Log "Setup started."
Write-Log "Project directory: $projectDirectory"
Write-Log "Configuration file: $configFile"
Write-Log "Log file: $logFile"


# ------------------------------------------------------------
# CHECK WINGET
# ------------------------------------------------------------

$winget = Get-Command winget -ErrorAction SilentlyContinue

if (-not $winget) {
    Write-Log "Windows Package Manager (winget) is unavailable." "ERROR"
    Write-Host "Install or update App Installer from Microsoft Store."
    exit 1
}


# ------------------------------------------------------------
# CHECK AND INSTALL DEPENDENCIES
# ------------------------------------------------------------

$uninstallConfig = @{
    "existingDependencies" = @()
    "dependenciesToUninstall" = @()
}

foreach ($dependency in $config.dependencies) {

    $installed = Get-Command $dependency.command `
        -ErrorAction SilentlyContinue

    if ($installed) {
        uninstallConfig.existingDependencies += $dependency
        Write-Log "$($dependency.name) is already installed." "SUCCESS"
        continue
    }

    Write-Log "$($dependency.name) is missing." "WARNING"
    Write-Log "Installing $($dependency.name)."

    & winget install `
        --id $dependency.package `
        -e `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        uninstallConfig.dependenciesToUninstall += $dependency
        Write-Log "$($dependency.name) installation completed." "SUCCESS"
    }
    else {
        Write-Log "$($dependency.name) installation failed." "ERROR"
    }
}

$uninstallConfig | ConvertTo-Json -Depth 3 | Set-Content -Path (Join-Path $projectDirectory "uninstall_config.json")


# ------------------------------------------------------------
# DOWNLOAD PROJECT FILES
# ------------------------------------------------------------

foreach ($file in $$config.files) {

    $outputPath = Join-Path $projectDirectory $file.name

    try {
        Write-Log "Downloading $($file.name)..."

        Invoke-WebRequest `
            -Uri $file.url `
            -OutFile $outputPath `
            -ErrorAction Stop

        Write-Log "Downloaded $($file.name)." "SUCCESS"
    }
    catch {
        Write-Log "Failed to download $($file.name)." "ERROR"
        Write-Log $_.Exception.Message "ERROR"
    }
}

# ------------------------------------------------------------
# SETUP TASK SCHEDULER
# ------------------------------------------------------------

foreach ($task in $config.tasks) {

    try {
        Write-Log "Creating scheduled task: $($task.name)..."

        $action = New-ScheduledTaskAction -Execute $task.action
        $trigger = New-ScheduledTaskTrigger -AtStartup
        Register-ScheduledTask -TaskName $task.name -Action $action -Trigger $trigger -Force

        Write-Log "Scheduled task created: $($task.name)." "SUCCESS"

        if ($task.runNow) {
            Write-Log "Running scheduled task: $($task.name)..."
            Start-ScheduledTask -TaskName $task.name
            Write-Log "Scheduled task started: $($task.name)." "SUCCESS"
        }
    }
    catch {
        Write-Log "Failed to create or run scheduled task: $($task.name)." "ERROR"
        Write-Log $_.Exception.Message "ERROR"
    }
}

# ------------------------------------------------------------
# DOWNLOAD UNINSTALL SCRIPT
# ------------------------------------------------------------

Write-Log "Downloading uninstall script..."
Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/daBest222/DigiSpark-PowerShell-Script-and-Code-Launcher/main/Scripts/uninstall.ps1" `
    -OutFile "uninstall.ps1" `
    -ErrorAction Stop

Write-Log "Uninstall script downloaded." "SUCCESS"

# ------------------------------------------------------------
# FINISH
# ------------------------------------------------------------

Write-Log "Setup completed."
Write-Host "Check the log file for details: $logFile"
Write-Host "The project files have been downloaded to: $projectDirectory"
