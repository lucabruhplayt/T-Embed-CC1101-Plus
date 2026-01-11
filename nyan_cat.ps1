# Author: SeenKid (seenkid on Discord)
# Description: Launches Nyan Cat on YouTube fullscreen and sets volume to max

# URL
$url = "https://youtu.be/2yJgwwDcgV8?si=2wt4DymR7MoIcL_x"

# Launch Chrome normally
Start-Process "chrome.exe" $url

# Wait for YouTube to load (adjust sleep if internet is slow)
Start-Sleep -Seconds 5

# Raise system volume to max
$k = [Math]::Ceiling(100 / 2)
$o = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt $k; $i++) {
    $o.SendKeys([char]175)  # Volume Up
}

# Send fullscreen command to YouTube (press 'f')
$o.SendKeys("f")
