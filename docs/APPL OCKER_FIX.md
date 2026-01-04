# #MundyTuned AppLocker Fix
**bryan@mundytuned.com**

## Goal
Block msedge.exe only (x86/64). Explicit allow %OSDRIVE%\*. Auto-launch Chrome for westcheckin1 on login.

## Plan
1. AppLocker XML: Allow %OSDRIVE%\*, Deny msedge paths (Everyone).
2. Scheduled Task: Chrome --profile-directory=Default for westcheckin1 logon.
3. Rollback: Clear policy, delete task, restore snapshot.

## Rollback Steps
1. Safe Mode: Set-AppLockerPolicy -XmlPolicy clear.xml
2. sc config AppIDSvc start=3; sc start AppIDSvc
3. Unregister-ScheduledTask "#MundyTuned-ChromeLaunch-westcheckin1" -User westcheckin1
4. tar -xzf snapshots/latest.tar.gz; reboot

© #MundyTuned 2026
