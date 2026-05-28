#Requires -Version 5.1
<#
.SYNOPSIS
  Bump pubspec.yaml version for Go Binary Rush.

.DESCRIPTION
  Reads `version: X.Y.Z+B` from pubspec.yaml and writes the bumped version.
  The build number (after `+`, used as Android versionCode) always increments
  by 1. The semver component bumped is selected with -Part.

.PARAMETER Part
  Which versionName component to bump: patch (default), minor, or major.

.PARAMETER DryRun
  Print the next version without writing the file.

.EXAMPLE
  .\tools\bump.ps1
  Bump patch: 1.1.1+5 -> 1.1.2+6

.EXAMPLE
  .\tools\bump.ps1 -Part minor
  Bump minor: 1.1.1+5 -> 1.2.0+6

.EXAMPLE
  .\tools\bump.ps1 -Part major -DryRun
  Show what a major bump would do, without modifying pubspec.yaml.
#>

[CmdletBinding()]
param(
    [ValidateSet('patch', 'minor', 'major')]
    [string]$Part = 'patch',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$pubspec  = Join-Path $repoRoot 'pubspec.yaml'

if (-not (Test-Path -LiteralPath $pubspec)) {
    throw "pubspec.yaml not found at $pubspec"
}

# Read the file as raw bytes/text so we preserve original line endings and
# encoding exactly (Get-Content/Set-Content in PS 5.1 can introduce a BOM
# and convert LF<->CRLF, which would dirty the diff).
$raw = [System.IO.File]::ReadAllText($pubspec)

$pattern = '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$'
$m = [regex]::Match($raw, $pattern)
if (-not $m.Success) {
    throw "No 'version: X.Y.Z+B' line found in pubspec.yaml"
}

$major = [int]$m.Groups[1].Value
$minor = [int]$m.Groups[2].Value
$patch = [int]$m.Groups[3].Value
$build = [int]$m.Groups[4].Value

$oldVersion = "$major.$minor.$patch+$build"

switch ($Part) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
}
$build++

$newVersion = "$major.$minor.$patch+$build"
$newLine    = "version: $newVersion"

Write-Host ("pubspec version: {0} -> {1}" -f $oldVersion, $newVersion) -ForegroundColor Green

if ($DryRun) {
    Write-Host "(dry run; pubspec.yaml not modified)" -ForegroundColor Yellow
    exit 0
}

$newRaw = $raw.Substring(0, $m.Index) + $newLine + $raw.Substring($m.Index + $m.Length)
[System.IO.File]::WriteAllText($pubspec, $newRaw)

Write-Host "Updated $pubspec" -ForegroundColor Green
