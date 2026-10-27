# Alerts the user when Claude stops and waits (Stop / Notification hooks).
# Beeps and shows a tray balloon without stealing focus from the app being
# automated. The balloon runs in a detached process so the hook returns at once.
param([string]$Show)

if ($Show) {
    [console]::Beep(880, 250); [console]::Beep(1100, 250)
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    $n = New-Object System.Windows.Forms.NotifyIcon
    $n.Icon = [System.Drawing.SystemIcons]::Information
    $n.Visible = $true
    $n.ShowBalloonTip(8000, "Kira automation paused", $Show, "Warning")
    Start-Sleep -Seconds 8
    $n.Dispose()
    exit 0
}

$message = "Claude is waiting for your answer."
try {
    $hookInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
    if ($hookInput.message) { $message = $hookInput.message }
} catch {}

# Balloon text is capped at 255 characters.
if ($message.Length -gt 255) { $message = $message.Substring(0, 252) + "..." }

Start-Process powershell -WindowStyle Hidden -ArgumentList @(
    "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"", "-Show", "`"$($message -replace '"', "'")`""
)
exit 0
