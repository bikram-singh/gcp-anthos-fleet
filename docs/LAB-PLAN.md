$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path (Get-Location).Path "docs\LAB-PLAN.md"), (Get-Clipboard -Raw), $utf8)