# Hard-to-escape Restricted System Interface
# Only numbers work on the keyboard
# Only closes when code "0000" is entered

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ErrorActionPreference = "SilentlyContinue"

# === CONFIG ===
$correctCode = "0000"
$script:isAuthenticated = $false

# --- Hide / Show Taskbar ---
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Taskbar {
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string className, string windowName);
    [DllImport("user32.dll")]
    public static extern int ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

function Hide-Taskbar {
    $taskbar = [Taskbar]::FindWindow("Shell_TrayWnd", $null)
    [Taskbar]::ShowWindow($taskbar, 0) | Out-Null
}

function Show-Taskbar {
    $taskbar = [Taskbar]::FindWindow("Shell_TrayWnd", $null)
    [Taskbar]::ShowWindow($taskbar, 5) | Out-Null
}

Hide-Taskbar

# Create window
$window = New-Object System.Windows.Window
$window.Title = "SYSTEM CONTROL INTERFACE"
$window.WindowStyle = "None"
$window.WindowState = "Maximized"
$window.Topmost = $true
$window.Background = [System.Windows.Media.Brushes]::Black
$window.FontFamily = "Consolas"
$window.ShowInTaskbar = $false
$window.ResizeMode = "NoResize"

# === BLOCK ALMOST ALL KEYS (only numbers + Backspace + Enter allowed) ===
$window.Add_PreviewKeyDown({
    param($sender, $e)

    $allowed = @(
        "D0","D1","D2","D3","D4","D5","D6","D7","D8","D9",   # Top row numbers
        "NumPad0","NumPad1","NumPad2","NumPad3","NumPad4",
        "NumPad5","NumPad6","NumPad7","NumPad8","NumPad9",  # Numpad
        "Back", "Return", "Enter"
    )

    if ($allowed -notcontains $e.Key.ToString()) {
        $e.Handled = $true   # Block everything else
    }

    # Extra block for Alt+F4 and Escape
    if ($e.Key -eq "Escape" -or ($e.Key -eq "F4" -and $e.KeyboardDevice.Modifiers -eq "Alt")) {
        $e.Handled = $true
    }
})

# Prevent closing unless authenticated
$window.Add_Closing({
    param($sender, $e)
    if (-not $script:isAuthenticated) {
        $e.Cancel = $true
    }
})

# Force focus + keep topmost
$focusTimer = New-Object System.Windows.Threading.DispatcherTimer
$focusTimer.Interval = [TimeSpan]::FromMilliseconds(250)
$focusTimer.Add_Tick({
    if (-not $script:isAuthenticated) {
        $window.Topmost = $false
        $window.Topmost = $true
        $window.Activate()
        if ($inputBox) { $inputBox.Focus() }
    }
})
$focusTimer.Start()

# Main layout
$grid = New-Object System.Windows.Controls.Grid
$window.Content = $grid

$panel = New-Object System.Windows.Controls.StackPanel
$panel.HorizontalAlignment = "Center"
$panel.VerticalAlignment = "Center"
$panel.Width = 700
$grid.Children.Add($panel)

# Header
$header = New-Object System.Windows.Controls.TextBlock
$header.Text = ">>> RESTRICTED SYSTEM NODE <<<"
$header.Foreground = [System.Windows.Media.Brushes]::Red
$header.FontSize = 38
$header.FontWeight = "Bold"
$header.TextAlignment = "Center"
$header.Margin = "0,0,0,15"
$panel.Children.Add($header)

$subheader = New-Object System.Windows.Controls.TextBlock
$subheader.Text = "UNAUTHORIZED ACCESS DETECTED"
$subheader.Foreground = [System.Windows.Media.Brushes]::DarkRed
$subheader.FontSize = 16
$subheader.TextAlignment = "Center"
$subheader.Margin = "0,0,0,40"
$panel.Children.Add($subheader)

$prompt = New-Object System.Windows.Controls.TextBlock
$prompt.Text = "ENTER AUTHORIZATION CODE"
$prompt.Foreground = [System.Windows.Media.Brushes]::Red
$prompt.FontSize = 20
$prompt.TextAlignment = "Center"
$prompt.Margin = "0,0,0,15"
$panel.Children.Add($prompt)

# Input
$inputBox = New-Object System.Windows.Controls.TextBox
$inputBox.FontSize = 26
$inputBox.Height = 52
$inputBox.Width = 280
$inputBox.Background = [System.Windows.Media.Brushes]::Black
$inputBox.Foreground = [System.Windows.Media.Brushes]::Red
$inputBox.BorderBrush = [System.Windows.Media.Brushes]::Red
$inputBox.BorderThickness = 2
$inputBox.CaretBrush = [System.Windows.Media.Brushes]::Red
$inputBox.HorizontalContentAlignment = "Center"
$inputBox.VerticalContentAlignment = "Center"
$inputBox.Margin = "0,0,0,25"
$inputBox.MaxLength = 8
$panel.Children.Add($inputBox)

# Button
$button = New-Object System.Windows.Controls.Button
$button.Content = "AUTHENTICATE"
$button.FontSize = 18
$button.Height = 48
$button.Width = 220
$button.Background = [System.Windows.Media.Brushes]::Black
$button.Foreground = [System.Windows.Media.Brushes]::Red
$button.BorderBrush = [System.Windows.Media.Brushes]::Red
$button.BorderThickness = 2
$button.Cursor = "Hand"
$panel.Children.Add($button)

# Status
$status = New-Object System.Windows.Controls.TextBlock
$status.Text = ""
$status.Foreground = [System.Windows.Media.Brushes]::Red
$status.FontSize = 18
$status.TextAlignment = "Center"
$status.Margin = "0,25,0,0"
$status.FontWeight = "Bold"
$panel.Children.Add($status)

# Authentication logic
$button.Add_Click({
    $code = $inputBox.Text.Trim()

    if ($code -eq $correctCode) {
        $script:isAuthenticated = $true
        $status.Text = "ACCESS GRANTED"
        $status.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        $inputBox.IsEnabled = $false
        $button.IsEnabled = $false
        $focusTimer.Stop()

        Show-Taskbar

        $closeTimer = New-Object System.Windows.Threading.DispatcherTimer
        $closeTimer.Interval = [TimeSpan]::FromSeconds(1.1)
        $closeTimer.Add_Tick({
            $closeTimer.Stop()
            $window.Close()
        })
        $closeTimer.Start()
    }
    else {
        $inputBox.Text = ""
        $inputBox.Focus()
        $status.Text = "ACCESS DENIED"

        # Red flash
        $flash = New-Object System.Windows.Threading.DispatcherTimer
        $flash.Interval = [TimeSpan]::FromMilliseconds(70)
        $script:flashCount = 0
        $flash.Add_Tick({
            $script:flashCount++
            if ($script:flashCount % 2 -eq 0) {
                $window.Background = [System.Windows.Media.Brushes]::Black
            } else {
                $window.Background = [System.Windows.Media.Brushes]::DarkRed
            }
            if ($script:flashCount -gt 8) {
                $flash.Stop()
                $window.Background = [System.Windows.Media.Brushes]::Black
            }
        })
        $flash.Start()
    }
})

# Enter key support
$inputBox.Add_KeyDown({
    param($sender, $e)
    if ($e.Key -eq "Return") {
        $button.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
    }
})

$window.Add_Loaded({
    $inputBox.Focus()
})

# Restore taskbar if script exits unexpectedly
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Show-Taskbar
} | Out-Null

$window.ShowDialog() | Out-Null
Show-Taskbar
