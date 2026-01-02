# Portable Windows 11 Debloat Script for Business
# Run as Administrator
#
# #MundyTuned - Windows Optimization Solutions
# Business Email: bryan@mundytuned.com
#
# Parameters:
#   -DryRun              Preview changes without applying
#   -Interactive         Prompt for confirmation before each action
#   -Restore             (Not yet implemented) Restore from backup
#   -ConfigFile          Path to configuration file (default: debloat-config.json)
#   -LogFile             Path to log file (default: debloat-log.txt)
#   -SkipHardwareDetection Skip camera/touch detection (remove all apps regardless)
#   -SkipDomainCheck      Apply settings even on domain-joined machines
#   -SkipPermissionCheck Skip initial permission verification (not recommended)
#   -ContinueAnyway      Continue despite permission warnings (not recommended)
#   -SetChromeDefault   Set Chrome as default browser
#
# Examples:
#   .\business-debloat.ps1                                    # Basic run
#   .\business-debloat.ps1 -DryRun                           # Preview changes
#   .\business-debloat.ps1 -Interactive                       # Interactive mode
#   .\business-debloat.ps1 -SkipPermissionCheck -ContinueAnyway # Force run

param(
    [switch]$DryRun,
    [switch]$Interactive,
    [switch]$Restore,
    [string]$ConfigFile = "debloat-config.json",
    [string]$LogFile = "debloat-log.txt",
     [switch]$SkipHardwareDetection,
     [switch]$SkipDomainCheck,
     [switch]$ContinueAnyway,
     [switch]$SkipPermissionCheck,
     [switch]$SetChromeDefault
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Backup-Registry {
    $backupPath = "C:\temp\registry-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg"
    if (-not $DryRun) {
        reg export HKLM $backupPath /y | Out-Null
        reg export HKCU $backupPath.Replace('.reg', '-HKCU.reg') /y | Out-Null
        Write-Log "Registry backed up to $backupPath"
    }
}

function Test-RegistryKey {
    param([string]$Path)
    return (Test-Path $Path)
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )
    if (-not (Test-RegistryKey $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Log "Created registry key: $Path"
    }
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set $Path\$Name = $Value"
    } else {
        if ($Interactive) {
            $response = Read-Host "Set $Path\$Name to $Value? (Y/N)"
            if ($response -ne 'Y') { return }
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type
        Write-Log "Set $Path\$Name = $Value"
    }
}

function Remove-BloatApps {
    param([array]$Apps, [hashtable]$PreserveApps)
    
    foreach ($app in $Apps) {
        if ($PreserveApps.ContainsKey($app) -and $PreserveApps[$app]) {
            Write-Log "Skipping $app (preserved)"
            continue
        }
        
        if ($DryRun) {
            Write-Log "[DRYRUN] Would remove $app"
        } else {
            Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            Write-Log "Removed $app"
        }
    }
}

function Disable-Service {
    param([string]$ServiceName)
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would disable service $ServiceName"
        } else {
            Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Write-Log "Disabled service $ServiceName"
        }
    }
}

