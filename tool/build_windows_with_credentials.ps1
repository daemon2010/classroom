$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$credentialsPath = Join-Path $repoRoot "assets\credentials.json"

if (-not (Test-Path $credentialsPath)) {
  Write-Error "Missing assets\credentials.json. Place the Google Desktop app connection file there before building."
}

try {
  $credentialsJson = Get-Content -Raw -Path $credentialsPath | ConvertFrom-Json
} catch {
  Write-Error "assets\credentials.json is not a valid Google Desktop app connection file."
}

if (-not $credentialsJson.installed -or -not $credentialsJson.installed.client_id) {
  Write-Error "assets\credentials.json must be a Google OAuth Desktop app connection file with an installed client."
}

$credentialsBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($credentialsPath))

Write-Host "Google connection file found and validated."
Write-Host "Cleaning old Windows build output..."
flutter clean
Write-Host "Building Windows release with embedded Google configuration..."
flutter build windows --dart-define "GOOGLE_CREDENTIALS_BASE64=$credentialsBase64"
Write-Host "Done. Launch build\windows\x64\runner\Release\classroom_ungraded_checker.exe"
