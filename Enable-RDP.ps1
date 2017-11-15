Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 

try {
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}
catch {
    netsh firewall set service type = remotedesktop mode = mode
}
