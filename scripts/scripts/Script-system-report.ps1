<#
system-report.ps1
Generates a basic Windows system report for troubleshooting and documentation.

Outputs:
- A timestamped TXT report
- Optional CSV exports (disk + network)
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Admin check ---
function Test-IsAdmin {
  $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$IsAdmin = Test-IsAdmin

# --- Output paths ---
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportDir = Join-Path -Path $PSScriptRoot -ChildPath "reports"
if (-not (Test-Path $reportDir)) { New-Item -Path $reportDir -ItemType Directory | Out-Null }

$txtPath  = Join-Path $reportDir "system-report_$timestamp.txt"
$diskCsv  = Join-Path $reportDir "disk_$timestamp.csv"
$netCsv   = Join-Path $reportDir "network_$timestamp.csv"

# Helper to append text safely
function Add-Section([string]$title, [string]$content) {
  "`n--- $title ---`n$content" | Out-File -FilePath $txtPath -Append -Encoding utf8
}

"=== SYSTEM REPORT ($timestamp) ===" | Out-File -FilePath $txtPath -Encoding utf8
Add-Section "Run Context" ("User: {0}`nAdmin: {1}`nComputer: {2}" -f $env:USERNAME, $IsAdmin, $env:COMPUTERNAME)

# --- Computer / OS Info ---
try {
  $ci = Get-ComputerInfo
  $osSummary = $ci | Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture, OsBuildNumber
  Add-Section "Computer Info" ($osSummary | Format-List | Out-String)
} catch {
  Add-Section "Computer Info" "Unable to fetch computer info."
}

# --- Uptime ---
try {
  $os = Get-CimInstance Win32_OperatingSystem
  $uptime = (Get-Date) - $os.LastBootUpTime
  $uptimeText = "Last Boot: {0}`nUptime: {1} days, {2} hours, {3} minutes" -f $os.LastBootUpTime, [int]$uptime.TotalDays, $uptime.Hours, $uptime.Minutes
  Add-Section "Uptime" $uptimeText
} catch {
  Add-Section "Uptime" "Unable to fetch uptime info."
}

# --- Disk Space (TXT + CSV) ---
try {
  $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
      @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
      @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
      @{Name="FreePercent";Expression={ if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace/$_.Size)*100,2) } else { 0 } }}

  Add-Section "Disk Space" ($disk | Format-Table -AutoSize | Out-String)
  $disk | Export-Csv -Path $diskCsv -NoTypeInformation -Encoding utf8
  Add-Section "Disk CSV" ("Saved: {0}" -f $diskCsv)
} catch {
  Add-Section "Disk Space" "Unable to fetch disk info."
}

# --- Network Config (TXT + CSV) ---
try {
  $net = Get-NetIPConfiguration |
    Select-Object InterfaceAlias,
      @{Name="IPv4";Expression={($_.IPv4Address | ForEach-Object {$_.IPAddress}) -join ", "}},
      @{Name="Gateway";Expression={($_.IPv4DefaultGateway | ForEach-Object {$_.NextHop}) -join ", "}},
      @{Name="DNS";Expression={($_.DNSServer.ServerAddresses) -join ", "}}

  Add-Section "Network Config" ($net | Format-Table -AutoSize | Out-String)
  $net | Export-Csv -Path $netCsv -NoTypeInformation -Encoding utf8
  Add-Section "Network CSV" ("Saved: {0}" -f $netCsv)
} catch {
  Add-Section "Network Config" "Unable to fetch network configuration."
}

# --- Recent System Errors (last 24 hours) ---
try {
  $since = (Get-Date).AddHours(-24)
  # Level=2 is Error
  $events = Get-WinEvent -FilterHashtable @{LogName='System'; Level=2; StartTime=$since} -MaxEvents 20 |
    Select-Object TimeCreated, ProviderName, Id, Message

  if ($events) {
    Add-Section "Recent System Errors (24h)" ($events | Format-List | Out-String)
  } else {
    Add-Section "Recent System Errors (24h)" "No System Error events found in the last 24 hours."
  }
} catch {
  Add-Section "Recent System Errors (24h)" ("Unable to read System event log. Admin may be required. Error: {0}" -f $_.Exception.Message)
}

Add-Section "Output Summary" ("TXT: {0}`nDisk CSV: {1}`nNetwork CSV: {2}" -f $txtPath, $diskCsv, $netCsv)
"=== END OF REPORT ===" | Out-File -FilePath $txtPath -Append -Encoding utf8

Write-Output "Report saved to: $txtPath"
Write-Output "CSV files saved to: $reportDir"
