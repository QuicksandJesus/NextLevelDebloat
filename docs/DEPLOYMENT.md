# NextLevelDebloat - Windows 11 Deployment Guide

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Document Version:** 1.0 | Last Updated: 2025-12-31  
**Status:** ✅ Complete

---

## Overview

This guide provides step-by-step instructions for deploying NextLevelDebloat to Windows 11 machines. The deployment process is automated with comprehensive validation, logging, and error handling.

---

## Prerequisites

### System Requirements

- **Operating System**: Windows 11 Pro or Enterprise
- **PowerShell**: Version 5.1 or higher
- **Permissions**: Administrator privileges required
- **Memory**: Minimum 4GB RAM
- **Disk Space**: Minimum 500MB free space
- **Network**: Internet connection for updates and verification

### User Account Requirements

- **Administrator** access on target machine
- **GitHub Access** for cloning repository (if using GitHub deployment)
- **Network credentials** for UNC paths (if deploying from network share)

---

## Deployment Methods

### Method 1: Single Machine Deployment (Recommended)

**Best for:** Single computer, testing, small offices

**Steps:**

1. **Prepare Deployment Media**
   ```powershell
   # Copy these files to USB drive
   Copy-Item -Path "C:\temp" -Destination "E:\NextLevelDebloat\" -Recurse
   ```

2. **Transfer to Target Machine**
   ```powershell
   # Copy from USB to target machine
   Copy-Item -Path "E:\NextLevelDebloat\" -Destination "C:\temp" -Recurse
   ```

3. **Run Deployment Script**
   ```powershell
   # Navigate to deployment location
   cd C:\temp
   
   # Run automated deployment
   .\Deploy-NextLevelDebloat.ps1
   ```

4. **Verify Deployment**
   ```powershell
   # Run verification script
   .\verify-restoration.ps1
   
   # Check execution log
   Get-Content C:\temp\deployment-report-*.txt | Select-Object -Last 5
   ```

**Time Estimate:** 10-15 minutes per machine

---

### Method 2: Network Share Deployment

**Best for:** Multiple computers in same location, large offices

**Prerequisites:**
- Network share with read access
- Target computers have access to share
- Deploy to share first, then run from each machine

**Steps:**

1. **Create Deployment Share**
   ```powershell
   # Create shared folder on file server
   New-Item -ItemType Directory -Path "\\server\NextLevelDebloat" -Force
   Copy-Item -Path "C:\temp\*" -Destination "\\server\NextLevelDebloat\" -Recurse
   ```

2. **Deploy from Each Machine**
   ```powershell
   # On each target machine
   Copy-Item -Path "\\server\NextLevelDebloat\*" -Destination "C:\temp\" -Recurse
   cd C:\temp
   .\Deploy-NextLevelDebloat.ps1
   ```

3. **Centralized Verification**
   ```powershell
   # Collect deployment reports from all machines
   # Generate summary report
   # Verify all deployments succeeded
   ```

**Time Estimate:** 5-10 minutes per machine (after initial share setup)

---

### Method 3: GitHub Deployment

**Best for:** Distributed teams, remote locations, version control

**Prerequisites:**
- Private GitHub repository: `bmundy1996/NextLevelDebloat`
- Git installed on all machines
- Network connectivity to GitHub

**Steps:**

1. **Clone Repository**
   ```bash
   git clone https://github.com/bmundy1996/NextLevelDebloat.git
   cd NextLevelDebloat
   ```

2. **Run Deployment**
   ```powershell
   .\Deploy-NextLevelDebloat.ps1
   ```

3. **Push Changes Back** (if customizing per location)
   ```bash
   git add .
   git commit -m "Customization for [location]"
   git push
   ```

**Time Estimate:** 5-10 minutes per machine (plus clone time: 1-2 minutes)

---

## Pre-Deployment Checklist

### System Requirements

- [ ] Windows 11 Pro/Enterprise installed
- [ ] PowerShell 5.1+ available
- [ ] Administrator privileges available
- [ ] Minimum 4GB RAM available
- [ ] Minimum 500MB disk space free
- [ ] Network connectivity available

