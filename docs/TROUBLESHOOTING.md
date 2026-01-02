# NextLevelDebloat - Troubleshooting Guide

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Document Version:** 1.0 | Last Updated: 2025-12-31  
**Status:** ✅ Complete

---

## Overview

This guide provides comprehensive troubleshooting procedures for NextLevelDebloat deployment and usage issues. Use this guide to diagnose and resolve common problems.

---

## Pre-Deployment Issues

### Issue: "Access Denied" or "Not Running as Administrator"

**Symptoms:**
- Script fails immediately
- Error: "This script must be run as Administrator"
- Registry access denied
- Service management fails

**Causes:**
- PowerShell not running as Administrator
- User Account Control (UAC) blocking elevation
- Insufficient user privileges

**Solutions:**

1. **Right-click Method:**
   ```powershell
   # Right-click PowerShell or script file
   # Select "Run as Administrator"
   ```

2. **Command Line Method:**
   ```powershell
   # Start PowerShell as Administrator
   Start-Process powershell -Verb RunAs

   # Or use runas command
   runas /user:Administrator "powershell.exe"
   ```

3. **Disable UAC Temporarily (Not Recommended):**
   ```cmd
   reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
   # Restart required - re-enable after deployment
   ```

**Prevention:** Always run deployment scripts as Administrator.

---

### Issue: PowerShell Execution Policy Blocks Script

**Symptoms:**
- Error: "execution of scripts is disabled on this system"
- Script won't run despite Administrator privileges
- Security warning about execution policy

**Causes:**
- PowerShell execution policy set to Restricted or AllSigned
- Group Policy restricting script execution
- Security settings blocking unsigned scripts

**Solutions:**

1. **Check Current Policy:**
   ```powershell
   Get-ExecutionPolicy -List
   ```

2. **Set Policy for Current Session:**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope Process -Force
   ```

3. **Set Policy for Current User:**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```

4. **Set Policy System-Wide (Administrator):**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
   ```

5. **Bypass for Single Script:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\temp\business-debloat.ps1"
   ```

**Prevention:** Set execution policy to RemoteSigned during deployment.

---

### Issue: "File Not Found" or Missing Files

**Symptoms:**
- Script can't find configuration file
- Error: "debloat-config.json not found"
- Missing PowerShell modules

**Causes:**
- Incomplete file transfer
- Wrong working directory
- Corrupted download
- Missing dependencies

**Solutions:**

1. **Verify File Presence:**
   ```powershell
   Get-ChildItem "C:\temp" -Name business-debloat.ps1, debloat-config.json
   ```

2. **Check File Integrity:**
   ```powershell
   Get-Item "C:\temp\business-debloat.ps1" | Select-Object Name, Length, LastWriteTime
   ```

3. **Redownload Files:**
   ```bash
   # From GitHub repository
   git clone https://github.com/QuicksandJesus/NextLevelDebloat.git
   cd NextLevelDebloat
   ```

4. **Verify Working Directory:**
   ```powershell
   Get-Location
   Set-Location "C:\temp"
   ```

**Prevention:** Always verify file transfer integrity before deployment.

---

## Deployment Issues

### Issue: Hardware Detection Fails

**Symptoms:**
- Apps not preserved despite hardware presence
- Camera app removed on laptop
- Calculator removed on touch device

**Causes:**
- PnP device enumeration issues
- Hardware not properly detected by Windows
- Virtual machine or remote desktop environment

**Solutions:**

1. **Manual Hardware Check:**
   ```powershell
   # Check for cameras
   Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Camera*" -or $_.FriendlyName -like "*Webcam*"}

   # Check for touch devices
   Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Touch*"}
   ```

2. **Skip Hardware Detection:**
   ```powershell
   .\business-debloat.ps1 -SkipHardwareDetection
   ```

3. **Force Specific Configuration:**
   ```powershell
   # Edit debloat-config.json
   "PreserveApps": {
     "Microsoft.WindowsCamera": true,
     "Microsoft.WindowsCalculator": true
   }
   ```

**Prevention:** Test hardware detection in target environment first.

---

### Issue: Domain-Joined Machine Errors

**Symptoms:**
- Warning: "Machine is domain-joined"
- Some settings may be overridden by Group Policy
- Registry changes fail due to domain policies

**Causes:**
- Active Directory Group Policy overriding local settings
- Domain security policies blocking changes
- Insufficient domain privileges

**Solutions:**

1. **Skip Domain Check:**
   ```powershell
   .\business-debloat.ps1 -SkipDomainCheck
   ```