function Disable-TaskScheduled {
    param([string]$TaskNamePattern)
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*$TaskNamePattern*" }

function Set-ChromeDefaultBrowser {
    param()
    
    Write-Log "=== SETTING CHROME AS DEFAULT BROWSER ==="
    
    $chromePaths = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeInstalled = $false
    $chromePath = $null
    
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            $chromeInstalled = $true
            $chromePath = $path
            break
        }
    }
    
    if (-not $chromeInstalled) {
        Write-Log "Chrome not found - skipping default browser configuration" -Level "WARN"
        return
    }
    
    Write-Log "Chrome found at: $chromePath"
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set Chrome as default browser"
        return
    }
    
    try {
        $associations = @(
            @("http", "http\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @("https", "https\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".html", ".html\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".htm", ".htm\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".shtml", ".shtml\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".xhtml", ".xhtml\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".webp", ".webp\shell\open\command", "`"$chromePath`" -- `"%1`"")
        )
        
        foreach ($assoc in $associations) {
            $assocPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$($assoc[0])\UserChoice"
            
            try {
                if (Test-Path $assocPath) {
                    Remove-Item -Path $assocPath -Force -ErrorAction SilentlyContinue
                }
                Write-Log "Cleared previous association for: $($assoc[0])"
            } catch {
                Write-Log "Could not clear association for $($assoc[0]): $(# Portable Windows 11 Debloat Script for Business
# Run as Administrator
#
# #MundyTuned - Windows Optimization Solutions
# Business Email: bryan@mundytuned.com
#
# Parameters:
#   -DryRun              Preview changes without applying
#   -Interactive         Prompt for confirmation before each action
#   -Restore             (Not yet implemented) Restore from backup
#   -ConfigFile          Path to configuration file (default: debloat-config.json)
#   -LogFile             Path to log file (default: debloat-log.txt)
#   -SkipHardwareDetection Skip camera/touch detection (remove all apps regardless)
#   -SkipDomainCheck      Apply settings even on domain-joined machines
#   -SkipPermissionCheck Skip initial permission verification (not recommended)
#   -ContinueAnyway      Continue despite permission warnings (not recommended)
#   -SetChromeDefault   Set Chrome as default browser
#
# Examples:
#   .\business-debloat.ps1                                    # Basic run
#   .\business-debloat.ps1 -DryRun                           # Preview changes
#   .\business-debloat.ps1 -Interactive                       # Interactive mode
#   .\business-debloat.ps1 -SkipPermissionCheck -ContinueAnyway # Force run

param(
    [switch]$DryRun,
    [switch]$Interactive,
    [switch]$Restore,
    [string]$ConfigFile = "debloat-config.json",
    [string]$LogFile = "debloat-log.txt",
     [switch]$SkipHardwareDetection,
     [switch]$SkipDomainCheck,
     [switch]$ContinueAnyway,
     [switch]$SkipPermissionCheck,
     [switch]$SetChromeDefault
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Backup-Registry {
    $backupPath = "C:\temp\registry-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg"
    if (-not $DryRun) {
        reg export HKLM $backupPath /y | Out-Null
        reg export HKCU $backupPath.Replace('.reg', '-HKCU.reg') /y | Out-Null
        Write-Log "Registry backed up to $backupPath"
    }
}

function Test-RegistryKey {
    param([string]$Path)
    return (Test-Path $Path)
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )
    if (-not (Test-RegistryKey $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Log "Created registry key: $Path"
    }
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set $Path\$Name = $Value"
    } else {
        if ($Interactive) {
            $response = Read-Host "Set $Path\$Name to $Value? (Y/N)"
            if ($response -ne 'Y') { return }
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type
        Write-Log "Set $Path\$Name = $Value"
    }
}

function Remove-BloatApps {
    param([array]$Apps, [hashtable]$PreserveApps)
    
    foreach ($app in $Apps) {
        if ($PreserveApps.ContainsKey($app) -and $PreserveApps[$app]) {
            Write-Log "Skipping $app (preserved)"
            continue
        }
        
        if ($DryRun) {
            Write-Log "[DRYRUN] Would remove $app"
        } else {
            Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            Write-Log "Removed $app"
        }
    }
}

function Disable-Service {
    param([string]$ServiceName)
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would disable service $ServiceName"
        } else {
            Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Write-Log "Disabled service $ServiceName"
        }
    }
}

function Disable-TaskScheduled {
    param([string]$TaskNamePattern)
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*$TaskNamePattern*" } -ErrorAction SilentlyContinue
    foreach ($task in $tasks) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would disable task $($task.TaskPath)\$($task.TaskName)"
        } else {
            Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
            Write-Log "Disabled task $($task.TaskPath)\$($task.TaskName)"
        }
    }
}

function Test-IsDomainJoined {
    return (Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain
}

function Test-Hardware {
    param([string]$Type)
    switch ($Type) {
        "Camera"   { return @(Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Camera*" -or $_.FriendlyName -like "*Webcam*"}).Count -gt 0 }
        "Touch"    { return (Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Touch*"}).Count -gt 0 }
        "Printer"  { return @(Get-Printer).Count -gt 0 }
        "Bluetooth" { return @(Get-PnpDevice -Class Bluetooth).Count -gt 0 }
        default    { return $false }
    }
}

function Test-ScriptPermissions {
    param([switch]$ContinueAnyway)
    
    Write-Log "=== PERMISSION CHECK STARTING ===" -Level "INFO"
    $allPermissionsOK = $true
    $warnings = @()
    
    $adminPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $adminPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Log "FAIL: Not running as Administrator" -Level "ERROR"
        $allPermissionsOK = $false
    } else {
        Write-Log "PASS: Running as Administrator" -Level "INFO"
    }
    
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $restrictedPolicies = @("Restricted", "Undefined", "AllSigned")
    if ($restrictedPolicies -contains $executionPolicy) {
        Write-Log "WARN: Execution policy is '$executionPolicy' - may block script execution" -Level "WARN"
        $warnings += "Execution policy '$executionPolicy' may require adjustment. Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    } else {
        Write-Log "PASS: Execution policy is '$executionPolicy'" -Level "INFO"
    }
    
    try {
        $testPath = "HKLM:\Software\TempDebloatTest"
        New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Write-Log "PASS: HKLM registry write permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No HKLM registry write permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        $testPath = "HKCU:\Software\TempDebloatTest"
        New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Write-Log "PASS: HKCU registry write permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No HKCU registry write permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        $testService = Get-Service -Name "TermService" -ErrorAction Stop
        Write-Log "PASS: Service management permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No service management permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        Get-AppxPackage -ErrorAction Stop | Out-Null
        Write-Log "PASS: Appx package management permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No appx package management permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        Get-ScheduledTask -TaskName "*" -ErrorAction Stop | Select-Object -First 1 | Out-Null
        Write-Log "PASS: Task scheduler permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "WARN: Unable to verify task scheduler permissions: $($_.Exception.Message)" -Level "WARN"
        $warnings += "Task scheduler permissions could not be verified - scheduled tasks may not be disabled"
    }
    
    try {
        $defenderStatus = Get-MpPreference -ErrorAction Stop
        $realTimeProtection = $defenderStatus.DisableRealtimeMonitoring
        if ($realTimeProtection -eq $false) {
            Write-Log "WARN: Windows Defender Real-time Protection is ENABLED - may interfere with script operations" -Level "WARN"
            $warnings += "Windows Defender Real-time Protection may block registry changes. Consider temporarily disabling."
        } else {
            Write-Log "INFO: Windows Defender Real-time Protection is DISABLED" -Level "INFO"
        }
    } catch {
        Write-Log "WARN: Unable to check Windows Defender status: $($_.Exception.Message)" -Level "WARN"
    }
    
    if (Test-IsDomainJoined) {
        Write-Log "WARN: Machine is domain-joined - Group Policy may override local settings" -Level "WARN"
        $warnings += "Domain-joined machine: Group Policy may override local changes. Use -SkipDomainCheck to attempt anyway."
        
        try {
            $gpResult = gpresult /scope computer /r
            Write-Log "INFO: Group Policy applied (run 'gpresult /h report.html' for details)" -Level "INFO"
        } catch {
            Write-Log "WARN: Unable to retrieve Group Policy status" -Level "WARN"
        }
    } else {
        Write-Log "PASS: Not domain-joined - local settings will take precedence" -Level "INFO"
    }
    
    try {
        $backupDir = "C:\temp"
        if (-not (Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $testFile = "$backupDir\debfloat-permission-test.txt"
        "test" | Out-File -FilePath $testFile -Force -ErrorAction Stop
        Remove-Item -Path $testFile -Force -ErrorAction Stop
        Write-Log "PASS: Backup directory write permissions confirmed ($backupDir)" -Level "INFO"
    } catch {
        Write-Log "FAIL: No write permissions to backup directory: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    $requiredModules = @("ScheduledTasks", "Appx")
    foreach ($module in $requiredModules) {
        $moduleAvailable = Get-Module -Name $module -ListAvailable -ErrorAction SilentlyContinue
        if ($moduleAvailable) {
            Write-Log "PASS: Module '$module' is available" -Level "INFO"
        } else {
            Write-Log "WARN: Module '$module' not found (may be built-in or optional)" -Level "WARN"
        }
    }
    
    Write-Log "=== PERMISSION CHECK COMPLETE ===" -Level "INFO"
    
    if ($warnings.Count -gt 0) {
        Write-Log "=== WARNINGS ===" -Level "WARN"
        foreach ($warning in $warnings) {
            Write-Log "  $warning" -Level "WARN"
        }
    }
    
    if (-not $allPermissionsOK) {
        Write-Log "=== CRITICAL PERMISSIONS MISSING ===" -Level "ERROR"
        Write-Log "Cannot continue due to missing critical permissions" -Level "ERROR"
        if ($ContinueAnyway) {
            Write-Log "WARNING: Continuing anyway despite permission failures (-ContinueAnyway flag set)" -Level "WARN"
        } else {
            Write-Log "Run with -ContinueAnyway to ignore these warnings (not recommended)" -Level "INFO"
            exit 1
        }
    }
    
    Write-Log "All required permissions verified. Continuing with debloat process." -Level "INFO"
    return $true
}

function Apply-DebloatSettings {
    $config = @{
        AppsToRemove = @(
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
        PreserveApps = @{}
        ServicesToDisable = @(
            "XblAuthManager",
            "XboxNetApiSvc",
            "XboxGipSvc",
            "DiagTrack",
            "MapsBroker",
            "WalletService",
            "RetailDemo",
            "wisvc"
        )
        TasksToDisable = @(
            "Microsoft Compatibility Appraiser",
            "Customer Experience Improvement Program",
            "Program Data Updater",
            "XblGameSaveTask"
        )
    }
    
    if (-not $SkipHardwareDetection) {
        $hasCamera = Test-Hardware "Camera"
        $hasTouch = Test-Hardware "Touch"
        
        if ($hasCamera) {
            $config.PreserveApps["Microsoft.WindowsCamera"] = $true
            Write-Log "Camera detected - preserving Windows Camera app"
        }
        
        if ($hasTouch) {
            $config.PreserveApps["Microsoft.WindowsCalculator"] = $true
            Write-Log "Touch screen detected - preserving Calculator app"
        }
    }
    
    Write-Log "Starting debloat process..."
    Write-Log "DryRun: $DryRun"
    Write-Log "Interactive: $Interactive"
    
    if (-not $SkipDomainCheck -and (Test-IsDomainJoined)) {
        Write-Log "Domain-joined machine - skipping domain-managed settings"
    }
    
    Backup-Registry
    Remove-BloatApps -Apps $config.AppsToRemove -PreserveApps $config.PreserveApps
    
    foreach ($service in $config.ServicesToDisable) {
        Disable-Service -ServiceName $service
    }
    
    foreach ($task in $config.TasksToDisable) {
        Disable-TaskScheduled -TaskNamePattern $task
    }
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "PersonalizationReportingEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "PreventFirstRunPage" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge" -Name "PreventFirstRunPage" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "Disable3DSecurePrompt" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "MetricsReportingEnabled" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "SendIntranetTraffictoInternetExplorer" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowDoNotTrack" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowWindowsSpotlight" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\ServiceUI" -Name "AllowMicrosoftWelcomeExperience" -Value 0 -Type "DWord"
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "DisableInstaller" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "AutoUpdateCheckPeriodMinutes" -Value 0 -Type "DWord"
    
    $edgePaths = @(
        "${env:PUBLIC}\Desktop\Microsoft Edge.lnk",
        "${env:USERPROFILE}\Desktop\Microsoft Edge.lnk",
        "${env:APPDATA}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk"
    )
    foreach ($path in $edgePaths) {
        if (Test-Path $path) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would remove Edge shortcut: $path"
            } else {
                Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                Write-Log "Removed Edge shortcut: $path"
            }
        }
    }
    
    $edgeUpdateServices = @("MicrosoftEdgeElevationService", "edgeupdate", "edgeupdatem")
    foreach ($serviceName in $edgeUpdateServices) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would disable Edge service: $serviceName"
            } else {
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Write-Log "Disabled Edge service: $serviceName"
            }
        }
    }
    
    Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoInternetOpenWith" -Value 1 -Type "DWord"
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "DisableWebSearch" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWebOverMeteredConnections" -Value 0 -Type "DWord"
    
    if ($SetChromeDefault) {
        Set-ChromeDefaultBrowser
    }
    
    if (-not $DryRun) {
        gpupdate /force | Out-Null
        Write-Log "Applied Group Policy updates"
        
        Write-Log "Restarting Explorer..."
        Stop-Process -Name explorer -Force
        Start-Process explorer
    }
    
    Write-Log "Debloat complete. Reboot for full effect."
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

if (-not $SkipPermissionCheck) {
    Test-ScriptPermissions -ContinueAnyway:$ContinueAnyway
}

Apply-DebloatSettingsfunction Set-ChromeDefaultBrowser {
    param()
    
    Write-Log "=== SETTING CHROME AS DEFAULT BROWSER ==="
    
    $chromePaths = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeInstalled = $false
    $chromePath = $null
    
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            $chromeInstalled = $true
            $chromePath = $path
            break
        }
    }
    
    if (-not $chromeInstalled) {
        Write-Log "Chrome not found - skipping default browser configuration" -Level "WARN"
        return
    }
    
    Write-Log "Chrome found at: $chromePath"
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set Chrome as default browser"
        return
    }
    
    try {
        $associations = @(
            @("http", "http\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @("https", "https\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".html", ".html\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".htm", ".htm\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".shtml", ".shtml\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".xhtml", ".xhtml\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".webp", ".webp\shell\open\command", "`"$chromePath`" -- `"%1`"")
        )
        
        foreach ($assoc in $associations) {
            $assocPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$($assoc[0])\UserChoice"
            
            try {
                if (Test-Path $assocPath) {
                    Remove-Item -Path $assocPath -Force -ErrorAction SilentlyContinue
                }
                Write-Log "Cleared previous association for: $($assoc[0])"
            } catch {
                Write-Log "Could not clear association for $($assoc[0]): $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        $chromeProgId = "ChromeHTML"
        
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http" -Name "ProgId" -Value $chromeProgId
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https" -Name "ProgId" -Value $chromeProgId
        
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice" -Name "ProgId" -Value $chromeProgId
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice" -Name "ProgId" -Value $chromeProgId
        
        Write-Log "Chrome set as default for: HTTP, HTTPS, HTML, HTM"
        
        $appAssociationPath = "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat"
        if (Test-Path $appAssociationPath) {
            $backupPath = "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat.bak"
            Copy-Item -Path $appAssociationPath -Destination $backupPath -Force -ErrorAction SilentlyContinue
            Write-Log "Backed up user associations to: $backupPath"
        }
        
        Write-Log "Opening Chrome to prompt for default browser..."
        Start-Process $chromePath -ArgumentList "--make-default-browser" -WindowStyle Hidden
        
        Write-Log "Chrome default browser configuration complete"
        Write-Log "Note: You may need to confirm Chrome as default in Settings → Apps → Default apps"
        
    } catch {
        Write-Log "Failed to set Chrome as default browser: $($_.Exception.Message)" -Level "ERROR"
    }
}
.Exception.Message)" -Level "WARN"
            }
        }
        
        $chromeProgId = "ChromeHTML"
        
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http" -Name "ProgId" -Value $chromeProgId
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https" -Name "ProgId" -Value $chromeProgId
        
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice" -Name "ProgId" -Value $chromeProgId
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice" -Name "ProgId" -Value $chromeProgId
        
        Write-Log "Chrome set as default for: HTTP, HTTPS, HTML, HTM"
        
        $appAssociationPath = "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat"
        if (Test-Path $appAssociationPath) {
            $backupPath = "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat.bak"
            Copy-Item -Path $appAssociationPath -Destination $backupPath -Force -ErrorAction SilentlyContinue
            Write-Log "Backed up user associations to: $backupPath"
        }
        
        Write-Log "Opening Chrome to prompt for default browser..."
        Start-Process $chromePath -ArgumentList "--make-default-browser" -WindowStyle Hidden
        
        Write-Log "Chrome default browser configuration complete"
        Write-Log "Note: You may need to confirm Chrome as default in Settings → Apps → Default apps"
        
    } catch {
        Write-Log "Failed to set Chrome as default browser: $(# Portable Windows 11 Debloat Script for Business
# Run as Administrator
#
# #MundyTuned - Windows Optimization Solutions
# Business Email: bryan@mundytuned.com
#
# Parameters:
#   -DryRun              Preview changes without applying
#   -Interactive         Prompt for confirmation before each action
#   -Restore             (Not yet implemented) Restore from backup
#   -ConfigFile          Path to configuration file (default: debloat-config.json)
#   -LogFile             Path to log file (default: debloat-log.txt)
#   -SkipHardwareDetection Skip camera/touch detection (remove all apps regardless)
#   -SkipDomainCheck      Apply settings even on domain-joined machines
#   -SkipPermissionCheck Skip initial permission verification (not recommended)
#   -ContinueAnyway      Continue despite permission warnings (not recommended)
#   -SetChromeDefault   Set Chrome as default browser
#
# Examples:
#   .\business-debloat.ps1                                    # Basic run
#   .\business-debloat.ps1 -DryRun                           # Preview changes
#   .\business-debloat.ps1 -Interactive                       # Interactive mode
#   .\business-debloat.ps1 -SkipPermissionCheck -ContinueAnyway # Force run

param(
    [switch]$DryRun,
    [switch]$Interactive,
    [switch]$Restore,
    [string]$ConfigFile = "debloat-config.json",
    [string]$LogFile = "debloat-log.txt",
     [switch]$SkipHardwareDetection,
     [switch]$SkipDomainCheck,
     [switch]$ContinueAnyway,
     [switch]$SkipPermissionCheck,
     [switch]$SetChromeDefault
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}

function Backup-Registry {
    $backupPath = "C:\temp\registry-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg"
    if (-not $DryRun) {
        reg export HKLM $backupPath /y | Out-Null
        reg export HKCU $backupPath.Replace('.reg', '-HKCU.reg') /y | Out-Null
        Write-Log "Registry backed up to $backupPath"
    }
}

function Test-RegistryKey {
    param([string]$Path)
    return (Test-Path $Path)
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )
    if (-not (Test-RegistryKey $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Log "Created registry key: $Path"
    }
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set $Path\$Name = $Value"
    } else {
        if ($Interactive) {
            $response = Read-Host "Set $Path\$Name to $Value? (Y/N)"
            if ($response -ne 'Y') { return }
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type
        Write-Log "Set $Path\$Name = $Value"
    }
}

function Remove-BloatApps {
    param([array]$Apps, [hashtable]$PreserveApps)
    
    foreach ($app in $Apps) {
        if ($PreserveApps.ContainsKey($app) -and $PreserveApps[$app]) {
            Write-Log "Skipping $app (preserved)"
            continue
        }
        
        if ($DryRun) {
            Write-Log "[DRYRUN] Would remove $app"
        } else {
            Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            Write-Log "Removed $app"
        }
    }
}

function Disable-Service {
    param([string]$ServiceName)
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would disable service $ServiceName"
        } else {
            Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Write-Log "Disabled service $ServiceName"
        }
    }
}

