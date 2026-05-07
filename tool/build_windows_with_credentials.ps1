$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$credentialsPath = Join-Path $repoRoot "assets\credentials.json"

if (-not (Test-Path $credentialsPath)) {
  Write-Error "Missing assets\credentials.json. Place the Google Desktop app connection file there before building."
}

$credentialsBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($credentialsPath))

flutter build windows --dart-define="GOOGLE_CREDENTIALS_BASE64=$credentialsBase64"
