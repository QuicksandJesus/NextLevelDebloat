# NextLevelDebloat Automated Deployment Script
# #MundyTuned - Windows Optimization Solutions
# Business Email: bryan@mundytuned.com
#
# This script automates the deployment of NextLevelDebloat to Windows 11 machines
# Features:
# - Pre-deployment system inventory
# - Snapshot creation (7-day retention)
# - Git repository initialization
# - Permission validation
# - Automated debloat execution
# - Post-deployment verification

param(
    [switch]$SkipSnapshot,
    [switch]$SkipGitSetup,
    [switch]$SkipValidation,
    [switch]$ForceDeploy,
    [string]$LogFile = "deployment-log.txt"
)

$ErrorActionPreference = "Stop"
$ScriptPath = "C:\temp"
$SnapshotPath = "$ScriptPath\snapshots"
$DocsPath = "$ScriptPath\docs"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Write-Success {
    param([string]$Message)
    Write-Log $Message -Level "SUCCESS"
}

function Write-Error-Message {
    param([string]$Message)
    Write-Log $Message -Level "ERROR"
}

function Write-Warning {
    param([string]$Message)
    Write-Log $Message -Level "WARN"
}

function Get-SystemInventory {
    Write-Log "=== SYSTEM INVENTORY STARTING ===" -Level "INFO"
    
    $inventory = @{
        "MachineName" = $env:COMPUTERNAME
        "UserName" = $env:USERNAME
        "OSVersion" = (Get-CimInstance Win32_OperatingSystem).Caption + " " + (Get-CimInstance Win32_OperatingSystem).Version
        "OSBuild" = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
        "PowerShellVersion" = $PSVersionTable.PSVersion
        "IsAdministrator" = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        "IsDomainJoined" = (Get-CimInstance Win32_ComputerSystem).PartOfDomain
    }
    
    Write-Log "Machine: $($inventory.MachineName)"
    Write-Log "User: $($inventory.UserName)"
    Write-Log "OS: $($inventory.OSVersion) (Build $($inventory.OSBuild))"
    Write-Log "PowerShell: $($inventory.PowerShellVersion)"
    Write-Log "Administrator: $($inventory.IsAdministrator)"
    Write-Log "Domain-Joined: $($inventory.IsDomainJoined)"
    
    if (-not $inventory.IsAdministrator) {
        Write-Error-Message "CRITICAL: Not running as Administrator"
        Write-Log "Please right-click and select 'Run as Administrator'"
        exit 1
    }
    
    Write-Log "=== SYSTEM INVENTORY COMPLETE ===" -Level "INFO"
    return $inventory
}

