# ~/.config/powershell/functions.ps1
# =============================================================================
# Functions
# =============================================================================

# Yazi (changes directory after Yazi quits)
if (Get-Command yazi -ErrorAction SilentlyContinue)
{
    function y
    {
        $tmp = (New-TemporaryFile).FullName
        yazi @args --cwd-file="$tmp"
        $cwd = Get-Content -Path $tmp -Encoding UTF8
        if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container))
        {
            Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
        }
        Remove-Item -Path $tmp
    }
}
