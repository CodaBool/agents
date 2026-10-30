<#
    Human-in-the-loop reproduction loop
    Copy this file, edit the steps below, and run it.
    
    Usage:
        .\hitl-loop.ps1
#>

$ErrorActionPreference = 'Stop'

function step {
    param([string]$Instruction)

    Write-Host "`n>>> $Instruction" -ForegroundColor Cyan
    Read-Host "    [Press Enter when done]"
}

function capture {
    param(
        [string]$VarName,
        [string]$Question
    )

    Write-Host "`n>>> $Question" -ForegroundColor Cyan
    $answer = Read-Host "    > "

    # Set the variable in the parent scope
    Set-Variable -Name $VarName -Value $answer -Scope 1
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture "ERRORED" "Click the 'Export' button. Did it throw an error? (y/n)"
capture "ERROR_MSG" "Paste the error message (or 'none'):"

# --- edit above ---------------------------------------------------------

Write-Host "`n--- Captured ---" -ForegroundColor Green
Write-Host "ERRORED=$ERRORED"
Write-Host "ERROR_MSG=$ERROR_MSG"