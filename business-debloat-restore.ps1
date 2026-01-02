# Windows 11 Business Debloat - Automated Restoration Script
# Restores system from business-optimized state to consumer Windows 11
#
# #MundyTuned - Windows Optimization Solutions
# Business Email: bryan@mundytuned.com

param(
    [switch]$RestoreApps,
    [switch]$RestoreServices,
    [switch]$RestoreTasks,
    [switch]$RestoreRegistry,
    [switch]$RestoreEdge,
    [switch]$RestoreAll = $true,
    [switch]$Interactive,
    [switch]$DryRun,
    [string]$BackupFile,
    [string]$LogFile = "restore-log.txt"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Restore-Registry {
    param([string]$BackupFile)
    
    if (-not $BackupFile) {
        $backupFiles = Get-ChildItem "C:\temp\" -Filter "registry-backup-*.reg" | Sort-Object LastWriteTime -Descending
        if ($backupFiles.Count -eq 0) {
            Write-Log "No registry backup files found" -Level "ERROR"
            return $false
        }
        $BackupFile = $backupFiles[0].FullName
        Write-Log "Using latest backup: $BackupFile"
    }
    
    $hkcuBackup = $BackupFile -replace '\.reg$', '-HKCU.reg'
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would import HKLM from: $BackupFile"
        Write-Log "[DRYRUN] Would import HKCU from: $hkcuBackup"
        return $true
    }
    
    if ($Interactive) {
        $response = Read-Host "Import registry from $BackupFile? (Y/N)"
        if ($response -ne 'Y') { return $false }
    }
    
    try {
        Write-Log "Importing HKLM registry..."
        reg import $BackupFile 2>&1 | Tee-Object -Variable importOutput
        if ($LASTEXITCODE -eq 0) {
            Write-Log "HKLM registry imported successfully"
        } else {
            Write-Log "HKLM registry import had issues: $importOutput" -Level "WARN"
        }
        
        if (Test-Path $hkcuBackup) {
            Write-Log "Importing HKCU registry..."
            reg import $hkcuBackup 2>&1 | Tee-Object -Variable importOutput
            if ($LASTEXITCODE -eq 0) {
                Write-Log "HKCU registry imported successfully"
            } else {
                Write-Log "HKCU registry import had issues: $importOutput" -Level "WARN"
            }
        } else {
            Write-Log "HKCU backup not found, skipping..." -Level "WARN"
        }
        
        return $true
    } catch {
        Write-Log "Registry import failed: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Restore-Services {
    param()
    
    $servicesToRestore = @(
        @{Name = "XblAuthManager"; StartType = "Manual"},
        @{Name = "XboxNetApiSvc"; StartType = "Manual"},
        @{Name = "XboxGipSvc"; StartType = "Manual"},
        @{Name = "DiagTrack"; StartType = "Automatic"},
        @{Name = "MapsBroker"; StartType = "Automatic"},
        @{Name = "WalletService"; StartType = "Manual"},
        @{Name = "RetailDemo"; StartType = "Manual"},
        @{Name = "wisvc"; StartType = "Manual"},
        @{Name = "MicrosoftEdgeElevationService"; StartType = "Automatic"},
        @{Name = "edgeupdate"; StartType = "Automatic"},
        @{Name = "edgeupdatem"; StartType = "Automatic"}
    )
    
    foreach ($svcInfo in $servicesToRestore) {
        $service = Get-Service -Name $svcInfo.Name -ErrorAction SilentlyContinue
        if ($service) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would enable service $($svcInfo.Name)"
            } else {
                try {
                    Set-Service -Name $svcInfo.Name -StartupType $svcInfo.StartType -ErrorAction Stop
                    Write-Log "Enabled service $($svcInfo.Name) with startup type $($svcInfo.StartType)"
                    
                    if ($svcInfo.StartType -eq "Automatic") {
                        Start-Service -Name $svcInfo.Name -ErrorAction SilentlyContinue
                        Write-Log "Started service $($svcInfo.Name)"
                    }
                } catch {
                    Write-Log "Failed to enable service $($svcInfo.Name): $($_.Exception.Message)" -Level "WARN"
                }
            }
        } else {
            Write-Log "Service $($svcInfo.Name) not found, skipping..." -Level "WARN"
        }
    }
}

