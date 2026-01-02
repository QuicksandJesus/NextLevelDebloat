# NextLevelDebloat - API Reference

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Document Version:** 1.0 | Last Updated: 2025-12-31  
**Status:** ✅ Complete

---

## Overview

This document provides a comprehensive reference for all PowerShell functions, parameters, and APIs available in NextLevelDebloat. Use this guide for scripting automation, custom deployments, and advanced troubleshooting.

---

## Main Script: business-debloat.ps1

### Script Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DryRun` | Switch | False | Preview all changes without applying them |
| `-Interactive` | Switch | False | Prompt for confirmation before each change |
| `-Restore` | Switch | False | Restore system to pre-debloat state |
| `-ConfigFile` | String | "debloat-config.json" | Path to configuration file |
| `-LogFile` | String | "debloat-log.txt" | Path to log file |
| `-SkipHardwareDetection` | Switch | False | Skip camera/touch hardware detection |
| `-SkipDomainCheck` | Switch | False | Apply changes on domain-joined machines |
| `-SkipPermissionCheck` | Switch | False | Skip initial permission validation |
| `-ContinueAnyway` | Switch | False | Continue despite permission warnings |
| `-SetChromeDefault` | Switch | False | Set Chrome as default browser |

### Example Usage

```powershell
# Standard run
.\business-debloat.ps1

# Preview changes
.\business-debloat.ps1 -DryRun

# Interactive mode with Chrome default
.\business-debloat.ps1 -Interactive -SetChromeDefault

# Skip hardware detection
.\business-debloat.ps1 -SkipHardwareDetection

# Force run despite warnings
.\business-debloat.ps1 -SkipPermissionCheck -ContinueAnyway
```

---

## Core Functions

### Write-Log

**Purpose:** Standardized logging utility for all script operations

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Message` | String | Yes | Log message to write |
| `Level` | String | No | Log level: INFO, WARN, ERROR |

**Return Value:** None

**Example:**
```powershell
Write-Log "Starting debloat process" -Level "INFO"
Write-Log "Registry access failed" -Level "ERROR"
```

### Backup-Registry

**Purpose:** Create timestamped backups of HKLM and HKCU registry hives

**Parameters:** None

**Return Value:** None

**Side Effects:**
- Creates `C:\temp\registry-backup-YYYYMMDD-HHmmss.reg`
- Creates `C:\temp\registry-backup-YYYYMMDD-HHmmss-HKCU.reg`

**Example:**
```powershell
Backup-Registry
```

### Test-RegistryKey

**Purpose:** Check if a registry key exists

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Path` | String | Yes | Registry key path (e.g., "HKCU:\Software\Microsoft") |

**Return Value:** Boolean

**Example:**
```powershell
if (Test-RegistryKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo") {
    Write-Host "Registry key exists"
}
```

### Set-RegistryValue

**Purpose:** Set a registry value with validation and logging

**Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Path` | String | Yes | - | Registry key path |
| `Name` | String | Yes | - | Value name |
| `Value` | Any | Yes | - | Value to set |
| `Type` | String | No | "DWord" | Registry value type |

**Return Value:** None

**Example:**
```powershell
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
```

### Remove-BloatApps

**Purpose:** Remove specified bloatware applications

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Apps` | Array | Yes | Array of app names to remove |
| `PreserveApps` | Hashtable | Yes | Apps to preserve (skip removal) |

**Return Value:** None

**Example:**
```powershell
$appsToRemove = @("Microsoft.BingNews", "Microsoft.BingWeather")
$preserveApps = @{"Microsoft.WindowsCamera" = $true}
Remove-BloatApps -Apps $appsToRemove -PreserveApps $preserveApps
```

### Disable-Service