2. **Check Group Policy:**
   ```cmd
   gpresult /h gpreport.html
   # Open gpreport.html to review applied policies
   ```

3. **Apply as Domain Admin:**
   - Run script with domain administrator credentials
   - Ensure GPO allows local administrator changes

4. **Review Domain Policies:**
   - Contact IT administrator
   - Modify Group Policy to allow changes
   - Deploy in test OU first

**Prevention:** Always test on domain-joined machines first.

---

### Issue: Registry Backup Fails

**Symptoms:**
- Error: "Registry export failed"
- No backup files created in C:\temp
- Warning about registry access

**Causes:**
- Insufficient registry permissions
- Registry corruption
- Anti-virus blocking registry access
- Windows Defender real-time protection

**Solutions:**

1. **Check Permissions:**
   ```powershell
   # Test registry access
   Test-Path "HKLM:\SOFTWARE"
   Test-Path "HKCU:\SOFTWARE"
   ```

2. **Temporarily Disable Anti-virus:**
   ```powershell
   # Windows Defender
   Set-MpPreference -DisableRealtimeMonitoring $true
   # Remember to re-enable after deployment
   Set-MpPreference -DisableRealtimeMonitoring $false
   ```

3. **Manual Registry Backup:**
   ```cmd
   reg export HKLM "C:\temp\registry-backup-HKLM.reg" /y
   reg export HKCU "C:\temp\registry-backup-HKCU.reg" /y
   ```

4. **Skip Backup (Not Recommended):**
   ```powershell
   # Edit script to skip backup creation
   # Remove Backup-Registry function calls
   ```

**Prevention:** Disable real-time protection during deployment.

---

## Post-Deployment Issues

### Issue: Apps Not Removed

**Symptoms:**
- Bloatware apps still visible in Start menu
- Apps appear in "All Apps" list
- Get-AppxPackage shows apps still installed

**Causes:**
- Apps provisioned for new users
- Apps installed for all users
- Microsoft Store cache issues
- Apps reinstalled by Windows Update

**Solutions:**

1. **Check All User Installations:**
   ```powershell
   Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*Xbox*"}
   Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*Xbox*"}
   ```

2. **Remove Provisioned Packages:**
   ```powershell
   Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*Microsoft.XboxApp*"} | Remove-AppxProvisionedPackage -Online
   ```

3. **Clear Store Cache:**
   ```cmd
   wsreset.exe
   ```

4. **Re-run Script:**
   ```powershell
   .\business-debloat.ps1 -ContinueAnyway
   ```

**Prevention:** Check for provisioned packages during verification.

---

### Issue: Services Still Running

**Symptoms:**
- Disabled services show as "Running"
- Services restart after reboot
- Task Manager shows service processes

**Causes:**
- Service dependencies preventing stop
- Group Policy overriding service settings
- Services set to "Manual" instead of "Disabled"
- Windows Update reinstalling service configurations

**Solutions:**

1. **Check Service Status:**
   ```powershell
   Get-Service DiagTrack, XblAuthManager | Select-Object Name, Status, StartType
   ```

2. **Force Stop Services:**
   ```powershell
   Stop-Service DiagTrack -Force
   Stop-Service XblAuthManager -Force
   ```

3. **Set to Disabled:**
   ```powershell
   Set-Service DiagTrack -StartupType Disabled -Force
   Set-Service XblAuthManager -StartupType Disabled -Force
   ```

4. **Check Dependencies:**
   ```powershell
   # Find dependent services
   $service = Get-Service DiagTrack
   $service.DependentServices
   ```

**Prevention:** Stop services before setting startup type to Disabled.

---

### Issue: Scheduled Tasks Still Running

**Symptoms:**
- Disabled tasks show as "Ready"
- Tasks execute despite being disabled
- Task Scheduler shows tasks as enabled

**Causes:**
- Tasks recreated by Windows Update
- Group Policy re-enabling tasks
- Tasks with different path names
- Multiple task instances

**Solutions:**

1. **Check Task Status:**
   ```powershell
   Get-ScheduledTask | Where-Object {$_.TaskName -like "*Microsoft*"} | Select-Object TaskName, State, TaskPath
   ```

2. **Disable All Matching Tasks:**
   ```powershell
   Get-ScheduledTask | Where-Object {$_.TaskName -like "*Microsoft*"} | Disable-ScheduledTask
   ```

3. **Check Task Paths:**
   ```powershell
   # Look for tasks in different paths
   Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\"
   ```