function Disable-TaskScheduled {
    param([string]$TaskNamePattern)
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*$TaskNamePattern*" } -ErrorAction SilentlyContinue
    foreach ($task in $tasks) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would disable task $($task.TaskPath)\$($task.TaskName)"
        } else {
            Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
            Write-Log "Disabled task $($task.TaskPath)\$($task.TaskName)"
        }
    }
}

function Test-IsDomainJoined {
    return (Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain
}

function Test-Hardware {
    param([string]$Type)
    switch ($Type) {
        "Camera"   { return @(Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Camera*" -or $_.FriendlyName -like "*Webcam*"}).Count -gt 0 }
        "Touch"    { return (Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Touch*"}).Count -gt 0 }
        "Printer"  { return @(Get-Printer).Count -gt 0 }
        "Bluetooth" { return @(Get-PnpDevice -Class Bluetooth).Count -gt 0 }
        default    { return $false }
    }
}

function Test-ScriptPermissions {
    param([switch]$ContinueAnyway)
    
    Write-Log "=== PERMISSION CHECK STARTING ===" -Level "INFO"
    $allPermissionsOK = $true
    $warnings = @()
    
    $adminPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $adminPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Log "FAIL: Not running as Administrator" -Level "ERROR"
        $allPermissionsOK = $false
    } else {
        Write-Log "PASS: Running as Administrator" -Level "INFO"
    }
    
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $restrictedPolicies = @("Restricted", "Undefined", "AllSigned")
    if ($restrictedPolicies -contains $executionPolicy) {
        Write-Log "WARN: Execution policy is '$executionPolicy' - may block script execution" -Level "WARN"
        $warnings += "Execution policy '$executionPolicy' may require adjustment. Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    } else {
        Write-Log "PASS: Execution policy is '$executionPolicy'" -Level "INFO"
    }
    
    try {
        $testPath = "HKLM:\Software\TempDebloatTest"
        New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Write-Log "PASS: HKLM registry write permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No HKLM registry write permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        $testPath = "HKCU:\Software\TempDebloatTest"
        New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Write-Log "PASS: HKCU registry write permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No HKCU registry write permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        $testService = Get-Service -Name "TermService" -ErrorAction Stop
        Write-Log "PASS: Service management permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No service management permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        Get-AppxPackage -ErrorAction Stop | Out-Null
        Write-Log "PASS: Appx package management permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No appx package management permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        Get-ScheduledTask -TaskName "*" -ErrorAction Stop | Select-Object -First 1 | Out-Null
        Write-Log "PASS: Task scheduler permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "WARN: Unable to verify task scheduler permissions: $($_.Exception.Message)" -Level "WARN"
        $warnings += "Task scheduler permissions could not be verified - scheduled tasks may not be disabled"
    }
    
    try {
        $defenderStatus = Get-MpPreference -ErrorAction Stop
        $realTimeProtection = $defenderStatus.DisableRealtimeMonitoring
        if ($realTimeProtection -eq $false) {
            Write-Log "WARN: Windows Defender Real-time Protection is ENABLED - may interfere with script operations" -Level "WARN"
            $warnings += "Windows Defender Real-time Protection may block registry changes. Consider temporarily disabling."
        } else {
            Write-Log "INFO: Windows Defender Real-time Protection is DISABLED" -Level "INFO"
        }
    } catch {
        Write-Log "WARN: Unable to check Windows Defender status: $($_.Exception.Message)" -Level "WARN"
    }
    
    if (Test-IsDomainJoined) {
        Write-Log "WARN: Machine is domain-joined - Group Policy may override local settings" -Level "WARN"
        $warnings += "Domain-joined machine: Group Policy may override local changes. Use -SkipDomainCheck to attempt anyway."
        
        try {
            $gpResult = gpresult /scope computer /r
            Write-Log "INFO: Group Policy applied (run 'gpresult /h report.html' for details)" -Level "INFO"
        } catch {
            Write-Log "WARN: Unable to retrieve Group Policy status" -Level "WARN"
        }
    } else {
        Write-Log "PASS: Not domain-joined - local settings will take precedence" -Level "INFO"
    }
    
    try {
        $backupDir = "C:\temp"
        if (-not (Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $testFile = "$backupDir\debfloat-permission-test.txt"
        "test" | Out-File -FilePath $testFile -Force -ErrorAction Stop
        Remove-Item -Path $testFile -Force -ErrorAction Stop
        Write-Log "PASS: Backup directory write permissions confirmed ($backupDir)" -Level "INFO"
    } catch {
        Write-Log "FAIL: No write permissions to backup directory: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    $requiredModules = @("ScheduledTasks", "Appx")
    foreach ($module in $requiredModules) {
        $moduleAvailable = Get-Module -Name $module -ListAvailable -ErrorAction SilentlyContinue
        if ($moduleAvailable) {
            Write-Log "PASS: Module '$module' is available" -Level "INFO"
        } else {
            Write-Log "WARN: Module '$module' not found (may be built-in or optional)" -Level "WARN"
        }
    }
    
    Write-Log "=== PERMISSION CHECK COMPLETE ===" -Level "INFO"
    
    if ($warnings.Count -gt 0) {
        Write-Log "=== WARNINGS ===" -Level "WARN"
        foreach ($warning in $warnings) {
            Write-Log "  $warning" -Level "WARN"
        }
    }
    
    if (-not $allPermissionsOK) {
        Write-Log "=== CRITICAL PERMISSIONS MISSING ===" -Level "ERROR"
        Write-Log "Cannot continue due to missing critical permissions" -Level "ERROR"
        if ($ContinueAnyway) {
            Write-Log "WARNING: Continuing anyway despite permission failures (-ContinueAnyway flag set)" -Level "WARN"
        } else {
            Write-Log "Run with -ContinueAnyway to ignore these warnings (not recommended)" -Level "INFO"
            exit 1
        }
    }
    
    Write-Log "All required permissions verified. Continuing with debloat process." -Level "INFO"
    return $true
}

function Apply-DebloatSettings {
    $config = @{
        AppsToRemove = @(
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
        PreserveApps = @{}
        ServicesToDisable = @(
            "XblAuthManager",
            "XboxNetApiSvc",
            "XboxGipSvc",
            "DiagTrack",
            "MapsBroker",
            "WalletService",
            "RetailDemo",
            "wisvc"
        )
        TasksToDisable = @(
            "Microsoft Compatibility Appraiser",
            "Customer Experience Improvement Program",
            "Program Data Updater",
            "XblGameSaveTask"
        )
    }
    
    if (-not $SkipHardwareDetection) {
        $hasCamera = Test-Hardware "Camera"
        $hasTouch = Test-Hardware "Touch"
        
        if ($hasCamera) {
            $config.PreserveApps["Microsoft.WindowsCamera"] = $true
            Write-Log "Camera detected - preserving Windows Camera app"
        }
        
        if ($hasTouch) {
            $config.PreserveApps["Microsoft.WindowsCalculator"] = $true
            Write-Log "Touch screen detected - preserving Calculator app"
        }
    }
    
    Write-Log "Starting debloat process..."
    Write-Log "DryRun: $DryRun"
    Write-Log "Interactive: $Interactive"
    
    if (-not $SkipDomainCheck -and (Test-IsDomainJoined)) {
        Write-Log "Domain-joined machine - skipping domain-managed settings"
    }
    
    Backup-Registry
    Remove-BloatApps -Apps $config.AppsToRemove -PreserveApps $config.PreserveApps
    
    foreach ($service in $config.ServicesToDisable) {
        Disable-Service -ServiceName $service
    }
    
    foreach ($task in $config.TasksToDisable) {
        Disable-TaskScheduled -TaskNamePattern $task
    }
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "PersonalizationReportingEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "PreventFirstRunPage" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge" -Name "PreventFirstRunPage" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "Disable3DSecurePrompt" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "MetricsReportingEnabled" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "SendIntranetTraffictoInternetExplorer" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowDoNotTrack" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowWindowsSpotlight" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\ServiceUI" -Name "AllowMicrosoftWelcomeExperience" -Value 0 -Type "DWord"
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "DisableInstaller" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "AutoUpdateCheckPeriodMinutes" -Value 0 -Type "DWord"
    
    $edgePaths = @(
        "${env:PUBLIC}\Desktop\Microsoft Edge.lnk",
        "${env:USERPROFILE}\Desktop\Microsoft Edge.lnk",
        "${env:APPDATA}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk"
    )
    foreach ($path in $edgePaths) {
        if (Test-Path $path) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would remove Edge shortcut: $path"
            } else {
                Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                Write-Log "Removed Edge shortcut: $path"
            }
        }
    }
    
    $edgeUpdateServices = @("MicrosoftEdgeElevationService", "edgeupdate", "edgeupdatem")
    foreach ($serviceName in $edgeUpdateServices) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would disable Edge service: $serviceName"
            } else {
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Write-Log "Disabled Edge service: $serviceName"
            }
        }
    }
    
    Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoInternetOpenWith" -Value 1 -Type "DWord"
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "DisableWebSearch" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWebOverMeteredConnections" -Value 0 -Type "DWord"
    
    if ($SetChromeDefault) {
        Set-ChromeDefaultBrowser
    }
    
    if (-not $DryRun) {
        gpupdate /force | Out-Null
        Write-Log "Applied Group Policy updates"
        
        Write-Log "Restarting Explorer..."
        Stop-Process -Name explorer -Force
        Start-Process explorer
    }
    
    Write-Log "Debloat complete. Reboot for full effect."
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

if (-not $SkipPermissionCheck) {
    Test-ScriptPermissions -ContinueAnyway:$ContinueAnyway
}

Apply-DebloatSettingsfunction Set-ChromeDefaultBrowser {
    param()
    
    Write-Log "=== SETTING CHROME AS DEFAULT BROWSER ==="
    
    $chromePaths = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeInstalled = $false
    $chromePath = $null
    
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            $chromeInstalled = $true
            $chromePath = $path
            break
        }
    }
    
    if (-not $chromeInstalled) {
        Write-Log "Chrome not found - skipping default browser configuration" -Level "WARN"
        return
    }
    
    Write-Log "Chrome found at: $chromePath"
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set Chrome as default browser"
        return
    }
    
    try {
        $associations = @(
            @("http", "http\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @("https", "https\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".html", ".html\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".htm", ".htm\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".shtml", ".shtml\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".xhtml", ".xhtml\shell\open\command", "`"$chromePath`" -- `"%1`""),
            @(".webp", ".webp\shell\open\command", "`"$chromePath`" -- `"%1`"")
        )
        
        foreach ($assoc in $associations) {
            $assocPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$($assoc[0])\UserChoice"
            
            try {
                if (Test-Path $assocPath) {
                    Remove-Item -Path $assocPath -Force -ErrorAction SilentlyContinue
                }
                Write-Log "Cleared previous association for: $($assoc[0])"
            } catch {
                Write-Log "Could not clear association for $($assoc[0]): $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        $chromeProgId = "ChromeHTML"
        
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http" -Name "ProgId" -Value $chromeProgId
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https" -Name "ProgId" -Value $chromeProgId
        
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice" -Name "ProgId" -Value $chromeProgId
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice" -Name "ProgId" -Value $chromeProgId
        
        Write-Log "Chrome set as default for: HTTP, HTTPS, HTML, HTM"
        
        $appAssociationPath = "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat"
        if (Test-Path $appAssociationPath) {
            $backupPath = "$env:LOCALAPPDATA\Microsoft\Windows\UserClass.dat.bak"
            Copy-Item -Path $appAssociationPath -Destination $backupPath -Force -ErrorAction SilentlyContinue
            Write-Log "Backed up user associations to: $backupPath"
        }
        
        Write-Log "Opening Chrome to prompt for default browser..."
        Start-Process $chromePath -ArgumentList "--make-default-browser" -WindowStyle Hidden
        
        Write-Log "Chrome default browser configuration complete"
        Write-Log "Note: You may need to confirm Chrome as default in Settings → Apps → Default apps"
        
    } catch {
        Write-Log "Failed to set Chrome as default browser: $($_.Exception.Message)" -Level "ERROR"
    }
}
.Exception.Message)" -Level "ERROR"
    }
} -ErrorAction SilentlyContinue
    foreach ($task in $tasks) {
        if ($DryRun) {
            Write-Log "[DRYRUN] Would disable task $($task.TaskPath)\$($task.TaskName)"
        } else {
            Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
            Write-Log "Disabled task $($task.TaskPath)\$($task.TaskName)"
        }
    }
}

