# clean_gradle.ps1
# Premium Gradle Lock and Cache Cleaner for Nova Cabs

Write-Host '=============================================' -ForegroundColor 'Cyan'
Write-Host '      Nova Cabs - Gradle Lock Cleaner' -ForegroundColor 'Cyan'
Write-Host '=============================================' -ForegroundColor 'Cyan'

# 1. Kill Owner and generic Java processes
Write-Host 'Stopping orphaned Java and Gradle processes...' -ForegroundColor 'Yellow'
Stop-Process -Id 10484 -Force -ErrorAction 'SilentlyContinue'
Stop-Process -Name 'java' -Force -ErrorAction 'SilentlyContinue'
Stop-Process -Name 'gradle' -Force -ErrorAction 'SilentlyContinue'
Start-Sleep -Seconds 1
Write-Host '[✔] Orphaned processes terminated.' -ForegroundColor 'Green'

# 2. Remove the specific lock file and build cache directories
Write-Host 'Clearing Gradle lock files...' -ForegroundColor 'Yellow'
$LockFile = 'android\.gradle\noVersion\buildLogic.lock'
if (Test-Path $LockFile) {
    Remove-Item -Path $LockFile -Force -ErrorAction 'SilentlyContinue'
    Write-Host '[✔] Removed stale lock file.' -ForegroundColor 'Green'
} else {
    Write-Host '[-] Lock file not found or already deleted.' -ForegroundColor 'DarkGray'
}

$GradleCache = 'android\.gradle'
if (Test-Path $GradleCache) {
    Write-Host 'Clearing local .gradle cache...' -ForegroundColor 'Yellow'
    Remove-Item -Path $GradleCache -Recurse -Force -ErrorAction 'SilentlyContinue'
    Write-Host '[✔] Cleared local .gradle directory.' -ForegroundColor 'Green'
}

# 3. Perform Flutter clean & get
Write-Host 'Running Flutter Clean and Pub Get...' -ForegroundColor 'Yellow'
flutter clean
flutter pub get

Write-Host '=============================================' -ForegroundColor 'Green'
Write-Host ' Gradle Lock Cleaned Successfully! ' -ForegroundColor 'Green'
Write-Host ' Try running: flutter run' -ForegroundColor 'Cyan'
Write-Host '=============================================' -ForegroundColor 'Green'
