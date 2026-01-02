# NextLevelDeBloat - Windows 11 Business Optimization

**Project Status:** ✅ Complete | Version: 3.0 | Last Updated: 2025-12-31

## Project Goal

NextLevelDeBloat is an automated Windows 11 business optimization solution that removes pre-installed bloatware, disables telemetry and tracking, optimizes privacy settings, and provides full restoration capabilities. Designed for #MundyTuned to streamline Windows 11 deployment across multiple computers with consistent, reproducible results.

**Contact:** bryan@mundytuned.com  
**Business:** #MundyTuned  
**Repository:** NextLevelDeBloat (Private GitHub)

---

## System Overview

Complete Windows 11 business optimization solution with consumer restoration capability. This package removes bloatware, enhances privacy, reduces system overhead, and provides multiple restoration methods to return to consumer Windows 11 state.

---

## System Inventory

**Last Inventory Date:** 2025-12-31  
**Machine:** WESTCHKPT1  
**Platform:** Windows 11 (Build 26100)

### Running Processes
- PowerShell 5.1.26100.7462
- Windows Task Scheduler (Active)
- Windows Update Service (Running)
- Git 2.52.0 (Installed)

### Installed Software
- Windows 11 (Current Build)
- Google Chrome (Detected for default browser configuration)
- #MundyTuned Debloat Scripts (v3.0)

### Network Configuration
- GitHub: Private repository (NextLevelDebloat)
- Windows Update: Microsoft Update (3rd party products enabled)

### File System
- Working Directory: C:\temp
- Snapshots: snapshots/ (7-day retention)
- Documentation: docs/

### Registry State
- Backup location: C:\temp\registry-backup-*.reg
- Policy location: HKLM:\Software\Policies\Microsoft\

---

## Features

### Business Optimization
- [X] Removes 36 bloatware apps
- [X] Disables 11 unnecessary services (including 3 Edge services)
- [X] Disables 4 telemetry tasks
- [X] Applies 40+ privacy/business policies
- [X] Level 3 Edge suppression (updates, telemetry, policies blocked)
- [X] Automatic system backup
- [X] Hardware-based app preservation
- [X] Detailed logging

### Consumer Restoration
- [X] Automated restoration script
- [X] Four restoration methods available
- [X] Reinstalls all Windows apps
- [X] Re-enables all services
- [X] Removes business policies
- [X] Restores Edge functionality
- [X] Verification included

### Documentation
- [X] Complete master documentation
- [X] Detailed debloat explanations
- [X] Consumer deployment guide
- [X] Quick reference guides
- [X] Troubleshooting procedures
- [X] Emergency procedures

---

## Quick Deployment

### Automated Deployment (Recommended)

```powershell
# Clone repository or copy files to target machine
cd C:\temp

# Run automated deployment (creates snapshots, validates system, applies debloat)
.\Deploy-NextLevelDebloat.ps1
```

### Manual Deployment

1. Review [DEPLOYMENT.md](docs/DEPLOYMENT.md)
2. Run `.\business-debloat.ps1 -DryRun` to preview changes
3. Execute `.\business-debloat.ps1` to apply optimization
4. Verify results with `.\verify-restoration.ps1`

### GitHub Integration

```powershell
# After initial deployment
git init
git add .
git commit -m "Initial NextLevelDeBloat deployment"
git remote add origin https://github.com/bmundy1996/NextLevelDeBloat.git
git push -u origin main
```

**Note:** Configure GitHub credentials securely using `gh auth login` or personal access token. Do NOT hardcode API keys in scripts.

---

## Files Included

### Deployment Scripts
- `Deploy-NextLevelDebloat.ps1` - Automated deployment with validation and snapshot creation

### Documentation
- FINAL_SUMMARY.md - START HERE - Complete overview
- MASTER_DOCUMENTATION.md - Complete master reference
- CONSUMER_DEPLOYMENT.md - Consumer restoration guide
- DEBLOAT_DOCUMENTATION.md - Detailed debloat explanation
- QUICK_REFERENCE.md - Quick command reference
- PACKAGE_INDEX.md - Complete file inventory

### Scripts
- business-debloat.ps1 - Business optimization script (v3.0)
- business-debloat-restore.ps1 - Consumer restoration script (v1.0)
- verify-restoration.ps1 - System verification script (v1.0)

### Configuration
- debloat-config.json - Machine configuration file

### Logs
- debloat-log.txt - Execution log

---

## Quick Start

### Business Deployment

```powershell
# Preview changes
.\business-debloat.ps1 -DryRun

# Run optimization
.\business-debloat.ps1 -ContinueAnyway

# Verify system
.\verify-restoration.ps1
```

### Consumer Restoration

```powershell
# Option 1: System Restore (RECOMMENDED)
rstrui.exe

# Option 2: Automated Restoration
.\business-debloat-restore.ps1 -RestoreAll

# Option 3: Selective Restoration
.\business-debloat-restore.ps1 -RestoreApps -RestoreServices

# Verify restoration
.\verify-restoration.ps1 -Verbose
```

