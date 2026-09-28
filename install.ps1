<#
.SYNOPSIS
    Installs the shared Claude Code setup on Windows: CLI tools, Claude Code,
    instructions, settings, skills, gstack, plugins, MCP servers and Codex CLI.

.DESCRIPTION
    Safe to re-run. Anything it replaces is copied first to
    ~/.claude/backups/claude-setup-<timestamp>/. Existing settings.json is
    merged, not overwritten. No secrets are shipped or written.

.EXAMPLE
    .\install.ps1

.EXAMPLE
    .\install.ps1 -SkipTools -SkipGstack
#>
[CmdletBinding()]
param(
    [switch]$SkipTools,
    [switch]$SkipClaudeInstall,
    [switch]$SkipGstack,
    [switch]$SkipPlugins,
    [switch]$SkipMcp,
    [switch]$SkipCodex
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = [Console]::OutputEncoding
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } catch { }

# Some plugin marketplaces contain paths longer than Windows' 260-char limit.
# Enable git long paths for every git this script (and claude) spawns, without
# touching the user's git config.
$gitCfgIndex = 0
if ($env:GIT_CONFIG_COUNT -match '^\d+$') { $gitCfgIndex = [int]$env:GIT_CONFIG_COUNT }
Set-Item -Path "Env:GIT_CONFIG_KEY_$gitCfgIndex" -Value 'core.longpaths'
Set-Item -Path "Env:GIT_CONFIG_VALUE_$gitCfgIndex" -Value 'true'
$env:GIT_CONFIG_COUNT = [string]($gitCfgIndex + 1)

$Repo       = $PSScriptRoot
$ClaudeDir  = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$CodexDir   = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$Stamp      = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir  = Join-Path $ClaudeDir "backups\claude-setup-$Stamp"
$HostExe    = (Get-Process -Id $PID).Path
$Utf8NoBom  = New-Object System.Text.UTF8Encoding $false

$GstackRepo     = 'https://github.com/garrytan/gstack.git'
$GstackRef      = '7ea6ead9fa88ba439002a6dc1d7409649b45e9f5'
# gstack skills this setup deliberately leaves out (duplicates of other skills).
$GstackArchived = @('browse', 'investigate', 'qa-only', 'review')

$script:Warnings    = New-Object System.Collections.Generic.List[string]
$script:ManualSteps = New-Object System.Collections.Generic.List[string]
$script:BackedUp    = $false

# ---------------------------------------------------------------- helpers

function Write-Step([string]$Msg) { Write-Host "`n==> $Msg" -ForegroundColor Cyan }
function Write-Ok([string]$Msg)   { Write-Host "    ok  $Msg" -ForegroundColor Green }
function Write-Info([string]$Msg) { Write-Host "        $Msg" -ForegroundColor DarkGray }
function Add-Warning([string]$Msg) {
    $script:Warnings.Add($Msg)
    Write-Host "    !!  $Msg" -ForegroundColor Yellow
}

