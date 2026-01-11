# system-report.ps1
# Generates a basic Windows system report for troubleshooting and documentation.

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outFile = "system-report_$timestamp.txt"

"=== SYSTEM REPORT ($timestamp) ===" | Out-File -FilePath $outFile -Encoding utf8

"`n--- Computer Info ---" | Out-File $outFile -Append
Get-ComputerInfo |
  Select-Object CsName, WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer, OsArchitecture, OsBuildNumber |
  Format-List | Out-String | Out-File $outFile -Append

"`n--- Uptime ---" | Out-File $outFile -Append
try {
  $os = Get-CimInstance Win32_OperatingSystem
  $uptime = (Get-Date) - $os.LastBootUpTime
  "Last Boot: $($os.LastBootUpTime)" | Out-File $outFile -Append
  "Uptime:    $([int]$uptime.TotalDays) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" | Out-File $outFile -Append
} catch {
  "Unable to fetch uptime info." | Out-File $outFile -Append
}

"`n--- Disk Space ---" | Out-File $outFile -Append
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
  Select-Object DeviceID,
    @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
    @{Name="Free%";Expression={ if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace/$_.Size)*100,2) } else { 0 } }} |
  Format-Table -AutoSize | Out-String | Out-File $outFile -Append

"`n--- Network Config (IP) ---" | Out-File $outFile -Append
Get-NetIPConfiguration |
  Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer |
  Format-List | Out-String | Out-File $outFile -Append

"`n--- Recent Event Log Errors (last 24 hours) ---" | Out-File $outFile -Append
try {
  $since = (Get-Date).AddHours(-24)
  Get-WinEvent -FilterHashtable @{LogName='System'; Level=2; StartTime=$since} -MaxEvents 20 |
    Select-Object TimeCreated, ProviderName, Id, Message |
    Format-List | Out-String | Out-File $outFile -Append
} catch {
  "Unable to read System event log (permission or availability issue)." | Out-File $outFile -Append
}

"`n=== END OF REPORT ===" | Out-File $outFile -Append

Write-Output "Report saved to: $outFile"