**Purpose:** Disable and stop a Windows service

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ServiceName` | String | Yes | Name of service to disable |

**Return Value:** None

**Example:**
```powershell
Disable-Service -ServiceName "DiagTrack"
Disable-Service -ServiceName "XblAuthManager"
```

### Disable-TaskScheduled

**Purpose:** Disable scheduled tasks matching a pattern

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `TaskNamePattern` | String | Yes | Pattern to match task names |

**Return Value:** None

**Example:**
```powershell
Disable-TaskScheduled -TaskNamePattern "Microsoft Compatibility Appraiser"
Disable-TaskScheduled -TaskNamePattern "*Customer Experience*"
```

### Test-IsDomainJoined

**Purpose:** Check if the computer is joined to an Active Directory domain

**Parameters:** None

**Return Value:** Boolean

**Example:**
```powershell
if (Test-IsDomainJoined) {
    Write-Log "Domain-joined machine detected" -Level "WARN"
}
```

### Test-Hardware

**Purpose:** Detect presence of specific hardware types

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Type` | String | Yes | Hardware type: "Camera", "Touch", "Printer", "Bluetooth" |

**Return Value:** Boolean

**Example:**
```powershell
$hasCamera = Test-Hardware "Camera"
$hasTouch = Test-Hardware "Touch"

if ($hasCamera) {
    Write-Log "Camera detected - preserving Windows Camera app"
}
```

### Test-ScriptPermissions

**Purpose:** Comprehensive permission validation for script execution

**Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ContinueAnyway` | Switch | No | False | Continue despite permission failures |

**Return Value:** Boolean (True if all checks pass)

**Validation Checks:**
- Administrator privileges
- PowerShell execution policy
- Registry read/write permissions
- Service management permissions
- App package management permissions
- Task scheduler permissions
- Windows Defender status
- Domain membership status
- Backup directory permissions

**Example:**
```powershell
$permissionsOK = Test-ScriptPermissions -ContinueAnyway:$false
if (-not $permissionsOK) {
    Write-Log "Permission validation failed" -Level "ERROR"
    exit 1
}
```

### Apply-DebloatSettings

**Purpose:** Main orchestration function that applies all debloat settings

**Parameters:** None (uses global configuration)

**Return Value:** None

**Execution Flow:**
1. Load configuration from JSON
2. Hardware detection (if enabled)
3. Registry backup
4. App removal
5. Service disabling
6. Task disabling
7. Registry optimizations
8. Edge suppression
9. Chrome default (if requested)
10. Group Policy update
11. Explorer restart

**Example:**
```powershell
Apply-DebloatSettings
```

---

## Restoration Script: business-debloat-restore.ps1

### Script Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-RestoreApps` | Switch | False | Restore removed Windows apps |
| `-RestoreServices` | Switch | False | Re-enable disabled services |
| `-RestoreTasks` | Switch | False | Re-enable disabled scheduled tasks |
| `-RestoreRegistry` | Switch | False | Import registry backups |
| `-RestoreEdge` | Switch | False | Restore Edge functionality |
| `-RestoreAll` | Switch | True | Complete restoration (all components) |
| `-Interactive` | Switch | False | Prompt for confirmations |
| `-DryRun` | Switch | False | Preview restoration without applying |
| `-BackupFile` | String | Auto-detect | Specific registry backup file to use |
| `-LogFile` | String | "restore-log.txt" | Path to restoration log file |

### Restoration Functions

### Restore-Registry

**Purpose:** Import registry backups created during debloat

**Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `BackupFile` | String | No | Latest found | Path to registry backup file |

**Return Value:** Boolean (True if successful)

**Example:**
```powershell
$success = Restore-Registry -BackupFile "C:\temp\registry-backup-20251231-141805.reg"
if ($success) {
    Write-Log "Registry restoration successful"
}
```

### Restore-Services

**Purpose:** Re-enable services disabled during debloat

**Parameters:** None

**Return Value:** None

**Services Restored:**
- DiagTrack (Automatic)
- XblAuthManager (Manual)
- XboxNetApiSvc (Manual)
- XboxGipSvc (Manual)
- MapsBroker (Automatic)
- WalletService (Manual)
- RetailDemo (Manual)
- wisvc (Manual)
- MicrosoftEdgeElevationService (Automatic)
- edgeupdate (Automatic)
- edgeupdatem (Automatic)

**Example:**
```powershell
Restore-Services
Write-Log "Services restored to pre-debloat state"
```

### Restore-ScheduledTasks

**Purpose:** Re-enable scheduled tasks disabled during debloat

**Parameters:** None

**Return Value:** None

**Tasks Restored:**
- Microsoft Compatibility Appraiser
- Customer Experience Improvement Program
- Program Data Updater
- XblGameSaveTask

