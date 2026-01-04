# Windows 11 Business Debloat - Restoration Verification Script
# Verifies complete restoration to consumer Windows 11 state
#
# #MundyTuned - Windows Optimization Solutions
# Business Email: bryan@mundytuned.com

param(
    [switch]$Verbose,
    [string]$LogFile = "verification-log.txt"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Test-ServicesRestored {
    param()
    
    Write-Log "=== SERVICE RESTORATION CHECK ==="
    
    $servicesToCheck = @{
        "DiagTrack" = @{Expected = "Automatic"; Description = "Telemetry service"}
        "edgeupdate" = @{Expected = "Automatic"; Description = "Edge update service"}
        "XblAuthManager" = @{Expected = "Manual"; Description = "Xbox authentication"}
        "XboxNetApiSvc" = @{Expected = "Manual"; Description = "Xbox networking"}
        "MapsBroker" = @{Expected = "Automatic"; Description = "Maps service"}
    }
    
    $passed = 0
    $failed = 0
    
    foreach ($svcName in $servicesToCheck.Keys) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        $expected = $servicesToCheck[$svcName].Expected
        $desc = $servicesToCheck[$svcName].Description
        
        if ($svc) {
            $actual = $svc.StartType
            if ($actual -eq $expected -or $actual -eq "Automatic") {
                Write-Log "✓ $svcName ($desc): $actual" -Level "INFO"
                $passed++
            } else {
                Write-Log "✗ $svcName ($desc): $actual (expected $expected)" -Level "WARN"
                $failed++
            }
        } else {
            Write-Log "? $svcName ($desc): Not found" -Level "WARN"
        }
    }
    
    Write-Log "Service Check: $passed passed, $failed failed"
    return $passed -ge 3
}

function Test-ScheduledTasksRestored {
    param()
    
    Write-Log "=== SCHEDULED TASK RESTORATION CHECK ==="
    
    $tasksToCheck = @(
        "Microsoft Compatibility Appraiser",
        "Customer Experience Improvement Program",
        "Program Data Updater",
        "XblGameSaveTask"
    )
    
    $passed = 0
    $failed = 0
    
    foreach ($taskName in $tasksToCheck) {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task) {
            if ($task.State -ne "Disabled") {
                Write-Log "✓ $taskName: $($task.State)" -Level "INFO"
                $passed++
            } else {
                Write-Log "✗ $taskName: Disabled" -Level "WARN"
                $failed++
            }
        } else {
            Write-Log "? $taskName: Not found" -Level "WARN"
        }
    }
    
    Write-Log "Task Check: $passed passed, $failed failed"
    return $passed -ge 2
}

function Test-PoliciesRemoved {
    param()
    
    Write-Log "=== POLICY REMOVAL CHECK ==="
    
    $policyKeys = @(
        "HKLM:\Software\Policies\Microsoft\MicrosoftEdge",
        "HKCU:\Software\Policies\Microsoft\MicrosoftEdge",
        "HKLM:\Software\Policies\Microsoft\EdgeUpdate",
        "HKLM:\Software\Policies\Microsoft\Edge",
        "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo",
        "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"
    )
    
    $removed = 0
    $found = 0
    
    foreach ($key in $policyKeys) {
        if (Test-Path $key) {
            Write-Log "✗ Policy key exists: $key" -Level "WARN"
            $found++
        } else {
            Write-Log "✓ Policy key removed: $key" -Level "INFO"
            $removed++
        }
    }
    
    Write-Log "Policy Check: $removed removed, $found found"
    return $removed -ge 4
}

function Test-AppsRestored {
    param()
    
    Write-Log "=== APP RESTORATION CHECK ==="
    
    $appsToCheck = @(
        "Microsoft.Windows.Photos",
        "Microsoft.WindowsCamera",
        "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCommunicationsApps",
        "Microsoft.Windows.Ai.Copilot.Provider",
        "Microsoft.XboxApp",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.BingWeather",
        "Microsoft.OutlookForWindows"
    )
    
    $passed = 0
    $failed = 0
    
    foreach ($appName in $appsToCheck) {
        $app = Get-AppxPackage -AllUsers $appName -ErrorAction SilentlyContinue
        if ($app) {
            Write-Log "✓ $appName: Installed" -Level "INFO"
            $passed++
        } else {
            Write-Log "? $appName: Not installed (may be optional)" -Level "WARN"
        }
    }
    
    $totalApps = Get-AppxPackage -AllUsers | Measure-Object
    Write-Log "Total Windows Apps: $($totalApps.Count) (should be 80+)"
    
    if ($totalApps.Count -ge 80) {
        Write-Log "✓ Sufficient apps installed" -Level "INFO"
        return $true
    } else {
        Write-Log "✗ Insufficient apps installed" -Level "WARN"
        return $false
    }
}