4. **Delete Tasks (Advanced):**
   ```powershell
   Unregister-ScheduledTask -TaskName "Microsoft Compatibility Appraiser" -Confirm:$false
   ```

**Prevention:** Use exact task names and paths from script.

---

### Issue: Registry Changes Not Applied

**Symptoms:**
- Bing search still enabled
- Advertising ID still active
- Copilot still available
- Settings revert after restart

**Causes:**
- Group Policy overriding registry
- Registry changes not taking effect
- User vs. machine policy conflicts
- Windows Update reverting changes

**Solutions:**

1. **Verify Registry Values:**
   ```powershell
   Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled"
   Get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy"
   ```

2. **Apply Group Policy Update:**
   ```cmd
   gpupdate /force /target:computer
   gpupdate /force /target:user
   ```

3. **Check for Policy Conflicts:**
   ```cmd
   gpresult /scope computer /r
   gpresult /scope user /r
   ```

4. **Restart Explorer:**
   ```powershell
   Stop-Process -Name explorer -Force
   Start-Process explorer
   ```

**Prevention:** Always run gpupdate and restart Explorer after deployment.

---

### Issue: System Performance Degraded

**Symptoms:**
- Slower boot times
- Higher CPU usage
- Increased memory usage
- General system sluggishness

**Causes:**
- Too many services disabled
- Critical system components affected
- Registry corruption
- Windows Update conflicts

**Solutions:**

1. **Check System Resources:**
   ```powershell
   Get-Counter '\Processor(_Total)\% Processor Time'
   Get-Counter '\Memory\Available MBytes'
   ```

2. **Review Disabled Services:**
   ```powershell
   Get-Service | Where-Object {$_.StartType -eq "Disabled"} | Select-Object Name, DisplayName
   ```

3. **Check Event Logs:**
   ```powershell
   Get-EventLog -LogName System -EntryType Error -Newest 10
   Get-EventLog -LogName Application -EntryType Error -Newest 10
   ```

4. **Restore System:**
   ```powershell
   # Use System Restore Point
   rstrui.exe

   # Or use restoration script
   .\business-debloat-restore.ps1 -RestoreAll
   ```

**Prevention:** Always create restore point before deployment.

---

## Edge Browser Issues

### Issue: Edge Still Opens on Links

**Symptoms:**
- Links still open in Edge despite Chrome default
- Edge shortcuts remain on desktop/taskbar
- Edge services still running

**Causes:**
- File associations not properly set
- Edge services not disabled
- Windows default app settings overridden

**Solutions:**

1. **Set Chrome as Default Manually:**
   ```powershell
   .\Set-ChromeDefaultBrowser.ps1
   ```

2. **Check File Associations:**
   ```powershell
   # Open Settings > Apps > Default apps
   # Set Chrome as default for web browser
   ```

3. **Remove Edge Shortcuts:**
   ```powershell
   Remove-Item "$env:PUBLIC\Desktop\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
   Remove-Item "$env:USERPROFILE\Desktop\Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
   ```

4. **Disable Edge Services:**
   ```powershell
   Set-Service MicrosoftEdgeElevationService -StartupType Disabled -Force
   Set-Service edgeupdate -StartupType Disabled -Force
   Set-Service edgeupdatem -StartupType Disabled -Force
   ```

**Prevention:** Run Set-ChromeDefaultBrowser.ps1 after deployment.

---

## Network and Connectivity Issues

### Issue: Script Can't Download Updates

**Symptoms:**
- Windows Update checks fail
- Microsoft Store connectivity issues
- Script hangs on update operations

**Causes:**
- Network proxy settings
- Firewall blocking connections
- DNS resolution issues
- Corporate network restrictions

**Solutions:**

1. **Check Network Connectivity:**
   ```powershell
   Test-NetConnection google.com -Port 80
   Test-NetConnection microsoft.com -Port 443
   ```

2. **Check Proxy Settings:**
   ```powershell
   Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | Select-Object ProxyServer, ProxyEnable
   ```

3. **Disable Proxy Temporarily:**
   ```powershell
   # Internet Options > Connections > LAN Settings
   # Uncheck "Use a proxy server for your LAN"
   ```

4. **Use Offline Mode:**
   ```powershell
   .\business-debloat.ps1 -DryRun
   # Remove network-dependent features
   ```

**Prevention:** Test network connectivity before deployment.

---

## Log Analysis and Debugging

### Enable Verbose Logging

```powershell
# Run with verbose logging
.\business-debloat.ps1 -Verbose

# Run restoration with verbose logging
.\business-debloat-restore.ps1 -RestoreAll -Verbose
```

### Analyze Log Files

