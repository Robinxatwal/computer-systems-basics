<#
system-report.ps1
Generates a Windows system report for IT troubleshooting.

Outputs:
- TXT report
- CSV files for disk and network info
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -----------------------------
# Check if running as Admin
# -----------------------------
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$IsAdmin = Test-IsAdmin

# -----------------------------
# Output setup
# -----------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportDir = Join-Path $PSScriptRoot "reports"

if (-not (Test-Path $reportDir)) {
    New-Item -Path $reportDir -ItemType Directory | Out-Null
}

$txtReport = Join-Path $reportDir "system-report_$timestamp.txt"
$diskCsv   = Join-Path $reportDir "disk_$timestamp.csv"
$netCsv    = Join-Path $reportDir "network_$timestamp.csv"

function Add-Section {
    param ($Title, $Content)
    "`n--- $Title ---`n$Content" | Out-File -FilePath $txtReport -Append -Encoding utf8
}

"=== SYSTEM REPORT ($timestamp) ===" | Out-File $txtReport -Encoding utf8
Add-Section "Run Context" "User: $env:USERNAME`nAdmin: $IsAdmin`nComputer: $env:COMPUTERNAME"

# -----------------------------
# System Info
# -----------------------------
try {
    $sys = Get-ComputerInfo |
        Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture, OsBuildNumber
    Add-Section "System Information" ($sys | Format-List | Out-String)
} catch {
    Add-Section "System Information" "Unable to retrieve system information."
}

# -----------------------------
# Uptime
# -----------------------------
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    Add-Section "Uptime" "Last Boot: $($os.LastBootUpTime)`nUptime: $([int]$uptime.TotalDays) days, $($uptime.Hours) hours"
} catch {
    Add-Section "Uptime" "Unable to retrieve uptime."
}

# -----------------------------
# Disk Info (TXT + CSV)
# -----------------------------
try {
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
        @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
        @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
        @{Name="FreePercent";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}

    Add-Section "Disk Usage" ($disk | Format-Table -AutoSize | Out-String)
    $disk | Export-Csv -Path $diskCsv -NoTypeInformation -Encoding utf8
} catch {
    Add-Section "Disk Usage" "Unable to retrieve disk information."
}

# -----------------------------
# Network Info (TXT + CSV)
# -----------------------------
try {
    $net = Get-NetIPConfiguration |
        Select-Object InterfaceAlias,
        @{Name="IPv4";Expression={($_.IPv4Address.IPAddress) -join ", "}},
        @{Name="Gateway";Expression={($_.IPv4DefaultGateway.NextHop) -join ", "}},
        @{Name="DNS";Expression={($_.DNSServer.ServerAddresses) -join ", "}}

    Add-Section "Network Configuration" ($net | Format-Table -AutoSize | Out-String)
    $net | Export-Csv -Path $netCsv -NoTypeInformation -Encoding utf8
} catch {
    Add-Section "Network Configuration" "Unable to retrieve network information."
}

# -----------------------------
# Recent System Errors (24h)
# -----------------------------
try {
    $since = (Get-Date).AddHours(-24)
    $events = Get-WinEvent -FilterHashtable @{
        LogName='System'
        Level=2
        StartTime=$since
    } -MaxEvents 20

    if ($events) {
        Add-Section "Recent System Errors (24h)" ($events | Select TimeCreated, ProviderName, Id, Message | Format-List | Out-String)
    } else {
        Add-Section "Recent System Errors (24h)" "No critical system errors found."
    }
} catch {
    Add-Section "Recent System Errors (24h)" "Unable to read system event logs (admin rights may be required)."
}

"=== END OF REPORT ===" | Out-File $txtReport -Append -Encoding utf8

Write-Output "System report saved to:"
Write-Output $txtReport