function Restore-ScheduledTasks {
    param()
    
    $tasksToRestore = @(
        @{Name = "Microsoft Compatibility Appraiser"; Path = "\Microsoft\Windows\Application Experience\"},
        @{Name = "Customer Experience Improvement Program"; Path = "\Microsoft\Windows\Application Experience\"},
        @{Name = "Program Data Updater"; Path = "\Microsoft\Windows\Application Experience\"},
        @{Name = "XblGameSaveTask"; Path = "\Microsoft\Windows\XblGameSave\"}
    )
    
    foreach ($taskInfo in $tasksToRestore) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would enable task $($taskInfo.Name)"
        } else {
            try {
                Enable-ScheduledTask -TaskName $taskInfo.Name -TaskPath $taskInfo.Path -ErrorAction Stop
                Write-Log "Enabled task $($taskInfo.Name)"
            } catch {
                Write-Log "Failed to enable task $($taskInfo.Name): $($_.Exception.Message)" -Level "WARN"
            }
        }
    }
}

function Remove-BusinessPolicies {
    param()
    
    $policyKeys = @(
        "HKLM:\Software\Policies\Microsoft\MicrosoftEdge",
        "HKCU:\Software\Policies\Microsoft\MicrosoftEdge",
        "HKLM:\Software\Policies\Microsoft\EdgeUpdate",
        "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo",
        "HKLM:\Software\Policies\Microsoft\Windows\Windows Search",
        "HKLM:\Software\Policies\Microsoft\Windows\CloudContent",
        "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting",
        "HKLM:\Software\Policies\Microsoft\Edge",
        "HKCU:\Software\Policies\Microsoft\Windows\Windows Search"
    )
    
    foreach ($key in $policyKeys) {
        if (Test-Path $key) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would remove policy key: $key"
            } else {
                try {
                    Remove-Item -Path $key -Recurse -Force -ErrorAction Stop
                    Write-Log "Removed policy key: $key"
                } catch {
                    Write-Log "Failed to remove policy key $key: $($_.Exception.Message)" -Level "WARN"
                }
            }
        }
    }
    
    $policyValues = @(
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name = "Enabled"},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"; Name = "TailoredExperiencesWithDiagnosticDataEnabled"},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarDa"},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name = "BingSearchEnabled"},
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name = "DisableWebSearch"},
        @{Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoInternetOpenWith"}
    )
    
    foreach ($value in $policyValues) {
        if (Test-Path $value.Path) {
            $property = Get-ItemProperty -Path $value.Path -Name $value.Name -ErrorAction SilentlyContinue
            if ($property) {
                if ($DryRun) {
                    Write-Log "[DRYRUN] Would remove policy value: $($value.Path)\$($value.Name)"
                } else {
                    try {
                        Remove-ItemProperty -Path $value.Path -Name $value.Name -Force -ErrorAction Stop
                        Write-Log "Removed policy value: $($value.Path)\$($value.Name)"
                    } catch {
                        Write-Log "Failed to remove policy value $($value.Path)\$($value.Name): $($_.Exception.Message)" -Level "WARN"
                    }
                }
            }
        }
    }
}

function Restore-WindowsApps {
    param()
    
    $appsToRestore = @(
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.GamingApp",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.MixedReality.Portal",
        "Microsoft.MSPaint",
        "Microsoft.OneDriveSync",
        "Microsoft.People",
        "Microsoft.PowerAutomateDesktop",
        "Microsoft.SkypeApp",
        "Microsoft.StorePurchaseApp",
        "Microsoft.Todos",
        "Microsoft.Windows.Photos",
        "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCamera",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsPhone",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCommunicationsApps",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.WindowsBackup",
        "Microsoft.OutlookForWindows",
        "Microsoft.Windows.Ai.Copilot.Provider",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.WalletService",
        "Microsoft.WebMediaExtensions",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.ConnectivityStore"
    )
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would reinstall Windows apps"
        return
    }
    
    Write-Log "Reinstalling Windows apps (this may take several minutes)..."
    
    foreach ($app in $appsToRestore) {
        try {
            Write-Log "Attempting to reinstall: $app"
            $result = Get-AppxPackage -AllUsers $app -ErrorAction SilentlyContinue | 
                      Add-AppxPackage -DisableDevelopmentMode -ErrorAction SilentlyContinue
            
            if ($result) {
                Write-Log "Reinstalled: $app"
            } else {
                Write-Log "App not available for reinstall: $app" -Level "WARN"
            }
        } catch {
            Write-Log "Failed to reinstall $app: $($_.Exception.Message)" -Level "WARN"
        }
    }
    
    Write-Log "Windows apps reinstallation complete"
}

