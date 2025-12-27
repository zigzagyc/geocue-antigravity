# Helper script to run Firebase configuration with absolute paths

# Absolute path to Firebase CLI (from Winget)
$firebasePath = "$env:LOCALAPPDATA\Microsoft\WinGet\Links\firebase.exe"

# Absolute path to FlutterFire CLI (from Pub Cache)
$flutterfirePath = "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat"

Write-Host "Using Firebase CLI at: $firebasePath"
Write-Host "Using FlutterFire CLI at: $flutterfirePath"

if (-not (Test-Path $firebasePath)) {
    Write-Error "Could not find firebase.exe at $firebasePath. Did you run 'winget install Google.FirebaseCLI'?"
    exit 1
}

if (-not (Test-Path $flutterfirePath)) {
    Write-Error "Could not find flutterfire.bat at $flutterfirePath. Did you run 'dart pub global activate flutterfire_cli'?"
    exit 1
}

Write-Host "`n1. Logging into Firebase (Browser will open)..."
& $firebasePath login

Write-Host "`n2. Configuring FlutterFire..."
& $flutterfirePath configure --project=geocue-antigravity

Write-Host "`nDone! You can now build the Android app."
Pause