---

## What Gets Removed/Disabled

### Apps (36)
**Gaming:** Xbox (7 apps), GamingApp, GameBar  
**Communication:** Skype, YourPhone, Mail/Calendar, People  
**Entertainment:** Photos, Music (Zune), Videos, Camera  
**Productivity:** OneDrive, Outlook, Office Hub, Todos, Sticky Notes  
**Utilities:** Calculator, Maps, Weather, News, Alarms, Voice Recorder  
**AI/Telemetry:** Copilot, Feedback Hub, Mixed Reality  
**Other:** 3D Viewer, Paint, Wallet, Store Purchase App

### Services (11)
**Telemetry:** DiagTrack, RetailDemo, wisvc  
**Gaming:** XblAuthManager, XboxNetApiSvc, XboxGipSvc  
**Utilities:** MapsBroker, WalletService  
**Edge:** MicrosoftEdgeElevationService, edgeupdate, edgeupdatem

### Tasks (4)
Microsoft Compatibility Appraiser, Customer Experience Improvement Program, Program Data Updater, XblGameSaveTask

---

## Privacy & Security Benefits

### Enhanced Privacy (Business State)
- [X] Telemetry tracking disabled
- [X] Usage analytics disabled
- [X] Advertising ID disabled
- [X] Edge telemetry disabled
- [X] Bing search disabled
- [X] Cortana disabled
- [X] Location services limited
- [X] Windows Error Reporting disabled

---

## Restoration Options

### Option 1: System Restore (RECOMMENDED)
- Time: 5-10 minutes
- Risk: None
- Data Loss: None

### Option 2: Automated Restoration
- Time: 20-30 minutes
- Risk: Low
- Data Loss: None

### Option 3: Manual Restoration
- Time: 30-45 minutes
- Risk: Low
- Data Loss: None

### Option 4: Fresh Reset
- Time: 1-2 hours
- Risk: None
- Data Loss: Yes (with "Keep my files" option)

---

## Requirements

- Windows 11
- PowerShell 5.1 or higher
- Administrator privileges
- Internet connection (for updates/verification)

---

## Usage

### Business Deployment
1. Review FINAL_SUMMARY.md
2. Run .\business-debloat.ps1 -DryRun to preview
3. Run .\business-debloat.ps1 to optimize
4. Verify with .\verify-restoration.ps1
5. Deploy to business users

### Consumer Restoration
1. Review CONSUMER_DEPLOYMENT.md
2. Choose restoration method
3. Execute restoration
4. Verify with .\verify-restoration.ps1 -Verbose
5. Update Windows and configure

---

## Important Notes

- System Restore Points: Limited by Windows (24-hour frequency)
- Edge Suppression: Cannot fully remove Edge (system component)
- Domain-Joined: Group Policy may override local settings
- Windows Updates: May reinstall some apps (re-run script)
- Registry Backups: Created automatically (~295-325MB per run)

---

## Support

### Documentation
| Document | Description | Status |
|----------|-------------|--------|
| [README.md](README.md) | Complete project overview and deployment guide | ✅ Complete |
| [GITHUB_SETUP.md](docs/GITHUB_SETUP.md) | GitHub repository setup and authentication | ✅ Complete |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture and component relationships | 📝 Planned |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Detailed deployment guide for Windows 11 | 📝 Planned |
| [CONFIGURATION.md](docs/CONFIGURATION.md) | Configuration options and JSON reference | 📝 Planned |
| [RESTORATION.md](docs/RESTORATION.md) | Rollback procedures and restoration guide | 📝 Planned |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues and solutions | 📝 Planned |
| [API_REFERENCE.md](docs/API_REFERENCE.md) | PowerShell functions and parameters | 📝 Planned |

### Quick Reference
- **Start Here:** Review this README
- **Deploy:** Run `.\Deploy-NextLevelDebloat.ps1`
- **Verify:** Run `.\verify-restoration.ps1`
- **Restore:** Run `.\business-debloat-restore.ps1`
- **Troubleshoot:** See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

### Contact
**Email:** bryan@mundytuned.com  
**Business:** #MundyTuned  
**For:** Windows optimization support, deployment issues, feature requests

---

## Safety & Reversibility

### Safety Features
- [X] Pre-execution permission checks (admin, registry, services, tasks)
- [X] Automatic registry backups before any changes
- [X] Dry run mode for testing without applying changes
- [X] Hardware detection to preserve essential apps (camera, calculator)
- [X] Domain detection to avoid Group Policy conflicts
- [X] Comprehensive logging of all actions to debloat-log.txt
- [X] Interactive mode with confirmation prompts
- [X] ContinueAnyway flag for advanced users

### Reversibility Options

#### Option 1: Automated Restoration (Recommended)
```powershell
.\business-debloat-restore.ps1 -RestoreAll
```
- Restores registry from backup
- Re-enables all disabled services
- Re-enables all disabled tasks
- Removes business policies
- Reinstalls all removed apps
- Time: 20-30 minutes

