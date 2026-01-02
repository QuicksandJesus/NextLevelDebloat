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