# ~\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# =============================================================================
# PowerShell Profile
# =============================================================================

$ConfigFile = Join-Path $HOME ".config" "powershell" "config.ps1"
if (Test-Path $ConfigFile)
{
    . $ConfigFile
}