function Test-Cmd([string]$Name) {
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Read-Json([string]$Path) {
    [IO.File]::ReadAllText($Path) | ConvertFrom-Json
}

function Write-TextFile([string]$Path, [string]$Text) {
    [IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

# Runs a native command, streams its output dimmed, returns the exit code.
# stderr is not allowed to trip $ErrorActionPreference.
function Invoke-Exe {
    param([string]$File, [string[]]$Arguments = @(), [switch]$Quiet)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $global:LASTEXITCODE = 0
    try {
        & $File @Arguments 2>&1 | ForEach-Object { if (-not $Quiet) { Write-Info "$_" } }
    } finally {
        $ErrorActionPreference = $prev
    }
    return $global:LASTEXITCODE
}

# Runs a native command and returns its output lines (stderr included).
function Invoke-ExeOutput {
    param([string]$File, [string[]]$Arguments = @())
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { return @(& $File @Arguments 2>&1 | ForEach-Object { "$_" }) }
    finally { $ErrorActionPreference = $prev }
}

# Runs a downloaded installer script in a child process so an `exit` inside it
# cannot end this script.
function Invoke-RemoteScript([string]$Url, [string[]]$ScriptArgs = @()) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("claude-setup-" + [Guid]::NewGuid().ToString('N') + '.ps1')
    try {
        Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
        $code = Invoke-Exe $HostExe (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tmp) + $ScriptArgs)
        return $code
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Update-SessionPath {
    $parts = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User'),
        (Join-Path $HOME '.local\bin'),
        (Join-Path $HOME '.cargo\bin'),
        (Join-Path $HOME 'scoop\shims')
    )
    if ($env:APPDATA) { $parts += (Join-Path $env:APPDATA 'npm') }
    $env:Path = ($parts | Where-Object { $_ }) -join ';'
}

function Add-UserPath([string]$Dir) {
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $user) { $user = '' }
    if (($user -split ';') -notcontains $Dir) {
        $new = if ($user) { $user.TrimEnd(';') + ';' + $Dir } else { $Dir }
        [Environment]::SetEnvironmentVariable('Path', $new, 'User')
    }
    Update-SessionPath
}

# C:\Users\me\.claude -> /c/Users/me/.claude (for Git Bash)
function ConvertTo-PosixPath([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    if ($full -match '^([A-Za-z]):\\(.*)$') {
        return '/' + $Matches[1].ToLower() + '/' + ($Matches[2] -replace '\\', '/')
    }
    return ($full -replace '\\', '/')
}

function Find-GitBash {
    $candidates = @()
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $root = Split-Path (Split-Path $git.Source -Parent) -Parent
        $candidates += (Join-Path $root 'bin\bash.exe')
    }
    $candidates += (Join-Path $HOME 'scoop\apps\git\current\bin\bash.exe')
    if ($env:ProgramFiles) { $candidates += (Join-Path $env:ProgramFiles 'Git\bin\bash.exe') }
    if (${env:ProgramFiles(x86)}) { $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe') }
    if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe') }
    foreach ($c in $candidates) { if ($c -and (Test-Path -LiteralPath $c)) { return $c } }
    return $null
}

# Copies $Path into the backup folder, keeping its location relative to $Base.
function Backup-Path([string]$Path, [string]$Base = $ClaudeDir, [string]$Label = 'claude') {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return }
    $rel = $item.FullName.Substring([IO.Path]::GetFullPath($Base).TrimEnd('\').Length).TrimStart('\')
    $dest = Join-Path (Join-Path $BackupDir $Label) $rel
    # First backup of a path wins: it is the state before this run touched it.
    if (Test-Path -LiteralPath $dest) { return }
    New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
    if ($item.LinkType) {
        Add-Content -LiteralPath (Join-Path $BackupDir 'links.txt') -Value "$($item.FullName) -> $($item.Target)"
    } elseif ($item.PSIsContainer) {
        Copy-Item -LiteralPath $item.FullName -Destination $dest -Recurse -Force
    } else {
        Copy-Item -LiteralPath $item.FullName -Destination $dest -Force
    }
    $script:BackedUp = $true
}

# Deletes a file or folder. A symlink/junction is unlinked; its target is never touched.
function Remove-PathSafe([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return }
    if ($item.LinkType) { $item.Delete(); return }
    Remove-Item -LiteralPath $Path -Recurse -Force
}

# Replaces folder $Dest with a copy of $Src (after backing $Dest up).
function Copy-DirReplace([string]$Src, [string]$Dest) {
    Backup-Path $Dest
    Remove-PathSafe $Dest
    New-Item -ItemType Directory -Force -Path (Split-Path $Dest -Parent) | Out-Null
    Copy-Item -LiteralPath $Src -Destination $Dest -Recurse -Force
}

# ---------------------------------------------------------------- steps

function Install-Tools {
    Write-Step 'CLI tools (git, gh, node, scoop + the fast CLIs the instructions use)'
    $tools = Read-Json (Join-Path $Repo 'manifest\tools.json')

    $hasWinget = Test-Cmd winget
    foreach ($w in $tools.winget) {
        if (Test-Cmd $w.bin) { Write-Ok "$($w.bin) already installed"; continue }
        if (-not $hasWinget) { Add-Warning "winget not found; install $($w.id) yourself"; continue }
        Write-Info "winget install $($w.id)"
        $code = Invoke-Exe winget @('install', '--id', $w.id, '--exact', '--silent',
            '--accept-package-agreements', '--accept-source-agreements')
        if ($code -ne 0) { Add-Warning "winget install $($w.id) exited with $code" }
    }
    Update-SessionPath

    if (-not (Test-Cmd scoop)) {
        Write-Info 'Installing scoop (per-user package manager, no admin needed)'
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)
        $scoopArgs = if ($isAdmin) { @('-RunAsAdmin') } else { @() }
        $code = Invoke-RemoteScript 'https://get.scoop.sh' $scoopArgs
        Update-SessionPath
        if (-not (Test-Cmd scoop)) { Add-Warning "scoop install failed (exit $code); CLI tools skipped"; return }
    }

    foreach ($b in $tools.scoopBuckets) {
        if ($b -ne 'main') { Invoke-Exe scoop @('bucket', 'add', $b) -Quiet | Out-Null }
    }
    $missing = @($tools.scoop | Where-Object { -not (Test-Cmd $_.bin) } | ForEach-Object { $_.app })
    if ($missing.Count -gt 0) {
        Write-Info ("scoop install " + ($missing -join ' '))
        Invoke-Exe scoop (@('install') + $missing) | Out-Null
        Update-SessionPath
    }

    foreach ($c in $tools.cargoBinstall) {
        if (Test-Cmd $c.bin) { continue }
        if (-not (Test-Cmd cargo-binstall)) { Add-Warning "cargo-binstall missing; could not install $($c.crate)"; continue }
        Invoke-Exe cargo-binstall @('--no-confirm', $c.crate) | Out-Null
        Add-UserPath (Join-Path $HOME '.cargo\bin')
    }

    $all = @($tools.winget) + @($tools.scoop) + @($tools.cargoBinstall)
    $stillMissing = @($all | Where-Object { -not (Test-Cmd $_.bin) } | ForEach-Object { $_.bin })
    if ($stillMissing.Count -gt 0) {
        Add-Warning ("Tools still missing: " + ($stillMissing -join ', '))
    } else {
        Write-Ok "$($all.Count) tools available"
    }
}

function Install-ClaudeCode {
    Write-Step 'Claude Code'
    if (Test-Cmd claude) { Write-Ok 'claude already installed'; return }
    $code = Invoke-RemoteScript 'https://claude.ai/install.ps1'
    Add-UserPath (Join-Path $HOME '.local\bin')
    if (-not (Test-Cmd claude)) {
        throw "Claude Code install failed (exit $code). Install it manually, then re-run with -SkipClaudeInstall."
    }
    Write-Ok 'claude installed'
}

function Install-Settings {
    $dest = Join-Path $ClaudeDir 'settings.json'
    $template = [IO.File]::ReadAllText((Join-Path $Repo 'claude\settings.template.json'))
    $template = $template.Replace('__CLAUDE_DIR_POSIX__', (ConvertTo-PosixPath $ClaudeDir))

    if (-not (Test-Path -LiteralPath $dest)) {
        Write-TextFile $dest $template
        Write-Ok 'settings.json written'
        return
    }
    Backup-Path $dest
    if (-not (Test-Cmd jq)) {
        $side = Join-Path $ClaudeDir 'settings.claude-setup.json'
        Write-TextFile $side $template
        Add-Warning "jq not found, so settings.json was left alone. Merge $side into it by hand."
        return
    }
    $tmp = [IO.Path]::GetTempFileName()
    try {
        Write-TextFile $tmp $template
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        $merged = & jq -s -f (Join-Path $Repo 'manifest\merge-settings.jq') $dest $tmp 2>&1
        $code = $LASTEXITCODE
        $ErrorActionPreference = $prev
        if ($code -ne 0) {
            Add-Warning "Existing settings.json is not valid JSON; replaced with the template (old copy in $BackupDir)"
            Write-TextFile $dest $template
        } else {
            Write-TextFile $dest (($merged | ForEach-Object { "$_" }) -join "`n")
            Write-Ok 'settings.json merged (your existing keys, permissions and hooks kept)'
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Install-Files {
    Write-Step "Instructions, settings, status line, commands -> $ClaudeDir"
    New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
    foreach ($f in @('CLAUDE.md', 'INSTRUCT.md', 'statusline-command.sh')) {
        $dest = Join-Path $ClaudeDir $f
        Backup-Path $dest
        Copy-Item -LiteralPath (Join-Path $Repo "claude\$f") -Destination $dest -Force
        Write-Ok $f
    }
    Get-ChildItem -LiteralPath (Join-Path $Repo 'claude\commands') -Directory | ForEach-Object {
        Copy-DirReplace $_.FullName (Join-Path $ClaudeDir "commands\$($_.Name)")
        Write-Ok "commands/$($_.Name)"
    }
    Install-Settings
}

# Backs up every skill folder this run may replace, before gstack setup or the
# skill copy can touch it.
function Backup-ExistingSkills {
    $names = @(Get-ChildItem -LiteralPath (Join-Path $Repo 'claude\skills') -Directory | ForEach-Object { $_.Name })
    $names += @((Read-Json (Join-Path $Repo 'manifest\remote-skills.json')).skills | ForEach-Object { $_.name })
    $names += $GstackArchived
    foreach ($n in $names) { Backup-Path (Join-Path $ClaudeDir "skills\$n") }
}

function Install-Gstack {
    Write-Step 'gstack (headless browser + QA/review/ship skills)'
    foreach ($b in @('git', 'bun', 'node')) {
        if (-not (Test-Cmd $b)) { Add-Warning "gstack skipped: '$b' not found"; return }
    }
    $bash = Find-GitBash
    if (-not $bash) { Add-Warning 'gstack skipped: Git Bash not found'; return }

    $dir = Join-Path $ClaudeDir 'skills\gstack'
    if (Test-Path -LiteralPath (Join-Path $dir '.git')) {
        Write-Info 'gstack already cloned; keeping its current version'
    } else {
        if (Test-Path -LiteralPath $dir) { Backup-Path $dir; Remove-PathSafe $dir }
        New-Item -ItemType Directory -Force -Path (Split-Path $dir -Parent) | Out-Null
        if ((Invoke-Exe git @('clone', '--quiet', '--filter=blob:none', $GstackRepo, $dir)) -ne 0) {
            Add-Warning 'git clone of gstack failed'; return
        }
        Invoke-Exe git @('-C', $dir, '-c', 'advice.detachedHead=false', 'checkout', '--quiet', $GstackRef) | Out-Null
    }

    $posix = ConvertTo-PosixPath $dir
    Write-Info 'Running gstack setup (bun install, browser build, Playwright Chromium). Takes a few minutes.'
    $code = Invoke-Exe $bash @('-lc', "cd '$posix' && ./setup --no-prefix")
    if ($code -ne 0) {
        Add-Warning "gstack setup exited with $code. Retry later: cd ~/.claude/skills/gstack && ./setup --no-prefix"
        return
    }
    Invoke-Exe $bash @('-lc', "'$posix/bin/gstack-config' set proactive true; '$posix/bin/gstack-config' set auto_upgrade true") -Quiet | Out-Null

    foreach ($name in $GstackArchived) {
        $p = Join-Path $ClaudeDir "skills\$name"
        $skill = Join-Path $p 'SKILL.md'
        if ((Test-Path -LiteralPath $skill) -and ([IO.File]::ReadAllText($skill) -match 'gstack')) {
            Remove-PathSafe $p
        }
    }
    Write-Ok 'gstack installed'
}

function Install-Skills {
    Write-Step 'Skills'
    $skillsDir = Join-Path $ClaudeDir 'skills'
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
    $n = 0
    Get-ChildItem -LiteralPath (Join-Path $Repo 'claude\skills') -Directory | ForEach-Object {
        Copy-DirReplace $_.FullName (Join-Path $skillsDir $_.Name)
        $n++
    }
    Write-Ok "$n bundled skills"

    $remote = Read-Json (Join-Path $Repo 'manifest\remote-skills.json')
    foreach ($s in $remote.skills) {
        $dest = Join-Path $skillsDir $s.name
        $stage = Join-Path ([IO.Path]::GetTempPath()) ("claude-setup-" + $s.name + "-" + $Stamp)
        try {
            New-Item -ItemType Directory -Force -Path $stage | Out-Null
            foreach ($f in $s.files) {
                $url = "https://raw.githubusercontent.com/$($s.repo)/$($s.ref)/$($s.path)$f"
                Invoke-WebRequest -Uri $url -OutFile (Join-Path $stage $f) -UseBasicParsing
            }
            Copy-DirReplace $stage $dest
            Write-Ok "$($s.name) (fetched from github.com/$($s.repo))"
        } catch {
            Add-Warning "Could not fetch skill $($s.name): $($_.Exception.Message)"
        } finally {
            Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-Plugins {
    Write-Step 'Plugins'
    if (-not (Test-Cmd claude)) { Add-Warning 'claude not found; plugins skipped'; return }
    $m = Read-Json (Join-Path $Repo 'manifest\plugins.json')
    $existing = (Invoke-ExeOutput claude @('plugin', 'marketplace', 'list')) -join "`n"
    foreach ($mk in $m.marketplaces) {
        if ($existing -match [regex]::Escape($mk.name)) { Write-Ok "marketplace $($mk.name) (already added)"; continue }
        # owner/repo shorthand can resolve to an SSH clone; fall back to HTTPS so no SSH key is needed.
        $code = Invoke-Exe claude @('plugin', 'marketplace', 'add', $mk.repo) -Quiet
        if ($code -ne 0) {
            $code = Invoke-Exe claude @('plugin', 'marketplace', 'add', "https://github.com/$($mk.repo).git") -Quiet
        }
        if ($code -eq 0) { Write-Ok "marketplace $($mk.name)" } else { Add-Warning "could not add marketplace $($mk.repo)" }
    }
    foreach ($p in $m.plugins) {
        $code = Invoke-Exe claude @('plugin', 'install', $p, '--scope', 'user') -Quiet
        if ($code -eq 0) { Write-Ok $p } else { Add-Warning "plugin install $p exited with $code (try: claude plugin install $p)" }
    }
}

function Install-Mcp {
    Write-Step 'MCP servers'
    if (-not (Test-Cmd claude)) { Add-Warning 'claude not found; MCP servers skipped'; return }

    $fsSrc = Join-Path $Repo 'claude\mcp-servers\free-search'
    $fsDst = Join-Path $ClaudeDir 'mcp-servers\free-search'
    New-Item -ItemType Directory -Force -Path $fsDst | Out-Null
    Get-ChildItem -LiteralPath $fsSrc -File | ForEach-Object {
        $d = Join-Path $fsDst $_.Name
        Backup-Path $d
        Copy-Item -LiteralPath $_.FullName -Destination $d -Force
    }
    if (Test-Cmd npm) {
        Push-Location $fsDst
        try { $code = Invoke-Exe npm @('ci', '--omit=dev', '--no-audit', '--no-fund') -Quiet } finally { Pop-Location }
        if ($code -ne 0) { Add-Warning "npm ci for free-search exited with $code" }
    } else {
        Add-Warning 'npm not found; free-search dependencies not installed'
    }

    $fwd = [IO.Path]::GetFullPath($ClaudeDir) -replace '\\', '/'
    $m = Read-Json (Join-Path $Repo 'manifest\mcp.json')
    foreach ($s in $m.servers) {
        if ((Invoke-Exe claude @('mcp', 'get', $s.name) -Quiet) -eq 0) {
            Write-Ok "$($s.name) (already configured, left as is)"
            continue
        }
        if ($s.transport -eq 'http') {
            $a = @('mcp', 'add', '--scope', 'user', '--transport', 'http', $s.name, $s.url)
        } else {
            $srvArgs = @($s.args | ForEach-Object { $_.Replace('__CLAUDE_DIR_FWD__', $fwd) })
            $a = @('mcp', 'add', '--scope', 'user', $s.name, '--', $s.command) + $srvArgs
        }
        $code = Invoke-Exe claude $a -Quiet
        if ($code -eq 0) { Write-Ok $s.name } else { Add-Warning "claude mcp add $($s.name) exited with $code" }
    }

    $token = [Environment]::GetEnvironmentVariable('PUTER_AUTH_TOKEN', 'User')
    if (-not $token -and -not $env:PUTER_AUTH_TOKEN) {
        $script:ManualSteps.Add("free-search MCP needs a free Puter token: cd `"$fsDst`"; npm run get-token  -> then run  [Environment]::SetEnvironmentVariable('PUTER_AUTH_TOKEN','<token>','User')  and open a new terminal.")
    }
    $script:ManualSteps.Add('In Claude Code run /mcp and authenticate the github and figma servers.')
}

function Install-Codex {
    Write-Step 'Codex CLI (executor for the fable-gpt workflow)'
    if (-not (Test-Cmd codex)) {
        if (Test-Cmd npm) {
            $code = Invoke-Exe npm @('install', '-g', '@openai/codex') -Quiet
            Update-SessionPath
            if ($code -ne 0) { Add-Warning "npm install -g @openai/codex exited with $code" }
        } else {
            Add-Warning 'npm not found; Codex CLI not installed'
        }
    }
    if (Test-Cmd codex) { Write-Ok 'codex available' }

    New-Item -ItemType Directory -Force -Path $CodexDir | Out-Null
    $agents = Join-Path $CodexDir 'AGENTS.md'
    Backup-Path $agents $CodexDir 'codex'
    Copy-Item -LiteralPath (Join-Path $Repo 'codex\AGENTS.md') -Destination $agents -Force
    Write-Ok 'AGENTS.md'
    $cfg = Join-Path $CodexDir 'config.toml'
    if (-not (Test-Path -LiteralPath $cfg)) {
        Copy-Item -LiteralPath (Join-Path $Repo 'codex\config.example.toml') -Destination $cfg
        Write-Ok 'config.toml (starter)'
    } else {
        Write-Info 'config.toml exists; left unchanged'
    }
    $script:ManualSteps.Add('Run  codex login  once, then inside Claude Code run /codex:setup to confirm the plugin sees it.')
}

# ---------------------------------------------------------------- main

Write-Host "Claude setup installer" -ForegroundColor White
Write-Host "  repo:   $Repo"
Write-Host "  claude: $ClaudeDir"
Write-Host "  codex:  $CodexDir"

Update-SessionPath
if (-not $SkipTools)         { Install-Tools }
if (-not $SkipClaudeInstall) { Install-ClaudeCode }
Install-Files
Backup-ExistingSkills
if (-not $SkipGstack)        { Install-Gstack }
Install-Skills
if (-not $SkipPlugins)       { Install-Plugins }
if (-not $SkipMcp)           { Install-Mcp }
if (-not $SkipCodex)         { Install-Codex }

$script:ManualSteps.Insert(0, 'Open a NEW terminal (PATH changed), run  claude  and log in.')
$script:ManualSteps.Add('Optional: for the rust-analyzer-lsp plugin install Rust (rustup) and run  rustup component add rust-analyzer.')

Write-Step 'Done'
$skillCount = @(Get-ChildItem -LiteralPath (Join-Path $ClaudeDir 'skills') -Directory -ErrorAction SilentlyContinue).Count
Write-Host "    skills folder now holds $skillCount skills"
if ($script:BackedUp) { Write-Host "    replaced files were backed up to $BackupDir" }
if ($script:Warnings.Count -gt 0) {
    Write-Host "`nWarnings:" -ForegroundColor Yellow
    $script:Warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
Write-Host "`nFinish by hand:" -ForegroundColor White
$i = 1
$script:ManualSteps | ForEach-Object { Write-Host "  $i. $_"; $i++ }
