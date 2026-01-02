# NextLevelDebloat - Configuration Reference

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Document Version:** 1.0 | Last Updated: 2025-12-31

---

## Overview

This document provides a comprehensive reference for all configuration options available in NextLevelDebloat. Use this guide to customize the debloation process for specific environments or requirements.

---

## Configuration Files

### Main Configuration

**File:** `debloat-config.json`  
**Location:** `C:\temp\debloat-config.json`

**Structure:**
```json
{
  "_metadata": {
    "solution": "Windows 11 Business Debloat",
    "brand": "#MundyTuned",
    "contact": "bryan@mundytuned.com",
    "version": "3.0",
    "created": "2025-12-31",
    "description": "Complete Windows 11 business optimization solution with consumer restoration capability"
  },
  "MachineConfigurations": {
    "default": {
      "AppsToRemove": [...],
      "PreserveApps": {}
    },
    "laptop": {
      "PreserveApps": {
        "Microsoft.WindowsCamera": true,
        "Microsoft.WindowsCalculator": true
      }
    },
    "desktop": {
      "PreserveApps": {}
    },
    "domain-joined": {
      "SkipDomainManagedSettings": true
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

---

## Machine Configurations

### Default Configuration

Used for standard business desktop computers where no special hardware or domain considerations exist.

#### AppsToRemove

Complete list of 36 bloatware applications to remove:

```json
[
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
]
```

#### PreserveApps

Empty hashtable - no apps are preserved in default configuration.

#### ServicesToDisable

List of 11 services to disable:

```json
[
  "XblAuthManager",
  "XboxNetApiSvc",
  "XboxGipSvc",
  "DiagTrack",
  "MapsBroker",
  "WalletService",
  "RetailDemo",
  "wisvc",
  "MicrosoftEdgeElevationService",
  "edgeupdate",
  "edgeupdatem"
]
```

#### TasksToDisable

List of 4 scheduled tasks to disable:

```json
[
  "\\Microsoft\\Windows\\Application Experience\\Microsoft Compatibility Appraiser",
  "\\Microsoft\\Windows\\Application Experience\\Customer Experience Improvement Program",
  "\\Microsoft\\Windows\\Application Experience\\Program Data Updater",
  "\\Microsoft\\Windows\\XblGameSave\\XblGameSaveTask"
]
```

#### RegistrySettings

Complete set of registry privacy and business optimization settings.

---

### Laptop Configuration

Optimized for laptops and tablet devices with touch screens or cameras.

#### PreserveApps

Apps to preserve on laptops:

```json
{
  "Microsoft.WindowsCamera": true,
  "Microsoft.WindowsCalculator": true
}
```

**Rationale:**
- Camera preservation ensures users can still take photos
- Calculator preservation essential for touch screen users

---

### Desktop Configuration

Optimized for desktop workstations without touch screens or cameras.

#### PreserveApps

Empty hashtable - all bloatware removed.

**Rationale:**
- Desktops typically don't need camera or calculator
- Maximum debloation achieved for business productivity

---

### Domain-Joined Configuration

Optimized for computers joined to Active Directory domain.

#### SkipDomainManagedSettings

```json
{
  "SkipDomainManagedSettings": true
}
```

**Rationale:**
- Domain Group Policy may override local settings
- Prevents conflicts between local and domain policies
- Allows IT to control certain settings centrally

**Behavior:**
- Script will skip domain-managed registry keys
- Warning message will be displayed during execution

---

## Logging Configuration

### LogFilePath

**Default:** `C:\temp\debloat-log.txt`

**Format:** `yyyyMMdd HH:mm:ss [LEVEL] Message`

**Levels:**
- `INFO`: Informational messages
- `WARN`: Warning messages (non-critical issues)
- `ERROR`: Critical errors that may cause script failure

### VerboseLogging

**Default:** `false`

**When Enabled:**
- Detailed logging of all operations
- Registry key/values before modification
- Service status changes
- App removal attempts and results
- Task scheduler actions

**Use Cases:**
- Troubleshooting: Enable verbose logging to diagnose issues
- Testing: Use with `-DryRun -Verbose` to see all actions

---

## Backup Configuration

### BackupPath

**Default:** `C:\temp\registry-backup`

**Backup Behavior:**
- Automatic backup before any registry changes
- Full HKLM and HKCU export
- Timestamped backup files (format: `registry-backup-YYYYMMDD-HHmmss.reg`)

**Backup Files:**
- `registry-backup-YYYYMMDD-HHmmss.reg` - HKLM registry hive
- `registry-backup-YYYYMMDD-HHmmss-HKCU.reg` - HKCU registry hive

---

## Execution Configuration

### Interactive

**Default:** `false`

**When Enabled:**
- Script prompts for confirmation before each action
- User must respond with 'Y' to continue

**Use Cases:**
- Testing: Preview changes without applying
- First-time deployments: User control over each action
- Auditing: User approval for all modifications

---

### DryRun

**Default:** `false`

**When Enabled:**
- Script shows all actions that would be taken
- No actual changes made to system
- Comprehensive logging of planned changes

**Use Cases:**
- Testing: Verify what will be changed before running
- Documentation: Generate preview report
- Training: Show users exactly what will happen

---

### SkipHardwareDetection

**Default:** `false`

**When Enabled:**
- Script skips camera and touch screen detection
- Removes all bloatware apps regardless of hardware

**Hardware Detection Logic:**
```powershell
# Camera Detection
$hasCamera = @(Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Camera*" -or $_.FriendlyName -like "*Webcam*"}).Count -gt 0

# Touch Screen Detection  
$hasTouch = (Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Touch*"}).Count -gt 0
```

**Use Cases:**
- Virtual machines: Often lack real hardware
- Remote desktops: Hardware detection may fail
- Desktops without touch: Remove camera/calculator preservation

---

### SkipDomainCheck

**Default:** `false`

**When Enabled:**
- Script applies settings even on domain-joined machines
- Skips domain detection warnings
- Bypasses Group Policy overrides

**Warning Displayed:**
```
⚠️ WARNING: Machine is domain-joined
Domain Group Policy may override local settings.
Continuing with -SkipDomainCheck flag...
```

**Use Cases:**
- Workgroup computers: IT may manage settings via GPO
- Standalone business machines: May need local settings despite domain
- Test environments: Skip domain checks during testing

---

### RestartExplorer

**Default:** `true`

**When Enabled:**
- Windows Explorer restarts after debloat process
- Ensures registry changes take effect
- Refreshes system UI immediately

**Behavior:**
- Graceful shutdown of Explorer.exe process
- Automatic restart with 5-second delay
- Shows "Restarting Explorer..." message to user

---

### ApplyGroupPolicyUpdates

**Default:** `true`

**When Enabled:**
- Forces Group Policy update after registry changes
- Ensures domain policies are applied
- May require additional processing time

**Command Used:**
```powershell
gpupdate /force /target:computer
```

**Use Cases:**
- Domain-joined computers: Ensures GPO compliance
- Policy testing: Verify GPO application
- Standalone machines: May not be necessary

---

## Registry Configuration Reference

### Advertising Settings

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled | 0 | DWord | Disable advertising ID |
| HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy | 1 | DWord | Disable via Group Policy |

### Privacy Settings

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy\TailoredExperiencesWithDiagnosticDataEnabled | 0 | DWord | Disable tailored experiences |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\ContentDeliveryAllowed | 0 | DWord | Disable content delivery |

### Search Settings

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled | 0 | DWord | Disable Bing search |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\DisableWebSearch | 1 | DWord | Disable web search |
| HKLM:\Software\Policies\Microsoft\Windows\Windows Search\DisableWebSearch | 1 | DWord | Disable web search via policy |
| HKLM:\Software\Policies\Microsoft\Windows\Windows Search\ConnectedSearchUseWeb | 0 | DWord | Disable web search on connections |
| HKLM:\Software\Policies\Microsoft\Windows\Windows Search\ConnectedSearchUseWebOverMeteredConnections | 0 | DWord | Disable on metered connections |
| HKLM:\Software\Policies\Microsoft\Windows\Windows Search\AllowCortana | 0 | DWord | Disable Cortana |

### Start Menu & Taskbar

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDa | 0 | DWord | Disable taskbar ads |
| HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot\TurnOffWindowsCopilot | 1 | DWord | Disable Windows Copilot |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_AccountNotifications | 0 | DWord | Disable account notifications |

### Content Delivery Manager

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338389Enabled | 0 | DWord | Disable suggestions |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SystemPaneSuggestionsEnabled | 0 | DWord | Disable system suggestions |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\RotatingLockScreenOverlayEnabled | 0 | DWord | Disable lock screen ads |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338387Enabled | 0 | DWord | Disable suggestions |

### Cloud Content

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKLM:\Software\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures | 1 | DWord | Disable consumer features |
| HKLM:\Software\Policies\Microsoft\Windows\CloudContent\DisableCloudOptimizedContent | 1 | DWord | Disable cloud content |

### Notifications

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK | 0 | DWord | Disable lock screen toasts |

### Game Bar

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKCU:\Software\Microsoft\GameBar\AllowAutoGameMode | 0 | DWord | Disable auto game mode |
| HKCU:\Software\Microsoft\GameBar\AutoGameModeEnabled | 0 | DWord | Disable game mode |
| HKLM:\Software\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR | 0 | DWord | Disable Game DVR |
| HKLM:\Software\Microsoft\Windows\Windows Error Reporting\Disabled | 1 | DWord | Disable error reporting |

### Edge Settings (Level 3 Suppression)

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PreventFirstRunPage | 1 | DWord | Skip first run page |
| HKCU:\Software\Policies\Microsoft\MicrosoftEdge\PreventFirstRunPage | 1 | DWord | Skip first run page |
| HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Disable3DSecurePrompt | 1 | DWord | Disable 3D secure prompt |
| HKCU:\Software\Policies\Microsoft\MicrosoftEdge\Disable3DSecurePrompt | 1 | DWord | Disable 3D secure prompt |
| HKLM:\Software\Policies\Microsoft\MicrosoftEdge\MetricsReportingEnabled | 0 | DWord | Disable metrics reporting |
| HKLM:\Software\Policies\Microsoft\MicrosoftEdge\SendIntranetTraffictoInternetExplorer | 0 | DWord | Disable telemetry |
| HKLM:\Software\Policies\Microsoft\Edge\Main\AllowDoNotTrack | 1 | DWord | Enable Do Not Track |
| HKLM:\Software\Policies\Microsoft\Edge\Main\AllowPrelaunch | 0 | DWord | Disable prelaunch |
| HKLM:\Software\Policies\Microsoft\Edge\Main\AllowWindowsSpotlight | 0 | DWord | Disable Windows spotlight |
| HKLM:\Software\Policies\Microsoft\Edge\ServiceUI\AllowMicrosoftWelcomeExperience | 0 | DWord | Disable welcome experience |
| HKLM:\Software\Policies\Microsoft\EdgeUpdate\UpdateDefault | 0 | DWord | Disable auto updates |
| HKLM:\Software\Policies\Microsoft\EdgeUpdate\DisableInstaller | 1 | DWord | Disable installer |
| HKLM:\Software\Policies\Microsoft\EdgeUpdate\AutoUpdateCheckPeriodMinutes | 0 | DWord | Disable update checks |

### Explorer Settings

| Registry Path | Value | Type | Purpose |
|---------------|-------|--------|
| HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoInternetOpenWith | 1 | DWord | Remove "Open with" button |

### Browser Association

File and URL associations configured by Set-ChromeDefaultBrowser.ps1

---

## Custom Configuration Examples

### Example 1: Custom App List

Create a custom configuration with specific apps:

```json
{
  "MachineConfigurations": {
    "custom-business": {
      "AppsToRemove": [
        "Microsoft.BingNews",
        "Microsoft.BingWeather"
      ],
      "PreserveApps": {
        "Microsoft.WindowsCalculator": true,
        "Microsoft.WindowsPhotos": true
      }
    }
  }
}
```

### Example 2: Minimal Configuration

Minimal debloation with maximum system performance:

```json
{
  "MachineConfigurations": {
    "minimal": {
      "AppsToRemove": [
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.GamingApp",
        "Microsoft.MicrosoftSolitaireCollection"
      ],
      "PreserveApps": {}
    }
  }
}
```

### Example 3: Development Machine

Configuration for development/testing environments:

```json
{
  "MachineConfigurations": {
    "development": {
      "AppsToRemove": [],
      "PreserveApps": {}
    }
  }
}
```

---

## Advanced Configuration

### Environment Variables

Customize behavior using environment variables:

```powershell
# Set custom log file location
$env:NEXTLEVEL_LOG = "C:\custom-logs\debloat.log"

# Set custom backup location
$env:NEXTLEVEL_BACKUP = "D:\backups\registry"

# Enable verbose logging
$env:NEXTLEVEL_VERBOSE = "true"
```

### Machine Type Detection

Automatically detect hardware and select appropriate configuration:

```powershell
# In business-debloat.ps1
$isLaptop = (Get-CimInstance Win32_SystemBaseBoard).Product -like "*Laptop*" -or (Get-CimInstance Win32_SystemBaseBoard).Product -like "*Notebook*"
if ($isLaptop) {
    Write-Log "Laptop detected - using laptop configuration"
    $machineType = "laptop"
} else {
    Write-Log "Desktop detected - using default configuration"
    $machineType = "desktop"
}
```

---

## Configuration Validation

### Config File Schema

Validate your configuration file against this schema:

```json
{
  "type": "object",
  "required": ["_metadata"],
  "properties": {
    "MachineConfigurations": {
      "type": "object",
      "properties": {
        "default": {
          "type": "object",
          "properties": {
            "AppsToRemove": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "PreserveApps": {
              "type": "object",
              "properties": {}
            },
            "ServicesToDisable": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "TasksToDisable": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "RegistrySettings": {
              "type": "object"
              "properties": {}
            }
          }
        },
        "laptop": {
          "type": "object",
          "properties": {
            "AppsToRemove": { "$ref": "#/properties/default/AppsToRemove" },
            "PreserveApps": {
              "type": "object",
              "properties": {
                "Microsoft.WindowsCamera": {
                  "type": "boolean"
                },
                "Microsoft.WindowsCalculator": {
                  "type": "boolean"
                }
              }
            },
            "ServicesToDisable": { "$ref": "#/properties/default/ServicesToDisable" },
            "TasksToDisable": { "$ref": "#/properties/default/TasksToDisable" },
            "RegistrySettings": { "$ref": "#/properties/default/RegistrySettings" }
          }
        }
      }
    },
    "Logging": {
      "type": "object",
      "properties": {
        "Enabled": {
          "type": "boolean"
        },
        "LogFilePath": {
          "type": "string",
          "pattern": "^[A-Za-z]:\\\\.+\\.log$"
        },
        "VerboseLogging": {
          "type": "boolean"
        }
      }
    },
    "Backup": {
      "type": "object",
      "properties": {
        "Enabled": {
          "type": "boolean"
        },
        "BackupPath": {
          "type": "string",
          "pattern": "^[A-Za-z]:\\\\.+\\\\.*"
        }
      }
    },
    "Execution": {
      "type": "object",
      "properties": {
        "Interactive": {
          "type": "boolean"
        },
        "DryRun": {
          "type": "boolean"
        },
        "SkipHardwareDetection": {
          "type": "boolean"
        },
        "SkipDomainCheck": {
          "type": "boolean"
        },
        "SkipPermissionCheck": {
          "type": "boolean"
        },
        "RestartExplorer": {
          "type": "boolean"
        },
        "ApplyGroupPolicyUpdates": {
          "type": "boolean"
        }
      }
    }
  }
}
```

---

## Deployment Configuration

### Using Custom Configuration with Scripts

```powershell
# Run with custom configuration file
.\business-debloat.ps1 -ConfigFile "custom-config.json"

# Run with laptop configuration
.\business-debloat.ps1 -ConfigFile "debloat-config.json"
# Note: Will automatically detect laptop configuration

# Run with dry run
.\business-debloat.ps1 -DryRun -ConfigFile "debloat-config.json"

# Run in interactive mode
.\business-debloat.ps1 -Interactive -ConfigFile "debloat-config.json"

# Skip hardware detection
.\business-debloat.ps1 -SkipHardwareDetection -ConfigFile "debloat-config.json"

# Skip domain check
.\business-debloat.ps1 -SkipDomainCheck -ConfigFile "debloat-config.json"
```

---

## Migration Notes

### Version 2.x to Version 3.0 Changes

**Breaking Changes:** None - backward compatible

**New Features:**
- GitHub integration
- Automated deployment script
- Documentation overhaul
- Enhanced security features
- Better error handling

**Deprecation Warnings:**
- Manual registry backups still supported via reg export
- Legacy configuration parameters maintained

---

## Support

For configuration questions or custom deployment needs:

**Email:** bryan@mundytuned.com  
**Business:** #MundyTuned

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-31