**Example:**
```powershell
Restore-ScheduledTasks
Write-Log "Scheduled tasks re-enabled"
```

### Restore-WindowsApps

**Purpose:** Reinstall Windows apps removed during debloat

**Parameters:** None

**Return Value:** None

**Process:**
- Attempts to reinstall all 36 bloatware apps
- Uses Add-AppxPackage with error handling
- Logs success/failure for each app
- May take 10-15 minutes

**Example:**
```powershell
Restore-WindowsApps
Write-Log "Windows apps restoration complete"
```

### Restore-Edge

**Purpose:** Restore Microsoft Edge functionality after suppression

**Parameters:** None

**Return Value:** None

**Actions:**
- Removes Edge-related Group Policies
- Re-enables Edge services
- Restores Edge app registration
- Clears Edge shortcut removal

**Example:**
```powershell
Restore-Edge
Write-Log "Edge functionality restored"
```

### Verify-Restoration

**Purpose:** Verify that restoration was successful

**Parameters:** None

**Return Value:** Boolean (True if verification passes)

**Checks Performed:**
- Service status verification
- Windows app installation count
- Edge policy removal confirmation
- Registry key validation

**Example:**
```powershell
$verified = Verify-Restoration
if ($verified) {
    Write-Log "Restoration verification passed" -Level "SUCCESS"
} else {
    Write-Log "Some restoration issues detected" -Level "WARN"
}
```

### Invoke-Restoration

**Purpose:** Main orchestration function for restoration process

**Parameters:** None (uses script parameters)

**Return Value:** None

**Execution Flow:**
1. Log restoration start
2. Check for registry backups
3. Apply selected restoration components
4. Verify restoration success
5. Prompt for system restart if needed

**Example:**
```powershell
Invoke-Restoration
```

---

## Chrome Browser Script: Set-ChromeDefaultBrowser.ps1

### Script Parameters

**No parameters - runs automatically**

### Functions

### Set-ChromeDefaultBrowser

**Purpose:** Configure Google Chrome as the default web browser

**Parameters:** None

**Return Value:** None

**Process:**
1. Detect Chrome installation path
2. Clear existing file associations
3. Set registry keys for HTTP/HTTPS/HTML/HTM
4. Launch Chrome with default browser prompt
5. Backup user associations

**Supported Extensions:**
- .html
- .htm
- .shtml
- .xhtml
- .webp
- HTTP protocol
- HTTPS protocol

**Example:**
```powershell
Set-ChromeDefaultBrowser
Write-Log "Chrome set as default browser"
```

---

## Deployment Script: Deploy-NextLevelDebloat.ps1

### Script Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-SkipSnapshot` | Switch | False | Skip system snapshot creation |
| `-SkipGitSetup` | Switch | False | Skip Git repository initialization |
| `-SkipValidation` | Switch | False | Skip environment validation |
| `-ForceDeploy` | Switch | False | Force deployment despite warnings |
| `-LogFile` | String | "deployment-log.txt" | Deployment log file path |

### Deployment Functions

### Get-SystemInventory

**Purpose:** Collect comprehensive system information

**Parameters:** None

**Return Value:** Hashtable with system information

**Information Collected:**
- Machine name and user
- OS version and build
- PowerShell version
- Administrator status
- Domain membership

**Example:**
```powershell
$inventory = Get-SystemInventory
Write-Log "System: $($inventory.OSVersion) on $($inventory.MachineName)"
```

### Create-Snapshot

**Purpose:** Create compressed snapshot of current system state

**Parameters:** None

**Return Value:** String (path to snapshot file) or False

**Process:**
- Identifies files to snapshot
- Creates timestamped tar.gz archive
- Cleans snapshots older than 7 days
- Returns snapshot path or failure

**Example:**
```powershell
$snapshotPath = Create-Snapshot
if ($snapshotPath) {
    Write-Log "Snapshot created: $snapshotPath"
} else {
    Write-Log "Snapshot creation failed" -Level "ERROR"
}
```

### Clean-OldSnapshots

**Purpose:** Remove snapshots older than retention period

**Parameters:** None

**Return Value:** None

**Process:**
- Finds snapshots older than 7 days
- Removes old files
- Logs cleanup activity

