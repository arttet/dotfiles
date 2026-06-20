# ~/.config/powershell/config.ps1
# =============================================================================
# PowerShell Configuration
# =============================================================================

# =============================================================================
# XDG Base Directory Standards
# =============================================================================
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

if (-not $env:XDG_CONFIG_HOME)
{
    $env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
}

if (-not $env:XDG_CACHE_HOME)
{
    $env:XDG_CACHE_HOME = Join-Path $HOME ".cache"
}

if (-not $env:XDG_DATA_HOME)
{
    $env:XDG_DATA_HOME = Join-Path $HOME ".local" "share"
}

if (-not $env:XDG_STATE_HOME)
{
    $env:XDG_STATE_HOME = Join-Path $HOME ".local" "state"
}

foreach ($dir in @($env:XDG_CONFIG_HOME, $env:XDG_CACHE_HOME, $env:XDG_DATA_HOME, $env:XDG_STATE_HOME))
{
    if (-not (Test-Path $dir))
    {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# =============================================================================
# PATH
# =============================================================================

$LocalBin = Join-Path $HOME ".local" "bin"
$PathSeparator = [IO.Path]::PathSeparator
if (($env:PATH -split $PathSeparator) -notcontains $LocalBin)
{
    $env:PATH = $LocalBin + $PathSeparator + $env:PATH
}

# =============================================================================
# Editor Configuration
# =============================================================================
# Priority: helix > neovim > vim > vi > nano

if (-not $env:EDITOR)
{
    foreach ($editor in "hx", "nvim", "vim", "vi", "nano")
    {
        if (Get-Command $editor -ErrorAction SilentlyContinue)
        {
            $env:EDITOR = $editor
            $env:VISUAL = $editor
            break
        }
    }
}

# =============================================================================
# PSReadLine
# =============================================================================
if (Get-Module -ListAvailable -Name PSReadLine)
{
    try
    {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd

        # Up/Down arrows search history matching what's already typed
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    } catch
    {
        # Prediction UI requires a VT-capable, non-redirected console
        # (e.g. scripts invoking pwsh without -NoProfile) - skip silently.
    }
}

# =============================================================================
# Tool Initialization (cached)
# =============================================================================
# Caches the output of `<tool> init powershell` to speed up startup, refreshing
# only when the binary changes (mirrors shell/shell.d 90-tools caching).

$CacheDir = Join-Path $env:XDG_CACHE_HOME "powershell" "init"
if (-not (Test-Path $CacheDir))
{
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
}

function Invoke-CachedInit
{
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [string]$InitCommand
    )

    $bin = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $bin)
    {
        return
    }

    $cacheFile = Join-Path $CacheDir "$Name.ps1"
    $stale = -not (Test-Path $cacheFile) -or
    ((Get-Item $bin.Source).LastWriteTime -gt (Get-Item $cacheFile).LastWriteTime)

    if ($stale)
    {
        Invoke-Expression $InitCommand | Out-File -FilePath $cacheFile -Encoding utf8
    }

    . $cacheFile
}

# Starship Prompt
if (Get-Command starship -ErrorAction SilentlyContinue)
{
    if (-not $env:STARSHIP_CONFIG)
    {
        $env:STARSHIP_CONFIG = Join-Path $env:XDG_CONFIG_HOME "starship" "starship.toml"
    }
}

Invoke-CachedInit -Name "starship" -InitCommand "starship init powershell"

# Claude Code
if (-not $env:CLAUDE_CONFIG_DIR)
{
    $env:CLAUDE_CONFIG_DIR = Join-Path $env:XDG_CONFIG_HOME "claude"
}

# Codex CLI
if (-not $env:CODEX_HOME)
{
    $env:CODEX_HOME = Join-Path $env:XDG_CONFIG_HOME "codex"
}

# Kimi Code
if (-not $env:KIMI_CODE_HOME)
{
    $env:KIMI_CODE_HOME = Join-Path $env:XDG_CONFIG_HOME "kimi-code"
}

# Yazi
if (Get-Command yazi -ErrorAction SilentlyContinue)
{
    if (-not $env:YAZI_CONFIG_HOME)
    {
        $env:YAZI_CONFIG_HOME = Join-Path $env:XDG_CONFIG_HOME "yazi"
    }
}

# Zoxide (Smart directory jumper, replaces cd)
Invoke-CachedInit -Name "zoxide" -InitCommand "zoxide init powershell"

# =============================================================================
# Aliases
# =============================================================================

$AliasesFile = Join-Path $env:XDG_CONFIG_HOME "powershell" "aliases.ps1"
if (Test-Path $AliasesFile)
{
    . $AliasesFile
}

# =============================================================================
# Functions
# =============================================================================

$FunctionsFile = Join-Path $env:XDG_CONFIG_HOME "powershell" "functions.ps1"
if (Test-Path $FunctionsFile)
{
    . $FunctionsFile
}
