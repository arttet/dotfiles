# PowerShell script formatter for Neovim conform.nvim

$ErrorActionPreference = 'Stop'

try {
    # Read code from stdin
    $code = [Console]::In.ReadToEnd().TrimEnd()

    # Formatter settings
    $settings = @{
        IncludeRules = @(
            "PSAvoidTrailingWhitespace",
            "PSAvoidLongLines",
            "PSPlaceOpenBrace",
            "PSUseConsistentIndentation",
            "PSUseConsistentWhitespace"
        )
        Rules = @{
            PSAvoidTrailingWhitespace = @{
                Enable = $true
            }
            PSAvoidLongLines = @{
                Enable = $true
                MaximumLineLength = 120
            }
            PSPlaceOpenBrace = @{
                Enable = $true
                OnSameLine = $true
                IgnoreOneLine = $false
            }
            PSUseConsistentIndentation = @{
                Enable = $true
                IndentationSize = 4
                Kind = "space"
            }
            PSUseConsistentWhitespace = @{
                Enable = $true
                CheckOpenBrace = $true
                CheckCloseParen = $true
                CheckInnerBrace = $true
                CheckOperator = $true
                CheckPipe = $true
                CheckPipeForRedundantWhitespace = $true
                CheckSeparator = $true
                CheckParameter = $true
                CheckParenthesis = $true
                CheckTernaryOperators = $true
            }
        }
    }

    # Format and output
    Invoke-Formatter -ScriptDefinition $code -Settings $settings
}
catch {
    Write-Error "PowerShell formatting failed: $_"
    exit 1
}