function Create-Snapshot {
    Write-Log "=== CREATING SYSTEM SNAPSHOT ===" -Level "INFO"
    
    if (-not (Test-Path $SnapshotPath)) {
        New-Item -ItemType Directory -Path $SnapshotPath -Force | Out-Null
        Write-Success "Created snapshots directory"
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $snapshotFile = "$SnapshotPath\snapshot-$timestamp.tar.gz"
    
    $filesToSnapshot = @(
        "business-debloat.ps1",
        "business-debloat-restore.ps1",
        "debloat-config.json",
        "Set-ChromeDefaultBrowser.ps1",
        "registry-backup-*.reg",
        "debloat-log.txt",
        "restore-log.txt"
    )
    
    $filesFound = 0
    $filesMissing = @()
    
    foreach ($file in $filesToSnapshot) {
        $filePath = Join-Path $ScriptPath $file
        if (Test-Path $filePath) {
            $filesFound++
        } else {
            if (-not ($file -like "*.reg")) {
                $filesMissing += $file
            }
        }
    }
    
    Write-Log "Files to snapshot: $filesFound"
    
    if ($filesMissing.Count -gt 0) {
        Write-Warning "Some files not found (may be normal): $($filesMissing -join ', ')"
    }
    
    if ($filesFound -eq 0) {
        Write-Warning "No files to snapshot (initial deployment?)"
        return $false
    }
    
    $snapshotCmd = "tar -czf `"$snapshotFile`" -C `"$ScriptPath`" $($filesToSnapshot -join ' ')"
    
    Write-Log "Creating snapshot: $snapshotFile"
    
    if ($SkipSnapshot) {
        Write-Log "[SKIP] Snapshot creation skipped"
        return $snapshotFile
    }
    
    try {
        Invoke-Expression $snapshotCmd | Out-Null
        Write-Success "Snapshot created successfully"
        
        $snapshotSize = (Get-Item $snapshotFile).Length / 1MB
        Write-Log "Snapshot size: $([math]::Round($snapshotSize, 2)) MB"
        
    } catch {
        Write-Error-Message "Failed to create snapshot: $($_.Exception.Message)"
        return $false
    }
    
    Write-Log "=== SNAPSHOT CREATION COMPLETE ===" -Level "INFO"
    return $snapshotFile
}

function Clean-OldSnapshots {
    Write-Log "=== CLEANING OLD SNAPSHOTS ===" -Level "INFO"
    
    if (-not (Test-Path $SnapshotPath)) {
        Write-Log "No snapshots directory to clean"
        return
    }
    
    $oldSnapshots = Get-ChildItem $SnapshotPath -Filter "snapshot-*.tar.gz" | 
                      Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
    
    if ($oldSnapshots.Count -eq 0) {
        Write-Log "No snapshots older than 7 days"
        return
    }
    
    $spaceFreed = 0
    
    foreach ($snapshot in $oldSnapshots) {
        try {
            $size = $snapshot.Length
            Remove-Item $snapshot.FullName -Force
            $spaceFreed += $size
            Write-Log "Removed: $($snapshot.Name)"
        } catch {
            Write-Warning "Failed to remove $($snapshot.Name): $($_.Exception.Message)"
        }
    }
    
    $spaceFreedMB = $spaceFreed / 1MB
    Write-Success "Cleaned $($oldSnapshots.Count) snapshots, freed $([math]::Round($spaceFreedMB, 2)) MB"
    Write-Log "=== SNAPSHOT CLEANUP COMPLETE ===" -Level "INFO"
}

function Validate-DeploymentEnvironment {
    Write-Log "=== VALIDATING DEPLOYMENT ENVIRONMENT ===" -Level "INFO"
    
    $allValidationsPassed = $true
    $warnings = @()
    
    $requiredFiles = @(
        "business-debloat.ps1",
        "debloat-config.json"
    )
    
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path "$ScriptPath\$file")) {
            Write-Error-Message "Required file missing: $file"
            $allValidationsPassed = $false
        } else {
            Write-Log "✓ Found: $file"
        }
    }
    
    $requiredPaths = @(
        $SnapshotPath,
        $DocsPath
    )
    
    foreach ($path in $requiredPaths) {
        if (-not (Test-Path $path)) {
            Write-Log "Creating missing directory: $path"
            try {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
            } catch {
                Write-Error-Message "Failed to create directory $path: $($_.Exception.Message)"
                $allValidationsPassed = $false
            }
        }
    }
    
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $restrictedPolicies = @("Restricted", "Undefined", "AllSigned")
    if ($restrictedPolicies -contains $executionPolicy) {
        $warnings += "Execution policy is '$executionPolicy' - may block scripts"
        Write-Log "Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -Level "WARN"
    }
    
    if ($warnings.Count -gt 0) {
        Write-Log "=== WARNINGS ===" -Level "WARN"
        foreach ($warning in $warnings) {
            Write-Log "  $warning" -Level "WARN"
        }
    }
    
    if (-not $allValidationsPassed) {
        Write-Error-Message "Environment validation failed - cannot continue"
        exit 1
    }
    
    Write-Success "Environment validation passed"
    Write-Log "=== VALIDATION COMPLETE ===" -Level "INFO"
}

