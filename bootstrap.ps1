# One-command install for Windows:
#   irm https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.ps1 | iex
# With installer flags:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/NAME0x0/CLAUDE_SETUP/main/bootstrap.ps1))) -SkipGstack
#
# Downloads the repo (no git needed) to ~/.claude-setup, then runs install.ps1.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$dest = if ($env:CLAUDE_SETUP_DIR) { $env:CLAUDE_SETUP_DIR } else { Join-Path $HOME '.claude-setup' }
$work = Join-Path ([IO.Path]::GetTempPath()) ('claude-setup-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $work | Out-Null
try {
    $zip = Join-Path $work 'repo.zip'
    Write-Host "Downloading NAME0x0/CLAUDE_SETUP..."
    Invoke-WebRequest -Uri 'https://github.com/NAME0x0/CLAUDE_SETUP/archive/refs/heads/main.zip' -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $work -Force
    if (Test-Path -LiteralPath (Join-Path $dest 'install.ps1')) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    } elseif (Test-Path -LiteralPath $dest) {
        throw "$dest exists and is not a CLAUDE_SETUP copy. Set CLAUDE_SETUP_DIR to another folder."
    }
    Move-Item -LiteralPath (Join-Path $work 'CLAUDE_SETUP-main') -Destination $dest
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}

$hostExe = (Get-Process -Id $PID).Path
& $hostExe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dest 'install.ps1') @args
