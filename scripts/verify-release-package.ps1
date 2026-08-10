[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackagePath,

    [string]$DevEcoStudioHome = $env:DEVECO_STUDIO_HOME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedPackage = (Resolve-Path -LiteralPath $PackagePath).Path
$extension = [System.IO.Path]::GetExtension($resolvedPackage).ToLowerInvariant()
if ($extension -notin @('.app', '.hap')) {
    throw 'PackagePath must point to a .app or .hap file.'
}

if ([string]::IsNullOrWhiteSpace($DevEcoStudioHome)) {
    throw 'Specify -DevEcoStudioHome or set DEVECO_STUDIO_HOME.'
}

$resolvedDevEcoHome = (Resolve-Path -LiteralPath $DevEcoStudioHome).Path
$javaPath = Join-Path $resolvedDevEcoHome 'jbr\bin\java.exe'
$signToolPath = Join-Path $resolvedDevEcoHome 'sdk\default\openharmony\toolchains\lib\hap-sign-tool.jar'

if (-not (Test-Path -LiteralPath $javaPath -PathType Leaf)) {
    throw "DevEco bundled Java was not found: $javaPath"
}
if (-not (Test-Path -LiteralPath $signToolPath -PathType Leaf)) {
    throw "hap-sign-tool.jar was not found: $signToolPath"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("harmony-release-verify-" + [guid]::NewGuid().ToString('N'))
$certificatePath = Join-Path $tempRoot 'certificate-chain.cer'
$profilePath = Join-Path $tempRoot 'profile.p7b'
$profileResultPath = Join-Path $tempRoot 'profile-verification.json'

New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    $verifyAppOutput = @(
        & $javaPath -jar $signToolPath verify-app `
            -inFile $resolvedPackage `
            -outCertChain $certificatePath `
            -outProfile $profilePath 2>&1 |
            ForEach-Object { $_.ToString() }
    )
    $verifyAppExitCode = $LASTEXITCODE
    $verifyAppText = $verifyAppOutput -join "`n"

    if ($verifyAppExitCode -ne 0 -or
        $verifyAppText -notmatch 'verify-app success' -or
        $verifyAppText -notmatch 'Digest verify result:\s*true') {
        throw "Package signature verification failed.`n$verifyAppText"
    }

    $verifyProfileOutput = @(
        & $javaPath -jar $signToolPath verify-profile `
            -inFile $profilePath `
            -outFile $profileResultPath 2>&1 |
            ForEach-Object { $_.ToString() }
    )
    $verifyProfileExitCode = $LASTEXITCODE
    $verifyProfileText = $verifyProfileOutput -join "`n"

    if ($verifyProfileExitCode -ne 0 -or $verifyProfileText -notmatch 'verify-profile success') {
        throw "Embedded Profile verification failed.`n$verifyProfileText"
    }

    $metadata = [ordered]@{
        BundleName   = $null
        VersionName  = $null
        VersionCode  = $null
        BuildVersion = $null
        CompatibleApi = $null
        TargetApi     = $null
        DeviceTypes   = $null
    }

    if ($extension -eq '.app') {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedPackage)
        try {
            $packInfoEntry = $archive.GetEntry('pack.info')
            if ($null -eq $packInfoEntry) {
                throw 'Verified APP does not contain pack.info.'
            }

            $reader = [System.IO.StreamReader]::new($packInfoEntry.Open())
            try {
                $packInfo = ($reader.ReadToEnd() | ConvertFrom-Json)
            }
            finally {
                $reader.Dispose()
            }

            $app = $packInfo.summary.app
            $modules = @($packInfo.summary.modules)
            $metadata.BundleName = [string]$app.bundleName
            $metadata.VersionName = [string]$app.version.name
            $metadata.VersionCode = [string]$app.version.code
            $metadata.BuildVersion = [string]$app.version.build
            $metadata.CompatibleApi = (@($modules | ForEach-Object { $_.apiVersion.compatible }) | Sort-Object -Unique) -join ','
            $metadata.TargetApi = (@($modules | ForEach-Object { $_.apiVersion.target }) | Sort-Object -Unique) -join ','
            $metadata.DeviceTypes = (@($modules | ForEach-Object { $_.deviceType } | ForEach-Object { $_ }) | Sort-Object -Unique) -join ','
        }
        finally {
            $archive.Dispose()
        }
    }

    $file = Get-Item -LiteralPath $resolvedPackage
    $hash = (Get-FileHash -LiteralPath $resolvedPackage -Algorithm SHA256).Hash.ToUpperInvariant()

    [pscustomobject]@{
        Path           = $resolvedPackage
        FileType       = $extension.TrimStart('.').ToUpperInvariant()
        SizeBytes      = $file.Length
        SHA256         = $hash
        Verified       = $true
        ProfileVerified = $true
        BundleName     = $metadata.BundleName
        VersionName    = $metadata.VersionName
        VersionCode    = $metadata.VersionCode
        BuildVersion   = $metadata.BuildVersion
        CompatibleApi  = $metadata.CompatibleApi
        TargetApi      = $metadata.TargetApi
        DeviceTypes    = $metadata.DeviceTypes
    }
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
