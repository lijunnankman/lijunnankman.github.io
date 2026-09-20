$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$jekyll = Get-Command 'jekyll' -ErrorAction SilentlyContinue
$jekyllPath = if ($jekyll) { $jekyll.Source } elseif (Test-Path 'C:\Ruby33-x64\bin\jekyll.bat') { 'C:\Ruby33-x64\bin\jekyll.bat' } else { $null }
if (-not $jekyllPath) {
    Write-Host 'Jekyll was not found. Install Ruby and run: gem install jekyll' -ForegroundColor Red
    exit 1
}

Write-Host 'Starting the local preview at http://127.0.0.1:4000/' -ForegroundColor Cyan
Write-Host 'Keep this window open while editing; press Ctrl+C to stop.'
Start-Process 'http://127.0.0.1:4000/'
& $jekyllPath serve --watch --host 127.0.0.1