### User Access

- [ ] Administrator account or credentials
- [ ] GitHub access (if using GitHub method)
- [ ] Network share access (if using network method)

### Backup Preparation

- [ ] Current system backed up (System Restore Point)
- [ ] Important data backed up
- [ ] Document current configuration
- [ ] Note any custom software installed

### Deployment Media

- [ ] Deployment files copied to USB drive
- [ ] Files verified (no corruption)
- [ ] README.md read and understood
- [ ] Troubleshooting guide reviewed
- [ ] Emergency rollback procedure understood

---

## Deployment Process

### Phase 1: Preparation

1. **Extract Deployment Package**
   - Copy deployment files to target location
   - Verify all files present and accessible

2. **Review Configuration**
   - Open `debloat-config.json`
   - Review machine-specific settings if needed
   - Make note of any customizations required

3. **Verify Environment**
   - Run: `Get-ComputerInfo` to check system
   - Verify PowerShell version: `$PSVersionTable.PSVersion`
   - Check disk space: `Get-PSDrive C | Select-Object Used,Free`

### Phase 2: Deployment

1. **Run Automated Script**
   ```powershell
   cd C:\temp
   .\Deploy-NextLevelDebloat.ps1
   ```

2. **Monitor Progress**
   - Watch for permission prompts
   - Review console output for errors
   - Check for success indicators

3. **Verify Completion**
   - Check deployment report: `C:\temp\deployment-report-*.txt`
   - Verify log file: `C:\temp\debloat-log.txt`
   - Run verification script

### Phase 3: Post-Deployment

1. **System Verification**
   ```powershell
   # Test essential applications
   # Verify network connectivity
   # Check Windows Update functionality
   ```

2. **User Acceptance Testing**
   - Verify user can log in
   - Test essential applications work
   - Get user acknowledgment

3. **Documentation Handover**
   - Provide user with updated documentation
   - Explain changes made to system
   - Provide restoration procedures if needed

---

## Configuration Options

### Machine Type Configuration

Edit `debloat-config.json` to customize deployment:

```json
{
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
}
```

### Execution Parameters

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `-DryRun` | Preview changes without applying | false | `.\Deploy-NextLevelDebloat.ps1 -DryRun` |
| `-Interactive` | Prompt for each action | false | `.\Deploy-NextLevelDebloat.ps1 -Interactive` |
| `-SetChromeDefault` | Set Chrome as default browser | false | `.\Deploy-NextLevelDebloat.ps1 -SetChromeDefault` |
| `-SkipHardwareDetection` | Remove all apps regardless | false | `.\Deploy-NextLevelDebloat.ps1 -SkipHardwareDetection` |
| `-SkipDomainCheck` | Apply on domain-joined machines | false | `.\Deploy-NextLevelDebloat.ps1 -SkipDomainCheck` |
| `-SkipPermissionCheck` | Skip validation (not recommended) | false | `.\Deploy-NextLevelDebloat.ps1 -SkipPermissionCheck` |
| `-ContinueAnyway` | Proceed despite warnings | false | `.\Deploy-NextLevelDebloat.ps1 -ContinueAnyway` |

---

## Post-Deployment Verification

### Quick Checks

```powershell
# 1. Verify apps removed
Get-AppxPackage -AllUsers | Where-Object {
    $_.Name -in "Microsoft.BingNews","Microsoft.BingWeather"
} | Measure-Object

# 2. Verify services disabled
Get-Service | Where-Object {
    $_.Name -eq "DiagTrack"
} | Select-Object Name, Status, StartType

# 3. Verify registry settings
Get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy"

# 4. Check scheduled tasks
Get-ScheduledTask | Where-Object {
    $_.TaskName -like "*Microsoft*"
} | Select-Object TaskName, State
```

### Comprehensive Verification

```powershell
# Run full verification script
.\verify-restoration.ps1 -Verbose
```

---

## Troubleshooting

### Pre-Deployment Issues

**Issue:** "Access Denied"

**Cause:** Not running as Administrator