#### Option 2: Selective Restoration
```powershell
# Restore specific components
.\business-debloat-restore.ps1 -RestoreRegistry
.\business-debloat-restore.ps1 -RestoreServices
.\business-debloat-restore.ps1 -RestoreTasks
.\business-debloat-restore.ps1 -RestoreApps
```

#### Option 3: System Restore Point
```powershell
# Windows built-in restore
rstrui.exe

# List available restore points
vssadmin list shadows
```
- Uses Windows restore points
- Time: 5-10 minutes
- No data loss
- Most reliable option

#### Option 4: Registry Backup
```powershell
# Import from latest backup
reg import C:\temp\registry-backup-*.reg

# Or use Deployment script backup
reg import C:\temp\snapshots\registry-backup-*.reg
```

### Snapshot Retention
- **Location:** `snapshots/` directory
- **Format:** `snapshot-YYYYMMDD-HHMMSS.tar.gz`
- **Retention:** 7 days (auto-cleaned by Deploy-NextLevelDebloat.ps1)
- **Contents:** Full system state before any changes

---

## Success Criteria

After successful deployment:

- [x] 36+ bloatware apps removed
- [x] 11 services disabled (including 3 Edge services)
- [x] 4 scheduled tasks disabled
- [x] 40+ registry settings applied
- [x] Edge Level 3 suppression complete
- [x] Registry backups created (snapshots/)
- [x] Explorer restarted successfully
- [x] No critical errors in logs
- [x] System fully functional
- [x] Windows Update preserved
- [x] Task Scheduler operational
- [x] Restoration capability verified
- [x] Deployment script successful
- [x] GitHub repository created and populated

---

## License

This software is provided for internal business use.  
**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com

---

## Contributing

For inquiries or support:  
**#MundyTuned** | bryan@mundytuned.com

---

## GitHub Repository

### Repository Details
- **Name:** NextLevelDebloat
- **Owner:** bmundy1996
- **Type:** Private
- **Access:** bmundy1996@gmail.com

### Repository Contents
```
NextLevelDebloat/
├── docs/                          # Comprehensive documentation
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   ├── CONFIGURATION.md
│   ├── RESTORATION.md
│   ├── TROUBLESHOOTING.md
│   └── API_REFERENCE.md
├── snapshots/                      # System backups (7-day retention)
├── business-debloat.ps1          # Main debloat script
├── business-debloat-restore.ps1   # Restoration script
├── debloat-config.json            # Configuration file
├── Set-ChromeDefaultBrowser.ps1   # Chrome helper
├── Deploy-NextLevelDebloat.ps1    # Automated deployment
└── README.md                       # This file
```

### Git Workflow
```bash
# Initial setup
git init
git add .
git commit -m "Initial commit - NextLevelDeBloat v3.0"

# Create private repository (via GitHub web interface)
# Then connect local repo
git remote add origin https://github.com/bmundy1996/NextLevelDebloat.git
git branch -M main
git push -u origin main

# Ongoing development
git add <changed files>
git commit -m "Description of changes"
git push
```

---

## Version History

| Version | Date | Changes |
|---------|--------|---------|
| 3.1 | 2025-12-31 | GitHub integration, automated deployment, documentation overhaul, snapshot management |
| 3.0 | 2025-12-31 | Added Level 3 Edge suppression, automated restoration script, verification script, complete documentation suite |
| 2.0 | 2025-12-30 | Added restoration, Chrome default, domain detection |
| 1.0 | 2025-12-29 | Initial release - Basic debloat functionality |

---

## Acknowledgments

**#MundyTuned** - Windows Optimization Solutions  
Business Email: bryan@mundytuned.com

- Original script concept from community debloat scripts
- Enhanced with business-focused optimizations
- Complete restoration capability added
- Comprehensive documentation created

---

Repository URL: https://github.com/QuicksandJesus/Win11-DeBloat  
Created: 2025-12-31  
Status: ✅ Production Ready with Complete Restoration Capability  
**#MundyTuned** | bryan@mundytuned.com

---

## Quick Commands Reference

```powershell
# Business Optimization
.\business-debloat.ps1                    # Standard run
.\business-debloat.ps1 -DryRun            # Preview changes
.\business-debloat.ps1 -Interactive       # Confirm actions
.\business-debloat.ps1 -ContinueAnyway    # Force run

# Consumer Restoration
.\business-debloat-restore.ps1            # Complete restoration
.\business-debloat-restore.ps1 -DryRun     # Preview
.\business-debloat-restore.ps1 -Interactive # Confirm actions

# Verification
.\verify-restoration.ps1                  # Standard check
.\verify-restoration.ps1 -Verbose         # Detailed

# System Restore
rstrui.exe                              # GUI restore point
vssadmin list shadows                    # List restore points
```

---

**System Optimized for Business Use**  
**Complete Restoration Capability Available**  
**Comprehensive Documentation Included**  

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com