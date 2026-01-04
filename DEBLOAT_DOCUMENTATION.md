# Windows 11 Business Debloat - Complete Documentation

#MundyTuned - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Last Updated:** 2025-12-31 15:00:00  
**Script Version:** 2.0  
**Execution Log:** `debloat-log.txt`

## Quick Reference

```powershell
# Basic run
.\business-debloat.ps1

# Preview changes
.\business-debloat.ps1 -DryRun

# Interactive mode
.\business-debloat.ps1 -Interactive

# Full force run
.\business-debloat.ps1 -ContinueAnyway -SkipPermissionCheck
```

---

## 🎯 What This Script Does

### Phase 1: System Backup & Permissions
- ✅ Creates System Restore Point (when allowed by Windows)
- ✅ Backs up HKLM registry (approx 340MB)
- ✅ Backs up HKCU registry (approx 1.3MB)
- ✅ Verifies admin privileges
- ✅ Validates registry write permissions
- ✅ Checks service management access
- ✅ Tests appx package management
- ✅ Validates task scheduler access
- ✅ Checks Windows Defender status
- ✅ Verifies backup directory permissions

### Phase 2: Bloatware Removal (36 Apps)

#### Microsoft Consumer Apps
- **BingNews** - News aggregator
- **BingWeather** - Weather app
- **GetHelp** - Windows help app
- **Getstarted** - Tips & welcome app
- **FeedbackHub** - User feedback app
- **Maps** - Offline maps
- **StickyNotes** - Note-taking app

#### Gaming & Entertainment
- **Xbox App** - Xbox gaming hub
- **Xbox TCUI** - Xbox text chat UI
- **Xbox Game Overlay** - In-game Xbox overlay
- **Xbox Gaming Overlay** - Gaming overlay
- **Xbox Identity Provider** - Xbox authentication
- **Xbox Speech to Text Overlay** - Voice chat overlay
- **GamingApp** - Xbox game management
- **GameBar** - Windows Game Bar (via registry)

#### Productivity & Office
- **Microsoft Office Hub** - Office installation gateway
- **OneDriveSync** - OneDrive integration
- **Todos** - Microsoft To Do
- **Outlook for Windows** - New Outlook client

#### Communication & Social
- **Skype App** - Skype consumer app
- **YourPhone** - Phone Link
- **People** - Contacts app
- **Mail & Calendar** - Windows Mail/Calendar apps

#### Media & Creative
- **Photos** - Windows Photos app
- **Zune Music** - Groove Music
- **Zune Video** - Movies & TV
- **WindowsCamera** - Camera app
- **WindowsSoundRecorder** - Voice Recorder
- **MSPaint** - Paint app
- **Windows Alarms** - Clock & alarms

#### System Tools
- **WindowsCalculator** - Calculator app
- **WindowsBackup** - Windows backup tool
- **Windows Phone** - Phone integration
- **MixedReality Portal** - Mixed reality setup
- **Power Automate Desktop** - Automation tool
- **Store Purchase App** - Store purchase gateway
- **3D Viewer** - 3D model viewer
- **Wallet Service** - Digital wallet
- **Web Media Extensions** - Media codecs
- **Connectivity Store** - Network-related store
- **Windows AI Copilot Provider** - Copilot integration

#### AI & Assistant
- **Windows Copilot Provider** - AI assistant backend

### Phase 3: Service Disabling (8 Services)

| Service | Purpose | Risk |
|---------|---------|------|
| **XblAuthManager** | Xbox authentication | None |
| **XboxNetApiSvc** | Xbox networking | None |
| **XboxGipSvc** | Xbox input device service | None |
| **DiagTrack** | Telemetry/data collection | None (recommended) |
| **MapsBroker** | Offline maps broker | None |
| **WalletService** | Digital wallet | None |
| **RetailDemo** | Retail demo mode | None |
| **wisvc** | Windows Insider Service | None |

### Phase 4: Scheduled Task Disabling (4 Tasks)

| Task | Purpose | Impact |
|------|---------|--------|
| **Microsoft Compatibility Appraiser** | Telemetry/data gathering | None |
| **Customer Experience Improvement Program** | Telemetry | None |
| **Program Data Updater** | Telemetry | None |
| **XblGameSaveTask** | Xbox game saves | None |

**⚠️ NOTE:** Windows Update tasks are **NOT** disabled - your updates will continue normally.

### Phase 5: Registry Modifications (30+ Settings)

