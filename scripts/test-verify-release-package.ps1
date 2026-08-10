[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackagePath,

    [Parameter(Mandatory = $true)]
    [string]$DevEcoStudioHome
)

$ErrorActionPreference = 'Stop'
$scriptUnderTest = Join-Path $PSScriptRoot 'verify-release-package.ps1'

if (-not (Test-Path -LiteralPath $scriptUnderTest -PathType Leaf)) {
    throw "Verification script is missing: $scriptUnderTest"
}

$result = & $scriptUnderTest -PackagePath $PackagePath -DevEcoStudioHome $DevEcoStudioHome

if (-not $result.Verified) {
    throw 'Expected package verification to pass.'
}
if (-not $result.ProfileVerified) {
    throw 'Expected embedded Profile verification to pass.'
}
if ($result.SHA256 -notmatch '^[A-F0-9]{64}$') {
    throw "Expected an uppercase SHA-256 digest, got: $($result.SHA256)"
}
if ([string]::IsNullOrWhiteSpace($result.BundleName)) {
    throw 'Expected APP metadata to include bundleName.'
}
if ([string]::IsNullOrWhiteSpace($result.VersionName)) {
    throw 'Expected APP metadata to include version name.'
}

$invalidFile = Join-Path ([System.IO.Path]::GetTempPath()) ("invalid-release-package-" + [guid]::NewGuid().ToString('N') + '.txt')
try {
    Set-Content -LiteralPath $invalidFile -Value 'not a package' -Encoding utf8
    $rejected = $false
    try {
        & $scriptUnderTest -PackagePath $invalidFile -DevEcoStudioHome $DevEcoStudioHome | Out-Null
    }
    catch {
        $rejected = $_.Exception.Message -match '\.app or \.hap'
    }
    if (-not $rejected) {
        throw 'Expected a non-.app/.hap file to be rejected before verification.'
    }
}
finally {
    Remove-Item -LiteralPath $invalidFile -Force -ErrorAction SilentlyContinue
}

Write-Host 'verify-release-package tests passed.'