**Solution:**
```powershell
# Right-click and select "Run as Administrator"
# Or run from elevated PowerShell:
Start-Process powershell -Verb RunAs -ArgumentList "-File C:\temp\Deploy-NextLevelDebloat.ps1"
```

**Issue:** "Files Missing"

**Cause:** Deployment package incomplete

**Solution:**
- Verify all files copied from source
- Check deployment package integrity
- Re-download from repository if needed

**Issue:** "PowerShell Execution Policy Blocked"

**Cause:** Execution policy set to Restricted or AllSigned

**Solution:**
```powershell
# Set to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for deployment only
powershell -ExecutionPolicy Bypass -File C:\temp\Deploy-NextLevelDebloat.ps1
```

### Post-Deployment Issues

**Issue:** "Services Still Running"

**Cause:** Services failed to stop or disable

**Solution:**
```powershell
# Check service status
Get-Service DiagTrack,XblAuthManager

# Force stop services
Stop-Service -Name DiagTrack -Force
Stop-Service -Name XblAuthManager -Force

# Disable services
Set-Service -Name DiagTrack -StartupType Disabled -Force
Set-Service -Name XblAuthManager -StartupType Disabled -Force
```

**Issue:** "Apps Not Removed"

**Cause:** Domain Group Policy overriding local settings

**Solution:**
```powershell
# Run with -SkipDomainCheck flag
.\business-debloat.ps1 -SkipDomainCheck
```

**Issue:** "System Performance Degraded"

**Cause:** Too many services/services running

**Solution:**
```powershell
# Check running processes
Get-Process | Sort-Object CPU -Descending

# Check service status
Get-Service | Where-Object {$_.Status -eq "Running"}

# Reboot machine to clear cached data
Restart-Computer -Force
```

---

## Rollback Procedures

### Option 1: Automatic Restoration

```powershell
# Run complete restoration
.\business-debloat-restore.ps1 -RestoreAll

# This will:
# - Import registry backups
# - Re-enable all services
# - Re-enable all tasks
# - Reinstall all removed apps
# - Remove business policies
```

**Time Estimate:** 20-30 minutes

### Option 2: Selective Restoration

```powershell
# Restore specific components
.\business-debloat-restore.ps1 -RestoreRegistry
.\business-debloat-restore.ps1 -RestoreServices
.\business-debloat-restore.ps1 -RestoreTasks
.\business-debloat-restore.ps1 -RestoreApps
```

**Time Estimate:** 10-20 minutes

### Option 3: System Restore Point

```powershell
# Open System Restore
rstrui.exe

# Select restore point from before deployment
# Follow restore wizard
```

**Time Estimate:** 5-10 minutes

---

## Deployment Scenarios

### Scenario 1: Fresh Windows 11 Install

**Considerations:**
- No user data to preserve
- No existing configuration to maintain
- Can use aggressive debloation

**Steps:**
1. Deploy NextLevelDebloat immediately after Windows setup
2. Use default configuration (no customizations)
3. Set Chrome as default browser during deployment

**Time Estimate:** 15 minutes

---

### Scenario 2: Existing Windows 11 Installation

**Considerations:**
- Preserve existing user data
- Maintain current user preferences
- Review custom software before deployment

**Steps:**
1. Document current configuration
2. Backup user data and settings
3. Test deployment in test environment first
4. Deploy to production after testing
5. Verify business applications after deployment

**Time Estimate:** 20-30 minutes

---

### Scenario 3: Laptop Deployment

**Considerations:**
- Preserve camera and calculator apps
- Battery-powered device considerations
- Mobile/portable usage patterns

**Steps:**
1. Use `laptop` configuration in debloat-config.json
2. Test camera and calculator before deployment
3. Verify power settings preserve battery life
4. Deploy and verify essential apps still work

**Time Estimate:** 20 minutes

---

### Scenario 4: Desktop Deployment

**Considerations:**
- No camera or touch screen
- May have specific software requirements
- Power saving less critical

**Steps:**
1. Use `desktop` configuration
2. Deploy with all app removals enabled
3. Verify display settings
4. Test business applications