#### Advertising & Telemetry
- Disable advertising ID
- Disable tailored experiences
- Disable diagnostic data sharing
- Disable cloud content
- Disable consumer features

#### Copilot & AI
- Disable Windows Copilot
- Disable Copilot sidebar in Edge

#### Search & Cortana
- Disable Cortana
- Disable Bing search in Windows Search
- Disable web search in Windows Search
- Disable connected search features

#### Start Menu & Taskbar
- Disable taskbar widgets
- Disable start menu ads
- Disable account notifications
- Disable content suggestions

#### Lock Screen & Personalization
- Disable Spotlight
- Disable lock screen ads
- Disable rotating lock screen overlay

#### Notifications & Popups
- Disable toasts above lock screen
- Disable push notifications

#### Gaming
- Disable Game Bar
- Disable Game DVR
- Disable Auto Game Mode

#### Edge Browser (Level 3 Suppression)
- **Disable Edge first run page**
- **Disable 3D Secure prompts**
- **Disable Edge telemetry/metrics**
- **Disable Edge startup boost**
- **Disable Edge Windows Spotlight**
- **Disable Edge welcome experience**
- **Disable Edge auto-updates**
- **Disable Edge installer**
- **Disable Edge services:**
  - MicrosoftEdgeElevationService
  - edgeupdate
  - edgeupdatem
- **Remove Edge shortcuts:**
  - Desktop shortcuts
  - Taskbar pinned shortcuts
- **Block "Open with" Edge prompts**
- **Disable Edge web views in Windows Search**

#### Edge Browser Policies
- **Prevent first run page**
- **Disable metrics reporting**
- **Disable prelaunch**
- **Disable Windows Spotlight in Edge**
- **Disable Microsoft welcome experience**
- **Disable auto-updates**
- **Disable installer**
- **Disable update checks**

#### Windows Error Reporting
- Disable Windows Error Reporting

### Phase 6: Final System Updates
- Apply Group Policy updates (`gpupdate /force`)
- Restart Windows Explorer to refresh UI

---

## 📋 What Gets Preserved

### Hardware-Based Preservation
- **Camera** → Preserves Windows Camera app if hardware detected
- **Touchscreen** → Preserves Calculator app if hardware detected

### Never Removed
- **Windows Store** → Required for app installation
- **Windows Update** → Critical for security
- **Windows Defender** → Antivirus protection
- **PowerShell** → System management
- **Notepad** → Text editor
- **Windows Terminal** → Command line interface

---

## 🔄 Rollback & Recovery

### Registry Backup Files
```
C:\temp\registry-backup-20251231-141805.reg        (HKLM - 341MB)
C:\temp\registry-backup-20251231-141805-HKCU.reg    (HKCU - 1.3MB)
```

### How to Rollback

**Method 1: Restore Registry**
```powershell
reg import "C:\temp\registry-backup-20251231-141805.reg"
reg import "C:\temp\registry-backup-20251231-141805-HKCU.reg"
```

**Method 2: System Restore**
```powershell
rstrui.exe
# Select restore point created before running script
```

**Method 3: Manual Reinstall of Apps**
```powershell
# Reinstall from Microsoft Store
Get-AppxPackage -AllUsers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```

---

## ⚠️ Known Issues & Warnings