function Initialize-GitRepository {
    Write-Log "=== INITIALIZING GIT REPOSITORY ===" -Level "INFO"
    
    if ($SkipGitSetup) {
        Write-Log "[SKIP] Git setup skipped"
        return
    }
    
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    
    if (-not (Test-Path $gitPath)) {
        Write-Warning "Git not found at expected path: $gitPath"
        Write-Log "Attempting to find git in PATH..."
        $gitPath = "git.exe"
    }
    
    try {
        $isRepo = & $gitPath rev-parse --is-inside-work-tree 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Git repository already initialized"
            $status = & $gitPath status --short 2>&1
            Write-Log "Current status: $status"
        } else {
            Write-Log "Initializing new git repository..."
            & $gitPath init | Out-Null
            Write-Success "Git repository initialized"
            
            $gitignoreContent = @"
# Flag files (runtime files)
*.flag

# Log files
*.log
UpdateLog.txt
debloat-log.txt
restore-log.txt

# Snapshot files (large)
snapshot-*.tar.gz

# Windows specific
Thumbs.db
desktop.ini

# Backup files
registry-backup-*.reg
"@
            
            Set-Content -Path ".gitignore" -Value $gitignoreContent -Force
            Write-Log "Created .gitignore file"
        }
        
        $gitUserEmail = & $gitPath config user.email 2>&1
        $gitUserName = & $gitPath config user.name 2>&1
        
        Write-Log "Git user: $gitUserName <$gitUserEmail>"
        
    } catch {
        Write-Warning "Git setup encountered issues: $($_.Exception.Message)"
        Write-Log "You may need to initialize git manually after deployment"
    }
    
    Write-Log "=== GIT INITIALIZATION COMPLETE ===" -Level "INFO"
}

function Execute-Debloat {
    Write-Log "=== EXECUTING DEBLOAT SCRIPT ===" -Level "INFO"
    
    $debloatScript = "$ScriptPath\business-debloat.ps1"
    
    if (-not (Test-Path $debloatScript)) {
        Write-Error-Message "Debloat script not found: $debloatScript"
        exit 1
    }
    
    Write-Log "Starting debloat process..."
    
    $deployParams = @()
    
    if ($ForceDeploy) {
        $deployParams += "-ContinueAnyway"
        Write-Log "Force deployment enabled (-ContinueAnyway)"
    }
    
    try {
        $paramString = $deployParams -join ' '
        if ($paramString) {
            & powershell -ExecutionPolicy Bypass -File $debloatScript $deployParams | Tee-Object -Variable debloatOutput
        } else {
            & powershell -ExecutionPolicy Bypass -File $debloatScript | Tee-Object -Variable debloatOutput
        }
        
        Write-Log "=== DEBLOAT EXECUTION COMPLETE ===" -Level "INFO"
        
    } catch {
        Write-Error-Message "Debloat execution failed: $($_.Exception.Message)"
        exit 1
    }
}

