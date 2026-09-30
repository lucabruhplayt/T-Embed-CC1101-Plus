Add-Type -AssemblyName PresentationFramework

$window = New-Object System.Windows.Window
$window.Title = "SYSTEM LOCKED"
$window.WindowStyle = "None"
$window.WindowState = "Maximized"
$window.Topmost = $true
$window.Background = "Black"
$window.FontFamily = "Consolas"

$grid = New-Object System.Windows.Controls.Grid
$window.Content = $grid

$panel = New-Object System.Windows.Controls.StackPanel
$panel.HorizontalAlignment = "Center"
$panel.VerticalAlignment = "Center"
$panel.Width = 700
$grid.Children.Add($panel)

$title = New-Object System.Windows.Controls.TextBlock
$title.Text = "!!! SYSTEM LOCKED !!!"
$title.Foreground = "Red"
$title.FontSize = 48
$title.FontWeight = "Bold"
$title.TextAlignment = "Center"
$title.Margin = "0,0,0,25"
$panel.Children.Add($title)

$message = New-Object System.Windows.Controls.TextBlock
$message.Text = "ENTER PASSWORD TO CONTINUE"
$message.Foreground = "Red"
$message.FontSize = 22
$message.TextAlignment = "Center"
$message.Margin = "0,0,0,20"
$panel.Children.Add($message)

$password = New-Object System.Windows.Controls.PasswordBox
$password.Width = 350
$password.Height = 50
$password.FontSize = 24
$password.Foreground = "Red"
$password.Background = "Black"
$password.BorderBrush = "Red"
$password.HorizontalContentAlignment = "Center"
$password.Margin = "0,0,0,20"
$panel.Children.Add($password)

$button = New-Object System.Windows.Controls.Button
$button.Content = "UNLOCK"
$button.Width = 200
$button.Height = 50
$button.FontSize = 20
$button.Foreground = "Red"
$button.Background = "Black"
$button.BorderBrush = "Red"
$button.HorizontalAlignment = "Center"
$panel.Children.Add($button)

$status = New-Object System.Windows.Controls.TextBlock
$status.Text = ""
$status.Foreground = "Red"
$status.FontSize = 18
$status.TextAlignment = "Center"
$status.Margin = "0,20,0,0"
$panel.Children.Add($status)

$button.Add_Click({
    if ($password.Password -eq "1234") {
        $window.Close()
    }
    else {
        $status.Text = "ACCESS DENIED"
        $password.Clear()
    }
})

$window.Add_KeyDown({
    if ($_.Key -eq "Escape") {
        $window.Close()
    }
})

$window.ShowDialog()