### Execution Policy
**Warning:** Execution policy is 'Undefined' may block script execution
**Fix:** `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Windows Defender
**Warning:** Windows Defender Real-time Protection is ENABLED - may interfere with script operations
**Impact:** May block some registry changes
**Recommendation:** Monitor logs for permission errors

### Domain-Joined Machines
**Warning:** Machine is domain-joined - Group Policy may override local settings
**Impact:** Some settings may be reverted by domain policies
**Workaround:** Use `-SkipDomainCheck` flag (may not override GPO)

### Task Scheduler
**Fixed:** Function naming conflict resolved in v2.0
**Status:** All 4 scheduled tasks successfully disabled

---

## 🔧 Configuration Options

### Command Line Parameters

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `-DryRun` | `$false` | Preview changes without applying |
| `-Interactive` | `$false` | Prompt for each action |
| `-ConfigFile` | `debloat-config.json` | Path to configuration file |
| `-LogFile` | `debloat-log.txt` | Path to log file |
| `-SkipHardwareDetection` | `$false` | Remove all apps (ignore hardware) |
| `-SkipDomainCheck` | `$false` | Apply settings even on domain |
| `-ContinueAnyway` | `$false` | Ignore permission warnings |
| `-SkipPermissionCheck` | `$false` | Skip initial permission validation |

### Configuration File (`debloat-config.json`)

```json
{
  "MachineConfigurations": {
    "default": {
      "AppsToRemove": [...],
      "PreserveApps": {},
      "ServicesToDisable": [...],
      "TasksToDisable": [...]
    },
    "laptop": {
      "PreserveApps": {
        "Microsoft.WindowsCamera": true,
        "Microsoft.WindowsCalculator": true
      }
    },
    "desktop": {
      "PreserveApps": {}
    }
  }
}
```

---

## 📊 Execution Summary

### Last Run: 2025-12-31 14:18:03

#### Permissions
- ✅ Running as Administrator
- ✅ HKLM registry write permissions
- ✅ HKCU registry write permissions
- ✅ Service management permissions
- ✅ Appx package management permissions
- ✅ Task scheduler permissions
- ✅ Backup directory write permissions

#### Actions Taken
- ✅ **36** apps removed
- ✅ **8** services disabled
- ✅ **4** scheduled tasks disabled
- ✅ **30+** registry settings applied
- ✅ **3** Edge services disabled
- ✅ **3** Edge shortcuts removed
- ✅ Explorer restarted

#### Backup Created
- ✅ System Restore Point (frequency-limited by Windows)
- ✅ HKLM registry backup (341MB)
- ✅ HKCU registry backup (1.3MB)

---

## 🚀 Post-Execution Recommendations

### Immediate Actions
1. **Reboot** for full effect of registry changes
2. **Test** default browser settings
3. **Verify** Windows Update is still working
4. **Check** Task Scheduler for your custom tasks

### Optional Additional Steps
1. Install preferred browser and set as default
2. Configure default file associations
3. Review installed programs list
4. Test business-critical applications

### Verification Commands
```powershell
# Check service status
Get-Service | Where-Object {$_.Status -eq "Running"}

# Check appx packages
Get-AppxPackage -AllUsers | Select-Object Name

# Check scheduled tasks
Get-ScheduledTask | Select-Object TaskName, State

# Check registry changes
Get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo"

# Check Edge status
Get-AppxPackage -Name '*MicrosoftEdge*'
```

---

## 📝 Maintenance & Updates

### Script Version History
- **v2.0** (2025-12-31) - Added Level 3 Edge suppression, fixed scheduled task function
- **v1.0** (2025-12-31) - Initial release with basic debloat functionality

### When to Re-Run Script
- After Windows Feature Updates
- When new bloatware appears
- After major Windows updates
- When settings appear to revert

### Keeping Documentation Current
This documentation is dynamically maintained. Update after:
- Script modifications
- New features added
- Bugs fixed
- Configuration changes

---

## 🛡️ Security & Privacy Benefits

### Removed Data Collection
- **Telemetry tracking** (DiagTrack service)
- **Usage data collection** (CEIP tasks)
- **Advertising ID tracking**
- **Location services** (when not needed)
- **Diagnostic data sharing**

### Privacy Enhancements
- **Disabled web search** in Windows Search
- **Removed Cortana** voice assistant
- **Disabled Microsoft account sync** (where applicable)
- **Blocked AI features** (Copilot)
- **Limited Edge telemetry**

---

## 📞 Support & Troubleshooting

### Common Issues

**Issue:** Apps reappearing after updates
**Fix:** Re-run script after Windows updates

**Issue:** Registry changes reverted
**Fix:** Check for Group Policy overrides, use `-SkipDomainCheck`

**Issue:** Services re-enabled
**Fix:** Check Windows Update logs, re-run script

**Issue:** Edge still opening
**Fix:** Set your preferred browser as default in Settings → Apps → Default apps

### Log Analysis
Check `debloat-log.txt` for:
- Failed permissions
- Registry errors
- Service startup failures
- App removal issues

---

## ✅ Success Criteria

Script execution is successful when:
- All 36 bloatware apps removed (or skipped per hardware detection)
- All 8 telemetry/gaming services disabled
- All 4 scheduled tasks disabled
- All 30+ registry settings applied
- Edge services disabled
- Edge shortcuts removed
- Explorer restarted without errors
- Log file shows no critical failures

---

**End of Documentation**  
**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
*This document is automatically maintained. Last generated: 2025-12-31 15:00:00*