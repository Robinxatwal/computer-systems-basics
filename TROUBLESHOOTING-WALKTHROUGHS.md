network-reset.ps1
Basic Windows network reset steps often used for connectivity issues.
#>

Write-Output "=== Network Reset (Basic) ==="

Write-Output "`n[1/5] Flushing DNS..."
ipconfig /flushdns | Out-Null
Write-Output "Done."

Write-Output "`n[2/5] Releasing IP..."
ipconfig /release | Out-Null
Write-Output "Done."

Write-Output "`n[3/5] Renewing IP..."
ipconfig /renew | Out-Null
Write-Output "Done."

Write-Output "`n[4/5] Resetting Winsock..."
netsh winsock reset | Out-Null
Write-Output "Done."

Write-Output "`n[5/5] Resetting TCP/IP stack..."
netsh int ip reset | Out-Null
Write-Output "Done."

Write-Output "`nAll steps completed."
Write-Output "Restart the computer to apply all changes."
