Import-Module posh-git
# Import-Module PowerLine
# Import-Module oh-my-posh

# Set-Theme Paradox
# Set-PowerLinePrompt -SetCurrentDirectory -Newline -Timestamp
# Set-PowerLinePrompt
# Add-PowerLineBlock { cwd } -AutoRemove
# Add-PowerLineBlock { Write-VcsStatus } -AutoRemove

# $global:PowerLinePrompt = @(
#     @{ bg = 'Green';        fg = 'Gray'; text = { $MyInvocation.HistoryId }}
#     @{ bg = 'DarkMagenta';  fg = 'Gray'; text = { [string]([char]1161) * [int]$NestedPromptLevel }}
#     @{ bg = 'DarkCyan';     fg = 'Gray'; text = { if($pushd = (Get-Location -Stack).count) {"$([char]187)" + $pushd }}}
#     @{ bg = 'DarkGreen';    fg = 'Gray'; text = { ' ~ ' + (Split-Path $pwd -Leaf) }})
 
# Set-PowerLinePrompt -CurrentDirectory -PowerlineFont -Title { 'PowerShell - {0}' -f (Convert-Path $pwd) }
#
# [System.Collections.Generic.List[ScriptBlock]]$Prompt = @(
#     { "$($MyInvocation.HistoryId) " }
#     { $executionContext.SessionState.Path.CurrentLocation }
#     # { '>' * ($nestedPromptLevel + 1) }

#     { "``t" }
#     { "right" }
#     # { "``t" }

#     { "``n" }
#     { "$ " }
# )

function Test-IsElevatedPrompt {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Format-AbbreviatePath {
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path,

        [Parameter(Mandatory = $false)]
        [string] $HomePrefix = '~',

        [Parameter(Mandatory = $false)]
        [Int16] $MaxDepth = 3,

        [Parameter(Mandatory = $false)]
        [string] $MaxDepthPrefix = '<' # '⋯' # '···'
    )

    $Prefix = ''

    if ($Path.ToLower().StartsWith($Env:HOME.ToLower())) {
        $Path = $Path.Substring($Env:HOME.Length)
        $Prefix = $HomePrefix
    }

    # drop leading/trailing '\'
    $Path = $Path.Trim("\\")

    $PathSplits = $Path.Split("\\")
    if ($PathSplits.Count -gt $MaxDepth) {
        $Path = [System.String]::Join("\", $PathSplits[ - $MaxDepth..-1])
        $Prefix = $MaxDepthPrefix
    }

    $Prefix + $Path
}

# function prompt {
#     $origLastExitCode = $LASTEXITCODE

#     $prompt = ""

#     $prompt += Write-Prompt "$($ExecutionContext.SessionState.Path.CurrentLocation)" -ForegroundColor Cyan
#     $prompt += Write-VcsStatus
#     $prompt += Write-Prompt "$(if ($PsDebugContext) {' [DBG]: '} else {''})" -ForegroundColor Magenta
#     $prompt += "$('>' * ($nestedPromptLevel + 1)) "

#     $LASTEXITCODE = $origLastExitCode
#     $prompt
# }

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    $prompt = ""

    # TODO: Why do this?
    # Write-Host

    # TODO: Maybe this isn't really necessary
    # Reset color, which can get messed up by Enable-GitColors
    # $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    $prompt += Write-Prompt (Format-AbbreviatePath($PWD))       -ForegroundColor Green # -ForegroundColor White -BackgroundColor DarkGreen

    $prompt += Write-VcsStatus

    # $Prompt += Write-Host

    $prompt += Write-Prompt "`n"
    $prompt += Write-Prompt "$ "                                 -ForegroundColor Yellow

    $LASTEXITCODE = $realLASTEXITCODE

    $prompt
}