function Restore-Edge {
    param()
    
    Write-Log "Restoring Microsoft Edge..."
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would restore Edge functionality"
        return
    }
    
    Remove-BusinessPolicies
    Restore-Services
    
    try {
        $edgePackage = Get-AppxPackage -Name '*MicrosoftEdge*' -ErrorAction SilentlyContinue
        if ($edgePackage) {
            Write-Log "Edge is installed, ensuring functionality..."
            
            $registrationPath = "$($edgePackage.InstallLocation)\AppXManifest.xml"
            if (Test-Path $registrationPath) {
                Add-AppxPackage -DisableDevelopmentMode -Register $registrationPath -ErrorAction SilentlyContinue
                Write-Log "Edge registration updated"
            }
        } else {
            Write-Log "Edge not found in packages, this is expected (system component)" -Level "WARN"
        }
    } catch {
        Write-Log "Error with Edge: $($_.Exception.Message)" -Level "WARN"
    }
    
    Write-Log "Edge restoration complete"
}

function Verify-Restoration {
    param()
    
    Write-Log "=== RESTORATION VERIFICATION ==="
    
    $checks = @{
        "Services" = 0
        "Apps" = 0
        "Tasks" = 0
        "Policies" = 0
    }
    
    $servicesToCheck = @("DiagTrack", "edgeupdate", "XblAuthManager")
    foreach ($svc in $servicesToCheck) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service -and $service.StartType -ne "Disabled") {
            Write-Log "✓ Service $svc: $($service.StartType)"
            $checks.Services++
        }
    }
    
    $apps = Get-AppxPackage -AllUsers | Measure-Object
    if ($apps.Count -gt 80) {
        Write-Log "✓ Windows apps: $($apps.Count) installed"
        $checks.Apps++
    }
    
    $edgePolicies = Get-ChildItem "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -ErrorAction SilentlyContinue
    if (-not $edgePolicies) {
        Write-Log "✓ Edge policies: Removed"
        $checks.Policies++
    } else {
        Write-Log "✗ Edge policies: Still exist" -Level "WARN"
    }
    
    $passedChecks = ($checks.Services + $checks.Apps + $checks.Tasks + $checks.Policies)
    Write-Log "Verification: $passedChecks/4 checks passed"
    
    return $passedChecks -ge 3
}

function Invoke-Restoration {
    Write-Log "=== WINDOWS 11 BUSINESS TO CONSUMER RESTORATION ==="
    Write-Log "DryRun: $DryRun"
    Write-Log "Interactive: $Interactive"
    Write-Log "RestoreAll: $RestoreAll"
    
    if ($Interactive) {
        Write-Log "Interactive mode enabled - will prompt for confirmations"
    }
    
    if ($RestoreAll -or $RestoreRegistry) {
        Write-Log "Starting registry restoration..."
        $regResult = Restore-Registry -BackupFile $BackupFile
        if ($regResult -and -not $DryRun) {
            Write-Log "Registry restoration complete - restart recommended"
        }
    }
    
    if ($RestoreAll -or $RestoreServices) {
        Write-Log "Starting service restoration..."
        Restore-Services
    }
    
    if ($RestoreAll -or $RestoreTasks) {
        Write-Log "Starting task restoration..."
        Restore-ScheduledTasks
    }
    
    if ($RestoreAll -or $RestoreEdge) {
        Write-Log "Starting Edge restoration..."
        Restore-Edge
    }
    
    if ($RestoreAll -or $RestoreApps) {
        Write-Log "Starting app restoration..."
        Restore-WindowsApps
    }
    
    Write-Log "=== RESTORATION COMPLETE ==="
    
    if (-not $DryRun) {
        Write-Log "Verifying restoration..."
        $verification = Verify-Restoration
        
        if ($verification) {
            Write-Log "✓ Restoration verified successfully"
            Write-Log "System restart recommended for complete restoration"
            
            if ($Interactive) {
                $restart = Read-Host "Restart now? (Y/N)"
                if ($restart -eq 'Y') {
                    Restart-Computer -Force
                }
            }
        } else {
            Write-Log "✗ Some restoration issues detected - review log" -Level "WARN"
        }
    }
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

Invoke-Restoration