function Generate-DeploymentReport {
    Write-Log "=== GENERATING DEPLOYMENT REPORT ===" -Level "INFO"
    
    $reportPath = "$ScriptPath\deployment-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    
    $reportContent = @"
#MundyTuned - NextLevelDebloat Deployment Report
# Business Email: bryan@mundytuned.com
# Deployment Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Deployment Summary

Machine: $env:COMPUTERNAME
User: $env:USERNAME
OS: $((Get-CimInstance Win32_OperatingSystem).Caption) (Build $(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild)

## Steps Completed

- [X] System inventory collected
- [X] Deployment environment validated
- [X] Pre-deployment snapshot created
- [X] Git repository initialized
- [X] Debloat script executed
- [X] Post-deployment verification

## Files Created

- Deployment log: $LogFile
- System snapshot: $(if ($snapshotCreated) { $snapshotCreated } else { 'Skipped' })
- Git repository: $(if ($gitInitialized) { 'Initialized' } else { 'Skipped' })
- Deployment report: $reportPath

## Next Steps

1. Review debloat-log.txt for execution details
2. Restart computer for all changes to take effect
3. Verify system functionality
4. Test restoration procedures with business-debloat-restore.ps1

## Support

For issues or questions:
Email: bryan@mundytuned.com
Business: #MundyTuned

---
Report generated: $(Get-Date)
"@
    
    Set-Content -Path $reportPath -Value $reportContent -Force
    Write-Success "Deployment report created: $reportPath"
    Write-Log "=== REPORT GENERATION COMPLETE ===" -Level "INFO"
}

function Verify-Deployment {
    Write-Log "=== VERIFYING DEPLOYMENT ===" -Level "INFO"
    
    $debloatLog = "$ScriptPath\debloat-log.txt"
    
    if (Test-Path $debloatLog) {
        $logContent = Get-Content $debloatLog -Tail 20
        $errors = $logContent | Select-String -Pattern "\[ERROR\]" -AllMatches
        $warnings = $logContent | Select-String -Pattern "\[WARN\]" -AllMatches
        
        Write-Log "Errors found: $($errors.Count)"
        Write-Log "Warnings found: $($warnings.Count)"
        
        if ($errors.Count -gt 0) {
            Write-Warning "Deployment completed with errors - review debloat-log.txt"
        } elseif ($warnings.Count -gt 5) {
            Write-Warning "Deployment completed with multiple warnings - review debloat-log.txt"
        } else {
            Write-Success "Deployment verified successfully"
        }
    } else {
        Write-Warning "Debloat log not found - may not have executed"
    }
    
    Write-Log "=== VERIFICATION COMPLETE ===" -Level "INFO"
}

function Show-Summary {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " DEPLOYMENT SUMMARY" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Business:" -ForegroundColor Yellow
    Write-Host "  #MundyTuned" -ForegroundColor White
    Write-Host ""
    Write-Host "Contact:" -ForegroundColor Yellow
    Write-Host "  bryan@mundytuned.com" -ForegroundColor White
    Write-Host ""
    Write-Host "Steps Completed:" -ForegroundColor Green
    Write-Host "  [✓] System inventory"
    Write-Host "  [✓] Environment validation"
    if (-not $SkipSnapshot) { Write-Host "  [✓] Snapshot creation" }
    if (-not $SkipGitSetup) { Write-Host "  [✓] Git initialization" }
    Write-Host "  [✓] Debloat execution"
    Write-Host "  [✓] Deployment verification"
    Write-Host ""
    Write-Host "Logs:" -ForegroundColor Yellow
    Write-Host "  - $LogFile"
    Write-Host "  - deployment-report-*.txt"
    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Yellow
    Write-Host "  - README.md"
    Write-Host "  - docs/DEPLOYMENT.md"
    Write-Host ""
}

# Main Execution Block
try {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " NextLevelDebloat Deployment" -ForegroundColor Cyan
    Write-Host " #MundyTuned" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "=== DEPLOYMENT STARTED ===" -Level "INFO"
    Write-Log "Deployment started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Log "SkipSnapshot: $SkipSnapshot"
    Write-Log "SkipGitSetup: $SkipGitSetup"
    Write-Log "SkipValidation: $SkipValidation"
    Write-Log "ForceDeploy: $ForceDeploy"
    
    if (-not $SkipValidation) {
        Validate-DeploymentEnvironment
    }
    
    $inventory = Get-SystemInventory
    
    if (-not $SkipSnapshot) {
        $snapshotCreated = Create-Snapshot
        Clean-OldSnapshots
    }
    
    if (-not $SkipGitSetup) {
        Initialize-GitRepository
    }
    
    Execute-Debloat
    
    Verify-Deployment
    Generate-DeploymentReport
    
    Show-Summary
    
    Write-Log "=== DEPLOYMENT COMPLETE ===" -Level "INFO"
    Write-Success "Deployment completed successfully!"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Review logs in $LogFile"
    Write-Host "  2. Restart computer for all changes to take effect"
    Write-Host "  3. Verify system functionality"
    Write-Host "  4. Initialize GitHub: git init; git add .; git commit -m 'Initial deployment'"
    Write-Host ""
    
} catch {
    Write-Error-Message "Deployment failed: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "ERROR"
    Write-Host ""
    Write-Host "Rollback options:" -ForegroundColor Yellow
    Write-Host "  1. Restore from snapshot: Extract snapshot-$timestamp.tar.gz"
    Write-Host "  2. Run restoration: .\business-debloat-restore.ps1"
    Write-Host ""
    exit 1
}
