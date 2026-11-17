$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host 'Preparando projeto Flutter Android e Web...' -ForegroundColor Cyan
flutter create --project-name organizaja --platforms=android,web .
if ($LASTEXITCODE -ne 0) { throw 'Falha ao criar arquivos nativos do Flutter.' }

$manifest = Join-Path $root 'android/app/src/main/AndroidManifest.xml'
if (Test-Path $manifest) {
  $xml = Get-Content $manifest -Raw -Encoding UTF8
  if ($xml -notmatch 'android:allowBackup=') {
    $xml = $xml -replace '<application', '<application android:allowBackup="false"'
    [System.IO.File]::WriteAllText($manifest, $xml, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host 'Android backup automatico desativado.' -ForegroundColor Green
  }
}

flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Falha em flutter pub get.' }

# Prepara os binarios do SQLite Web (necessarios para o Chrome).
dart run sqflite_common_ffi_web:setup
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar SQLite Web (sqlite3.wasm e sqflite_sw.js).' }
Write-Host 'Projeto pronto: flutter run -d chrome --web-port 8080' -ForegroundColor Green