### Validate-DeploymentEnvironment

**Purpose:** Verify all prerequisites for deployment

**Parameters:** None

**Return Value:** None (exits on failure)

**Validations:**
- Required files present
- PowerShell execution policy
- Directory permissions
- Git availability

### Initialize-GitRepository

**Purpose:** Set up local Git repository

**Parameters:** None

**Return Value:** None

**Actions:**
- Configure git user.name and user.email
- Create .gitignore file
- Add credential helper

### Execute-Debloat

**Purpose:** Run the main debloat script

**Parameters:** None

**Return Value:** None

**Process:**
- Launches business-debloat.ps1
- Monitors execution
- Handles errors gracefully

### Verify-Deployment

**Purpose:** Post-deployment verification

**Parameters:** None

**Return Value:** None

**Checks:**
- Log file analysis
- Error count review
- Success confirmation

### Generate-DeploymentReport

**Purpose:** Create comprehensive deployment report

**Parameters:** None

**Return Value:** None

**Report Includes:**
- Deployment summary
- System information
- File changes
- Next steps

---

## Configuration API

### JSON Configuration Structure

```json
{
  "_metadata": {
    "solution": "Windows 11 Business Debloat",
    "brand": "#MundyTuned",
    "contact": "bryan@mundytuned.com",
    "version": "3.0",
    "created": "2025-12-31",
    "description": "Complete Windows 11 business optimization solution"
  },
  "MachineConfigurations": {
    "default": {
      "AppsToRemove": ["Microsoft.BingNews", "Microsoft.BingWeather"],
      "PreserveApps": {},
      "ServicesToDisable": ["DiagTrack", "XblAuthManager"],
      "TasksToDisable": ["Microsoft Compatibility Appraiser"],
      "RegistrySettings": {
        "DisableAdvertising": true,
        "DisableCopilot": true
      }
    },
    "laptop": {
      "PreserveApps": {
        "Microsoft.WindowsCamera": true,
        "Microsoft.WindowsCalculator": true
      }
    }
  },
  "Logging": {
    "Enabled": true,
    "LogFilePath": "C:\\temp\\debloat-log.txt",
    "VerboseLogging": false
  },
  "Backup": {
    "Enabled": true,
    "BackupPath": "C:\\temp\\registry-backup"
  },
  "Execution": {
    "Interactive": false,
    "DryRun": false,
    "SkipHardwareDetection": false,
    "SkipDomainCheck": false,
    "SkipPermissionCheck": false,
    "RestartExplorer": true,
    "ApplyGroupPolicyUpdates": true
  }
}
```

### Configuration Loading

```powershell
$configPath = "debloat-config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    Write-Log "Configuration loaded from $configPath"
} else {
    Write-Log "Configuration file not found, using defaults" -Level "WARN"
    # Use hardcoded defaults
}
```

---

## Error Handling API

### Error Codes and Exceptions

| Error Type | Description | Handling |
|------------|-------------|----------|
| Permission Denied | Insufficient privileges | Exit with error code 1 |
| File Not Found | Missing required files | Log error, suggest download |
| Registry Access | Cannot read/write registry | Skip registry operations |
| Service Error | Cannot stop/modify service | Log warning, continue |
| App Removal Failed | Cannot remove app | Log warning, continue |

### Exception Handling Patterns

```powershell
try {
    # Risky operation
    Set-RegistryValue -Path $registryPath -Name $valueName -Value $value
} catch {
    Write-Log "Registry operation failed: $($_.Exception.Message)" -Level "ERROR"
    # Continue with other operations
}
```

### Logging Levels

- **INFO:** Normal operations and progress
- **WARN:** Non-critical issues that don't stop execution
- **ERROR:** Critical failures that may affect results
- **SUCCESS:** Important successful operations

---

## Performance API

### Execution Time Tracking

```powershell
$startTime = Get-Date
# Execute operations
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Log "Operation completed in $($duration.TotalSeconds) seconds"
```

### Resource Monitoring

```powershell
# CPU usage
$cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time'
Write-Log "CPU Usage: $($cpuUsage.CounterSamples.CookedValue)%"

# Memory usage
$memoryUsage = Get-Counter '\Memory\Available MBytes'
Write-Log "Available Memory: $($memoryUsage.CounterSamples.CookedValue) MB"
```