**Check debloat-log.txt:**
```powershell
Get-Content "C:\temp\debloat-log.txt" | Select-String "ERROR" -Context 2
Get-Content "C:\temp\debloat-log.txt" | Select-String "WARN" -Context 2
```

**Check Event Logs:**
```powershell
# System events
Get-EventLog -LogName System -EntryType Error,Warning -Newest 20

# Application events
Get-EventLog -LogName Application -EntryType Error,Warning -Newest 20

# PowerShell events
Get-EventLog -LogName "Windows PowerShell" -Newest 10
```

### Debug Mode Operations

```powershell
# Test registry access
try {
    New-Item -Path "HKCU:\Software\DebloatTest" -Force
    Remove-Item -Path "HKCU:\Software\DebloatTest" -Force
    Write-Host "Registry access: OK"
} catch {
    Write-Host "Registry access: FAILED - $($_.Exception.Message)"
}

# Test service management
try {
    $testService = Get-Service "TermService"
    Write-Host "Service access: OK"
} catch {
    Write-Host "Service access: FAILED - $($_.Exception.Message)"
}

# Test app management
try {
    Get-AppxPackage -Name "*Microsoft*" | Select-Object -First 1 | Out-Null
    Write-Host "App management: OK"
} catch {
    Write-Host "App management: FAILED - $($_.Exception.Message)"
}
```

---

## Emergency Recovery

### System Won't Boot

**If Windows won't start after deployment:**

1. **Boot from Installation Media:**
   - Insert Windows 11 USB/installation media
   - Boot from USB (change boot order in BIOS)
   - Select "Repair your computer"

2. **Use Recovery Environment:**
   - Choose "Troubleshoot" > "Command Prompt"
   - Navigate to system drive: `C:`
   - Run restoration: `powershell -ExecutionPolicy Bypass -File C:\temp\business-debloat-restore.ps1 -RestoreAll`

### Complete System Recovery

**If all else fails:**

1. **Fresh Windows Reset:**
   - Boot from installation media
   - Choose "Install Windows"
   - Select "Keep my files" during setup
   - Windows will reinstall while preserving user data

2. **System Restore from Recovery:**
   - Boot from installation media
   - Choose "Troubleshoot" > "System Restore"
   - Select restore point from before deployment

---

## Prevention Best Practices

### Pre-Deployment Checklist

- [ ] Test on virtual machine first
- [ ] Create System Restore Point
- [ ] Backup important data
- [ ] Document current configuration
- [ ] Test network connectivity
- [ ] Verify administrator privileges
- [ ] Check execution policy
- [ ] Review hardware detection
- [ ] Confirm domain status

### Post-Deployment Monitoring

- [ ] Monitor system performance for 24 hours
- [ ] Check Event Viewer for errors
- [ ] Verify Windows Update functionality
- [ ] Test critical business applications
- [ ] Confirm user satisfaction

### Documentation and Support

- [ ] Keep deployment logs for 90 days
- [ ] Document any customizations made
- [ ] Note any issues encountered and resolutions
- [ ] Update contact information for users

---

## Common Error Codes and Meanings

| Error Code | Meaning | Resolution |
|------------|---------|------------|
| 0x80070005 | Access Denied | Run as Administrator |
| 0x80070002 | File Not Found | Verify file paths |
| 0x80070422 | Service Disabled | Enable service first |
| 0x80070643 | Installation Failed | Retry or skip component |
| 0x8024002E | Update Service Busy | Wait and retry |
| 0xC1900101 | Installation Failed | Check system requirements |

---

## Contact and Support

### Primary Support

**Business:** #MundyTuned  
**Email:** bryan@mundytuned.com  
**Repository:** https://github.com/QuicksandJesus/NextLevelDebloat

### Support Resources

- **This Guide:** Complete troubleshooting procedures
- **DEPLOYMENT.md:** Step-by-step deployment
- **RESTORATION.md:** Recovery procedures
- **README.md:** Quick reference

### Emergency Procedures

**For critical system issues:**
1. Document current symptoms and error messages
2. Attempt System Restore Point recovery
3. Use automated restoration script
4. Contact support with detailed logs

---

## Summary

NextLevelDebloat includes comprehensive error handling and troubleshooting capabilities:

- **Prevention:** Pre-deployment checks and validation
- **Detection:** Verbose logging and error reporting
- **Recovery:** Multiple restoration methods
- **Support:** Detailed documentation and contact information

**Always create a System Restore Point before deployment for easiest recovery.**

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-31  
**Status:** ✅ Complete

---

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com