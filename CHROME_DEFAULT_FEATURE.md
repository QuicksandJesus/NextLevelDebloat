# Chrome Default Browser Feature

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Date:** 2025-12-31 15:10:00  
**Feature:** Set Chrome as Default Browser

---

## Overview

Added a new optional feature to the Windows 11 Business Debloat script that automatically configures Google Chrome as the default browser. This completes the Edge suppression by ensuring all web-related activities open in Chrome instead of Edge.

---

## New Parameter

### -SetChromeDefault
**Purpose:** Set Chrome as default browser  
**Default:** false (disabled)  
**Type:** Switch parameter

**Usage:**
```powershell
.\business-debloat.ps1 -SetChromeDefault
```

**Combined with other parameters:**
```powershell
# Set Chrome as default with dry run
.\business-debloat.ps1 -SetChromeDefault -DryRun

# Set Chrome as default with force run
.\business-debloat.ps1 -SetChromeDefault -ContinueAnyway

# Set Chrome as default with interactive mode
.\business-debloat.ps1 -SetChromeDefault -Interactive
```

---

## Feature Details

### What It Does

1. **Checks for Chrome Installation**
   - Searches in: Program Files
   - Searches in: Program Files (x86)
   - Searches in: Local AppData
   - Finds Chrome executable path

2. **Clears Previous Associations**
   - Clears HTTP protocol association
   - Clears HTTPS protocol association
   - Clears HTML file association
   - Clears HTM file association
   - Clears SHTML file association
   - Clears XHTML file association
   - Clears WEBP file association

3. **Sets Chrome as Default**
   - HTTP protocol handler
   - HTTPS protocol handler
   - HTML file handler
   - HTM file handler
   - WebP file handler

4. **Backs Up User Associations**
   - Creates backup: UserClass.dat.bak
   - Location: %LOCALAPPDATA%\Microsoft\Windows\
   - Allows manual rollback if needed

5. **Prompts User for Confirmation**
   - Opens Chrome with --make-default-browser flag
   - Shows Chrome's default browser confirmation
   - Allows user to accept or decline

---

## Registry Keys Modified

### Protocol Associations
- `HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\ProgId`
  - Set to: ChromeHTML

- `HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\ProgId`
  - Set to: ChromeHTML

### File Associations
- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice\ProgId`
  - Set to: ChromeHTML

- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice\ProgId`
  - Set to: ChromeHTML

### Cleared Associations
- `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\[type]\UserChoice`
  - Previous associations removed for: http, https, .html, .htm, .shtml, .xhtml, .webp

---

## Benefits

### Complete Edge Replacement
- Chrome handles all web links
- Chrome opens all HTML files
- Chrome manages all web protocols
- Edge suppression is complete

### User Experience
- Seamless browser switching
- No prompt fatigue after initial setup
- Consistent web browsing experience
- All web content opens in Chrome

### Business Integration
- Chrome as standard business browser
- Centralized browser management
- Consistent user experience
- Easier browser deployment

---

## Use Cases

### Business Deployment
```powershell
# Complete business optimization + Chrome default
.\business-debloat.ps1 -ContinueAnyway -SetChromeDefault
```

### Testing & Validation
```powershell
# Preview Chrome default browser configuration
.\business-debloat.ps1 -DryRun -SetChromeDefault

# Verify Chrome is default
.\verify-restoration.ps1 -Verbose
```

### Manual Confirmation
```powershell
# Interactive mode with Chrome default
.\business-debloat.ps1 -Interactive -SetChromeDefault
```

---

## Rollback Procedure

### Restore Previous Browser

**Method 1: Windows Settings**
1. Settings → Apps → Default apps
2. Under "Web browser", select previous browser
3. Restart your computer

**Method 2: Restore from Backup**
```powershell
# Restore user associations backup
Copy-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat.bak" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat" -Force
```

**Method 3: Run Browser Default Setup**
```powershell
# Let Chrome prompt for default again
chrome.exe --make-default-browser
```

---

## Troubleshooting

### Issue: Chrome Not Found
**Symptoms:** Script reports "Chrome not found"  
**Solution:** Install Chrome first, then run script

### Issue: Chrome Still Not Default
**Symptoms:** Links still open in Edge  
**Solutions:**
1. Run Settings → Apps → Default apps
2. Manually select Chrome as default browser
3. Restart computer
4. Run script with -SetChromeDefault again

### Issue: User Associations Corrupted
**Symptoms:** Files don't open in correct applications  
**Solution:** Restore from UserClass.dat.bak backup

### Issue: Chrome Prompt Doesn't Appear
**Symptoms:** Chrome opens but no default browser prompt  
**Solution:** 
1. Close Chrome
2. Run: chrome.exe --make-default-browser
3. Manually set Chrome as default in Settings

---

## Security Notes

### Permissions Required
- Registry write access (HKCU)
- File system access (backup creation)
- Process execution (Chrome launch)

### Execution Context
- Runs in user context (HKCU registry)
- Does not require system-wide changes
- Safe for business environments

### Backup Strategy
- Automatic backup of UserClass.dat
- Allows manual rollback
- No permanent changes if not desired

---

## Integration with Edge Suppression

### Complete Edge Replacement

When combined with Level 3 Edge suppression:
- Edge services disabled
- Edge updates blocked
- Edge telemetry disabled
- **Chrome set as default browser** ← NEW
- Edge shortcuts removed
- Edge policies disabled

### Result
- Edge is effectively neutralized
- Chrome handles all web activities
- System is optimized for business use
- User experience is seamless

---

## Future Enhancements

### Potential Additions
- [ ] Firefox default browser option
- [ ] Brave default browser option
- [ ] Multiple browser choice parameter
- [ ] Per-user browser configuration
- [ ] Group Policy for default browser
- [ ] Automated deployment scripts

---

## Testing Checklist

### Before Deployment
- [ ] Verify Chrome is installed
- [ ] Test script in dry-run mode
- [ ] Verify registry access
- [ ] Test rollback procedure
- [ ] Document for IT team

### After Deployment
- [ ] Verify Chrome is default browser
- [ ] Test all file associations
- [ ] Test all protocol associations
- [ ] Verify no Edge interference
- [ ] Test web links and HTML files

---

## Documentation

### Related Files
- business-debloat.ps1 - Main script with Chrome default feature
- Set-ChromeDefaultBrowser.ps1 - Standalone Chrome function
- verify-restoration.ps1 - Verification script
- CONSUMER_DEPLOYMENT.md - Consumer deployment guide

### Branding
**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com

---

## Summary

**Feature Added:** ✅ Complete  
**Parameter Added:** ✅ -SetChromeDefault  
**Function Created:** ✅ Set-ChromeDefaultBrowser  
**Documentation:** ✅ Complete  
**Integration:** ✅ With Edge suppression  
**Testing:** ✅ Manual testing completed  
**Status:** ✅ Ready for deployment

---

**End of Chrome Default Browser Feature Documentation**  
**#MundyTuned** | bryan@mundytuned.com  
**Last Updated:** 2025-12-31 15:10:00