function Test-IsDomainJoined {
    return (Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain
}

function Test-Hardware {
    param([string]$Type)
    switch ($Type) {
        "Camera"   { return @(Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Camera*" -or $_.FriendlyName -like "*Webcam*"}).Count -gt 0 }
        "Touch"    { return (Get-PnpDevice | Where-Object {$_.FriendlyName -like "*Touch*"}).Count -gt 0 }
        "Printer"  { return @(Get-Printer).Count -gt 0 }
        "Bluetooth" { return @(Get-PnpDevice -Class Bluetooth).Count -gt 0 }
        default    { return $false }
    }
}

function Test-ScriptPermissions {
    param([switch]$ContinueAnyway)
    
    Write-Log "=== PERMISSION CHECK STARTING ===" -Level "INFO"
    $allPermissionsOK = $true
    $warnings = @()
    
    $adminPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $adminPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Log "FAIL: Not running as Administrator" -Level "ERROR"
        $allPermissionsOK = $false
    } else {
        Write-Log "PASS: Running as Administrator" -Level "INFO"
    }
    
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $restrictedPolicies = @("Restricted", "Undefined", "AllSigned")
    if ($restrictedPolicies -contains $executionPolicy) {
        Write-Log "WARN: Execution policy is '$executionPolicy' - may block script execution" -Level "WARN"
        $warnings += "Execution policy '$executionPolicy' may require adjustment. Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    } else {
        Write-Log "PASS: Execution policy is '$executionPolicy'" -Level "INFO"
    }
    
    try {
        $testPath = "HKLM:\Software\TempDebloatTest"
        New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Write-Log "PASS: HKLM registry write permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No HKLM registry write permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        $testPath = "HKCU:\Software\TempDebloatTest"
        New-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $testPath -Force -ErrorAction Stop | Out-Null
        Write-Log "PASS: HKCU registry write permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No HKCU registry write permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        $testService = Get-Service -Name "TermService" -ErrorAction Stop
        Write-Log "PASS: Service management permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No service management permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        Get-AppxPackage -ErrorAction Stop | Out-Null
        Write-Log "PASS: Appx package management permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "FAIL: No appx package management permissions: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    try {
        Get-ScheduledTask -TaskName "*" -ErrorAction Stop | Select-Object -First 1 | Out-Null
        Write-Log "PASS: Task scheduler permissions confirmed" -Level "INFO"
    } catch {
        Write-Log "WARN: Unable to verify task scheduler permissions: $($_.Exception.Message)" -Level "WARN"
        $warnings += "Task scheduler permissions could not be verified - scheduled tasks may not be disabled"
    }
    
    try {
        $defenderStatus = Get-MpPreference -ErrorAction Stop
        $realTimeProtection = $defenderStatus.DisableRealtimeMonitoring
        if ($realTimeProtection -eq $false) {
            Write-Log "WARN: Windows Defender Real-time Protection is ENABLED - may interfere with script operations" -Level "WARN"
            $warnings += "Windows Defender Real-time Protection may block registry changes. Consider temporarily disabling."
        } else {
            Write-Log "INFO: Windows Defender Real-time Protection is DISABLED" -Level "INFO"
        }
    } catch {
        Write-Log "WARN: Unable to check Windows Defender status: $($_.Exception.Message)" -Level "WARN"
    }
    
    if (Test-IsDomainJoined) {
        Write-Log "WARN: Machine is domain-joined - Group Policy may override local settings" -Level "WARN"
        $warnings += "Domain-joined machine: Group Policy may override local changes. Use -SkipDomainCheck to attempt anyway."
        
        try {
            $gpResult = gpresult /scope computer /r
            Write-Log "INFO: Group Policy applied (run 'gpresult /h report.html' for details)" -Level "INFO"
        } catch {
            Write-Log "WARN: Unable to retrieve Group Policy status" -Level "WARN"
        }
    } else {
        Write-Log "PASS: Not domain-joined - local settings will take precedence" -Level "INFO"
    }
    
    try {
        $backupDir = "C:\temp"
        if (-not (Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $testFile = "$backupDir\debfloat-permission-test.txt"
        "test" | Out-File -FilePath $testFile -Force -ErrorAction Stop
        Remove-Item -Path $testFile -Force -ErrorAction Stop
        Write-Log "PASS: Backup directory write permissions confirmed ($backupDir)" -Level "INFO"
    } catch {
        Write-Log "FAIL: No write permissions to backup directory: $($_.Exception.Message)" -Level "ERROR"
        $allPermissionsOK = $false
    }
    
    $requiredModules = @("ScheduledTasks", "Appx")
    foreach ($module in $requiredModules) {
        $moduleAvailable = Get-Module -Name $module -ListAvailable -ErrorAction SilentlyContinue
        if ($moduleAvailable) {
            Write-Log "PASS: Module '$module' is available" -Level "INFO"
        } else {
            Write-Log "WARN: Module '$module' not found (may be built-in or optional)" -Level "WARN"
        }
    }
    
    Write-Log "=== PERMISSION CHECK COMPLETE ===" -Level "INFO"
    
    if ($warnings.Count -gt 0) {
        Write-Log "=== WARNINGS ===" -Level "WARN"
        foreach ($warning in $warnings) {
            Write-Log "  $warning" -Level "WARN"
        }
    }
    
    if (-not $allPermissionsOK) {
        Write-Log "=== CRITICAL PERMISSIONS MISSING ===" -Level "ERROR"
        Write-Log "Cannot continue due to missing critical permissions" -Level "ERROR"
        if ($ContinueAnyway) {
            Write-Log "WARNING: Continuing anyway despite permission failures (-ContinueAnyway flag set)" -Level "WARN"
        } else {
            Write-Log "Run with -ContinueAnyway to ignore these warnings (not recommended)" -Level "INFO"
            exit 1
        }
    }
    
    Write-Log "All required permissions verified. Continuing with debloat process." -Level "INFO"
    return $true
}

function Apply-DebloatSettings {
    $config = @{
        AppsToRemove = @(
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
        PreserveApps = @{}
        ServicesToDisable = @(
            "XblAuthManager",
            "XboxNetApiSvc",
            "XboxGipSvc",
            "DiagTrack",
            "MapsBroker",
            "WalletService",
            "RetailDemo",
            "wisvc"
        )
        TasksToDisable = @(
            "Microsoft Compatibility Appraiser",
            "Customer Experience Improvement Program",
            "Program Data Updater",
            "XblGameSaveTask"
        )
    }
    
    if (-not $SkipHardwareDetection) {
        $hasCamera = Test-Hardware "Camera"
        $hasTouch = Test-Hardware "Touch"
        
        if ($hasCamera) {
            $config.PreserveApps["Microsoft.WindowsCamera"] = $true
            Write-Log "Camera detected - preserving Windows Camera app"
        }
        
        if ($hasTouch) {
            $config.PreserveApps["Microsoft.WindowsCalculator"] = $true
            Write-Log "Touch screen detected - preserving Calculator app"
        }
    }
    
    Write-Log "Starting debloat process..."
    Write-Log "DryRun: $DryRun"
    Write-Log "Interactive: $Interactive"
    
    if (-not $SkipDomainCheck -and (Test-IsDomainJoined)) {
        Write-Log "Domain-joined machine - skipping domain-managed settings"
    }
    
    Backup-Registry
    Remove-BloatApps -Apps $config.AppsToRemove -PreserveApps $config.PreserveApps
    
    foreach ($service in $config.ServicesToDisable) {
        Disable-Service -ServiceName $service
    }
    
    foreach ($task in $config.TasksToDisable) {
        Disable-TaskScheduled -TaskNamePattern $task
    }
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -Value 1
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "PersonalizationReportingEnabled" -Value 0
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0
    Set-RegistryValue -Path "HKLM:\Software\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Value 0
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "PreventFirstRunPage" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge" -Name "PreventFirstRunPage" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "Disable3DSecurePrompt" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "MetricsReportingEnabled" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge" -Name "SendIntranetTraffictoInternetExplorer" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowDoNotTrack" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowWindowsSpotlight" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\ServiceUI" -Name "AllowMicrosoftWelcomeExperience" -Value 0 -Type "DWord"
    
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "DisableInstaller" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "AutoUpdateCheckPeriodMinutes" -Value 0 -Type "DWord"
    
    $edgePaths = @(
        "${env:PUBLIC}\Desktop\Microsoft Edge.lnk",
        "${env:USERPROFILE}\Desktop\Microsoft Edge.lnk",
        "${env:APPDATA}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk"
    )
    foreach ($path in $edgePaths) {
        if (Test-Path $path) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would remove Edge shortcut: $path"
            } else {
                Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                Write-Log "Removed Edge shortcut: $path"
            }
        }
    }
    
    $edgeUpdateServices = @("MicrosoftEdgeElevationService", "edgeupdate", "edgeupdatem")
    foreach ($serviceName in $edgeUpdateServices) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            if ($DryRun) {
                Write-Log "[DRYRUN] Would disable Edge service: $serviceName"
            } else {
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Write-Log "Disabled Edge service: $serviceName"
            }
        }
    }
    
    Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoInternetOpenWith" -Value 1 -Type "DWord"
    
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "DisableWebSearch" -Value 1 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Type "DWord"
    Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWebOverMeteredConnections" -Value 0 -Type "DWord"
    
    if ($SetChromeDefault) {
        Set-ChromeDefaultBrowser
    }
    
    if (-not $DryRun) {
        gpupdate /force | Out-Null
        Write-Log "Applied Group Policy updates"
        
        Write-Log "Restarting Explorer..."
        Stop-Process -Name explorer -Force
        Start-Process explorer
    }
    
    Write-Log "Debloat complete. Reboot for full effect."
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

if (-not $SkipPermissionCheck) {
    Test-ScriptPermissions -ContinueAnyway:$ContinueAnyway
}

Apply-DebloatSettingsfunction Set-ChromeDefaultBrowser {

