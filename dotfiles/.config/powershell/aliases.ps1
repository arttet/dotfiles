# ~/.config/powershell/aliases.ps1
# =============================================================================
# Aliases
# =============================================================================

if (Get-Command eza -ErrorAction SilentlyContinue)
{
    function ll
    {
        eza --long --group --icons --time-style=long-iso @args
    }

    function la
    {
        eza --long --all --group --icons --time-style=long-iso @args
    }

    function lt
    {
        eza --tree --level=2 --icons @args
    }
} else
{
    function ll
    {
        Get-ChildItem @args
    }

    function la
    {
        Get-ChildItem -Force @args
    }
}