**Time Estimate:** 15 minutes

---

## Maintenance Procedures

### Daily Checks

- [ ] Verify Windows Update functionality
- [ ] Check for new critical updates
- [ ] Review error logs in C:\temp
- [ ] Verify system performance

### Weekly Tasks

- [ ] Review deployment logs for patterns
- [ ] Check for failed updates
- [ ] Verify snapshot retention policy (7 days)
- [ ] Clean up old snapshots automatically

### Monthly Reviews

- [ ] Review all deployed machines
- [ ] Update documentation as needed
- [ ] Check for Windows 11 feature updates
- [ ] Evaluate deployment success metrics

---

## Security Considerations

### During Deployment

- **Never** share deployment credentials
- **Always** use HTTPS for GitHub operations
- **Verify** file integrity before deployment
- **Document** any customizations per machine
- **Maintain** secure storage of deployment media

### After Deployment

- **Remove** deployment files from temporary locations
- **Clear** Windows Defender history if needed
- **Disable** local administrator accounts if not needed
- **Enable** BitLocker if available (for physical security)

### Access Control

- **Limit** deployment script access to administrators
- **Document** who has deployed to each machine
- **Maintain** deployment log with timestamps
- **Implement** change control process for deployments

---

## Contact & Support

### Primary Contact

**Business:** #MundyTuned  
**Email:** bryan@mundytuned.com  
**For:** Deployment issues, configuration questions, feature requests

### Documentation

**Complete Guide:** This document  
**System Architecture:** docs/ARCHITECTURE.md  
**Configuration Reference:** docs/CONFIGURATION.md  
**Restoration Procedures:** docs/RESTORATION.md  
**Troubleshooting:** docs/TROUBLESHOOTING.md  
**API Reference:** docs/API_REFERENCE.md

---

## Appendix

### A: File Manifest

| File | Purpose | Location |
|-------|---------|----------|
| Deploy-NextLevelDebloat.ps1 | Automated deployment script | C:\temp\ |
| business-debloat.ps1 | Main optimization script | C:\temp\ |
| business-debloat-restore.ps1 | Restoration script | C:\temp\ |
| debloat-config.json | Configuration file | C:\temp\ |
| README.md | Project overview | C:\temp\ |

### B: PowerShell Reference

| Function | Purpose | Script |
|---------|---------|----------|
| Write-Log | Logging utility | business-debloat.ps1 |
| Get-SystemInventory | System information | Deploy-NextLevelDebloat.ps1 |
| Create-Snapshot | Backup creation | Deploy-NextLevelDebloat.ps1 |
| Validate-DeploymentEnvironment | Environment checks | Deploy-NextLevelDebloat.ps1 |
| Apply-DebloatSettings | Main optimization logic | business-debloat.ps1 |

### C: Registry Keys Modified

| Registry Path | Purpose | Type |
|---------------|---------|------|
| HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo | Disable advertising | DWord |
| HKLM:\Software\Policies\Microsoft\Windows\Windows Search | Disable Bing search | DWord |
| HKLM:\Software\Policies\Microsoft\Windows\CloudContent | Disable cloud features | DWord |
| HKLM:\Software\Policies\Microsoft\Edge* | Edge policies | Various |
| HKCU:\Software\Microsoft\Windows\CurrentVersion\* | User settings | Various |

### D: Services Disabled

| Service Name | Purpose | Type |
|--------------|---------|------|
| DiagTrack | Telemetry | Auto |
| XblAuthManager | Xbox authentication | Manual |
| XboxNetApiSvc | Xbox network | Manual |
| XboxGipSvc | Xbox game invite | Manual |
| MapsBroker | Maps background | Auto |
| WalletService | Microsoft Wallet | Manual |
| RetailDemo | Retail demo mode | Manual |
| wisvc | Windows Insider | Manual |
| MicrosoftEdgeElevationService | Edge elevation | Auto |
| edgeupdate | Edge updates | Auto |
| edgeupdatem | Edge updates (mobile) | Auto |

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-31  
**Status:** ✅ Complete  
**Next Review:** 2026-06-31

---

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com