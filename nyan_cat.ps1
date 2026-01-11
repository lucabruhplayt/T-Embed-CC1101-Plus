# Author: SeenKid (seenkid on Discord)
# Converted to PowerShell (.ps1)
# Description: Launches Nyan Cat video in Chrome fullscreen and sets volume to max

# URL
$url = "https://youtu.be/2yJgwwDcgV8?si=2wt4DymR7MoIcL_x"

# Launch Chrome in fullscreen (kiosk mode)
Start-Process "chrome.exe" "--kiosk $url"

# Give Chrome time to initialize audio
Start-Sleep -Seconds 2

# Raise system volume to max
$k = [Math]::Ceiling(100 / 2)
$o = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt $k; $i++) {
    $o.SendKeys([char]175)  # Volume Up
}

Start-Sleep -Seconds 3

$o.SendKeys("f")