---

## Integration API

### Windows Services Integration

```powershell
# Check service status
$service = Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
if ($service) {
    Write-Log "Service status: $($service.Status), Startup: $($service.StartType)"
}
```

### Scheduled Tasks Integration

```powershell
# Enumerate tasks
$tasks = Get-ScheduledTask | Where-Object { $_.State -eq "Ready" }
Write-Log "Found $($tasks.Count) active scheduled tasks"
```

### Registry Integration

```powershell
# Safe registry operations
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (Test-Path $registryPath) {
    $currentValue = Get-ItemProperty -Path $registryPath -Name "Enabled" -ErrorAction SilentlyContinue
    Write-Log "Current advertising setting: $($currentValue.Enabled)"
}
```

### Windows Apps Integration

```powershell
# App enumeration
$allApps = Get-AppxPackage -AllUsers
$provisionedApps = Get-AppxProvisionedPackage -Online
Write-Log "Total apps: $($allApps.Count), Provisioned: $($provisionedApps.Count)"
```

---

## Extension API

### Custom Functions

Developers can extend NextLevelDebloat by adding custom functions:

```powershell
function Custom-DebloatOperation {
    param([string]$Parameter)
    
    Write-Log "Starting custom operation: $Parameter"
    
    # Custom logic here
    # Use Write-Log for consistency
    # Return appropriate values
    
    Write-Log "Custom operation completed"
}
```

### Configuration Extensions

Add custom configuration sections:

```json
{
  "CustomSettings": {
    "EnableAdvancedLogging": true,
    "CustomAppList": ["Custom.App1", "Custom.App2"],
    "BackupRetentionDays": 14
  }
}
```

### Hook Points

The scripts include several hook points for customization:

- **Pre-Debloat:** Before any changes
- **Post-Debloat:** After all changes
- **Pre-Restore:** Before restoration
- **Post-Restore:** After restoration
- **Error Handler:** Custom error handling

---

## Security Considerations

### Execution Context

- **Administrator Required:** All scripts require elevated privileges
- **Execution Policy:** Scripts are signed for RemoteSigned policy
- **Credential Storage:** Temporary credential helpers cleaned up
- **Registry Access:** Full HKLM/HKCU access required
- **Service Control:** System service modification permissions

### Data Protection

- **Registry Backups:** Automatic before any changes
- **Log Files:** Contain system information (handle appropriately)
- **Credential Cleanup:** Temporary credentials removed after use
- **Error Logging:** Sensitive information not logged

### Compliance

- **Microsoft Terms:** Operations comply with Windows licensing
- **Domain Policies:** Respects but can override Group Policy
- **Audit Trail:** Complete logging for compliance verification
- **Reversibility:** Full restoration capability maintained

---

## Contact and Support

### API Support

**Business:** #MundyTuned  
**Email:** bryan@mundytuned.com  
**Repository:** https://github.com/QuicksandJesus/NextLevelDebloat

### Documentation

- **This Reference:** Complete API documentation
- **TROUBLESHOOTING.md:** Issue resolution
- **ARCHITECTURE.md:** System design overview
- **DEPLOYMENT.md:** Implementation procedures

### Development Support

For custom integrations or API extensions:

1. Review existing function patterns
2. Use Write-Log for consistent logging
3. Handle errors gracefully
4. Test on virtual machines first
5. Document customizations

---

## Version Compatibility

| Component | Version | Compatibility |
|-----------|---------|---------------|
| Windows 11 | 21H2+ | Fully supported |
| PowerShell | 5.1+ | Required |
| .NET Framework | 4.8+ | Required |
| Git | 2.30+ | Optional (for version control) |
| GitHub CLI | 2.0+ | Optional (for repository management) |

---

## Future API Extensions

### Planned Enhancements

- **Remote Management API:** PowerShell remoting support
- **Configuration Validation:** JSON schema validation
- **Progress Callbacks:** Real-time progress reporting
- **Rollback API:** Programmatic restoration triggers
- **Reporting API:** Automated deployment reporting

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-31  
**Status:** ✅ Complete

---

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com