function Test-EdgeRestored {
    param()
    
    Write-Log "=== EDGE RESTORATION CHECK ==="
    
    $checks = @{
        "EdgePackage" = 0
        "EdgeServices" = 0
        "EdgePolicies" = 0
    }
    
    $edgePackage = Get-AppxPackage -Name '*MicrosoftEdge*' -ErrorAction SilentlyContinue
    if ($edgePackage) {
        Write-Log "✓ Edge installed: $($edgePackage.Name)" -Level "INFO"
        $checks.EdgePackage++
    } else {
        Write-Log "? Edge not found (may be system component)" -Level "WARN"
    }
    
    $edgeServices = @("edgeupdate", "MicrosoftEdgeElevationService")
    foreach ($svcName in $edgeServices) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc -and $svc.StartType -ne "Disabled") {
            Write-Log "✓ Edge service $svcName: $($svc.StartType)" -Level "INFO"
            $checks.EdgeServices++
        } else {
            Write-Log "✗ Edge service $svcName: Not running or disabled" -Level "WARN"
        }
    }
    
    $edgePolicies = Get-ChildItem "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -ErrorAction SilentlyContinue
    if (-not $edgePolicies) {
        Write-Log "✓ Edge policies removed" -Level "INFO"
        $checks.EdgePolicies++
    } else {
        Write-Log "✗ Edge policies still exist" -Level "WARN"
    }
    
    $passed = $checks.EdgePackage + $checks.EdgeServices + $checks.EdgePolicies
    Write-Log "Edge Check: $passed/3 checks passed"
    return $passed -ge 2
}

function Test-WindowsUpdateWorking {
    param()
    
    Write-Log "=== WINDOWS UPDATE CHECK ==="
    
    $updateServices = @("wuauserv", "UsoSvc")
    $passed = 0
    
    foreach ($svcName in $updateServices) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -eq "Running") {
            Write-Log "✓ Update service $svcName: Running" -Level "INFO"
            $passed++
        } else {
            Write-Log "? Update service $svcName: Not running" -Level "WARN"
        }
    }
    
    if ($passed -ge 2) {
        Write-Log "✓ Windows Update appears functional" -Level "INFO"
        return $true
    } else {
        Write-Log "✗ Windows Update may not be functional" -Level "WARN"
        return $false
    }
}

function Test-SystemHealth {
    param()
    
    Write-Log "=== SYSTEM HEALTH CHECK ==="
    
    Write-Log "Running SFC scan..." -Level "INFO"
    $sfcOutput = sfc /scannow 2>&1
    $sfcClean = $sfcOutput -match "integrity violations"
    
    if ($sfcClean) {
        Write-Log "✓ System file check passed" -Level "INFO"
        $systemHealthy = $true
    } else {
        Write-Log "✗ System file issues found" -Level "WARN"
        $systemHealthy = $false
    }
    
    $memory = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object TotalPhysicalMemory
    $memoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
    Write-Log "System Memory: $memoryGB GB" -Level "INFO"
    
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace
    $diskSizeGB = [math]::Round($disk.Size / 1GB, 2)
    $diskFreeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    Write-Log "Disk C: $diskSizeGB GB, $diskFreeGB GB free" -Level "INFO
    
    return $systemHealthy
}

function Generate-Report {
    param([hashtable]$Results)
    
    Write-Log "=== VERIFICATION SUMMARY ==="
    
    $totalChecks = 0
    $passedChecks = 0
    
    foreach ($key in $Results.Keys) {
        $totalChecks++
        if ($Results[$key]) {
            $passedChecks++
            Write-Log "✓ $key: PASSED" -Level "INFO"
        } else {
            Write-Log "✗ $key: FAILED" -Level "ERROR"
        }
    }
    
    $percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 0)
    Write-Log "Overall: $passedChecks/$totalChecks checks passed ($percentage%)"
    
    if ($passedChecks -ge $totalChecks * 0.75) {
        Write-Log "✓ System ready for consumer use" -Level "INFO"
        return $true
    } else {
        Write-Log "✗ System requires additional restoration work" -Level "ERROR"
        return $false
    }
}

function Invoke-Verification {
    Write-Log "=== WINDOWS 11 CONSUMER DEPLOYMENT VERIFICATION ==="
    Write-Log "Started: $(Get-Date)"
    
    if ($Verbose) {
        Write-Log "Verbose mode enabled"
    }
    
    $results = @{
        "Services" = $false
        "Tasks" = $false
        "Policies" = $false
        "Apps" = $false
        "Edge" = $false
        "WindowsUpdate" = $false
        "SystemHealth" = $false
    }
    
    $results.Services = Test-ServicesRestored
    $results.Tasks = Test-ScheduledTasksRestored
    $results.Policies = Test-PoliciesRemoved
    $results.Apps = Test-AppsRestored
    $results.Edge = Test-EdgeRestored
    $results.WindowsUpdate = Test-WindowsUpdateWorking
    $results.SystemHealth = Test-SystemHealth
    
    $readyForDeployment = Generate-Report -Results $results
    
    Write-Log "=== VERIFICATION COMPLETE ==="
    Write-Log "Completed: $(Get-Date)"
    
    if (-not $readyForDeployment) {
        Write-Log "Review $LogFile for detailed issues" -Level "ERROR"
    }
    
    return $readyForDeployment
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

$ready = Invoke-Verification
exit $(! $ready)