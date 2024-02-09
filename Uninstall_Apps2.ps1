# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select Applications to Uninstall'
$form.Size = New-Object System.Drawing.Size(600,700)
$form.StartPosition = 'CenterScreen'

# Create the list view to show applications
$listView = New-Object System.Windows.Forms.ListView
$listView.View = [System.Windows.Forms.View]::Details
$listView.CheckBoxes = $true
$listView.FullRowSelect = $true
$listView.Columns.Add('Application', 400)
$listView.Location = New-Object System.Drawing.Point(10,10)
$listView.Size = New-Object System.Drawing.Size(560,550)

# Add installed applications to the list view
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Select-Object DisplayName | 
    Where-Object { $_.DisplayName -ne $null } |
    ForEach-Object { 
        $listItem = New-Object System.Windows.Forms.ListViewItem($_.DisplayName)
        $listView.Items.Add($listItem)
    }

# Add the list view to the form
$form.Controls.Add($listView)

# Create the uninstall button
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10,570)
$button.Size = New-Object System.Drawing.Size(560,30)
$button.Text = 'Uninstall Selected Application(s)'
$button.Add_Click({
    $listView.CheckedItems | ForEach-Object {
        $appName = $_.Text
        $key = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
               Where-Object { $_.DisplayName -eq $appName }
        if ($key -and $key.UninstallString) {
            Start-Process cmd -ArgumentList "/c $($key.UninstallString)" -Wait
        }
    }
})
$form.Controls.Add($button)

# Show the form
$form.ShowDialog()
