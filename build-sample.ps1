#!/usr/bin/env pwsh
#
# Build Sample Application
#
# This script automates the workflow for building and testing changes using the sample application.
# It must be run from a shell that has sourced activate.ps1 first.
#

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "    ✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "    ✗ $Message" -ForegroundColor Red
}

# Activate environment if not already activated
Write-Step "Checking environment..."

if (-not $env:DOTNET_ROOT) {
    Write-Host "    Environment not activated. Activating now..." -ForegroundColor Yellow

    $activateScript = Join-Path $PSScriptRoot "activate.ps1"
    if (-not (Test-Path $activateScript)) {
        Write-Error "Cannot find activate.ps1 at: $activateScript"
        exit 1
    }

    # Source the activate script
    . $activateScript

    if (-not $env:DOTNET_ROOT) {
        Write-Error "Failed to activate environment"
        exit 1
    }
}

Write-Success "Environment is activated (DOTNET_ROOT: $env:DOTNET_ROOT)"

# Clear NuGet cache
Write-Step "Clearing NuGet cache..."
Write-Host "    This is required to ensure the sample app uses freshly built packages."

dotnet nuget locals all --clear
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to clear NuGet cache"
    exit $LASTEXITCODE
}

Write-Success "NuGet cache cleared"

# Build and pack
Write-Step "Building and packing Razor packages..."

./build.sh --pack
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit $LASTEXITCODE
}

Write-Success "Packages built successfully (see artifacts/packages/Debug/)"

# Build sample application
Write-Step "Building sample application..."

dotnet build ./sample/TestBlazorApp/TestBlazorApp.csproj
if ($LASTEXITCODE -ne 0) {
    Write-Error "Sample build failed"
    exit $LASTEXITCODE
}

Write-Success "Sample application built successfully"

Write-Host "`n==> All done! ✓" -ForegroundColor Green
Write-Host "    The sample app is ready to test your changes." -ForegroundColor Gray
Write-Host "    Check sample/TestBlazorApp/Generated/ for compiler-generated files.`n" -ForegroundColor Gray
