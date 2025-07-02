# setup.ps1 - Complete Setup for Flask + Selenium + ChromeDriver (Windows)

# Define URLs and Paths
$chromeDriverBaseUrl = "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing"
$driverDir = "$PSScriptRoot\driver"
$env:Path += ";$driverDir"

function Check-Command {
    param($cmd)
    return Get-Command $cmd -ErrorAction SilentlyContinue
}

function Install-Packages {
    Write-Host "`n📦 Installing Flask and Selenium..."
    pip install flask selenium --upgrade
}

function Get-Chrome-Version {
    $chromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    if (!(Test-Path $chromePath)) {
        $chromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
    }
    if (!(Test-Path $chromePath)) {
        Write-Host "❌ Google Chrome not found! Install Chrome first." -ForegroundColor Red
        exit 1
    }
    $version = (Get-Item $chromePath).VersionInfo.ProductVersion
    return $version
}

function Get-Major-Version {
    param($fullVersion)
    return $fullVersion.Split(".")[0]
}

function Download-ChromeDriver {
    param($majorVersion)

    Write-Host "`n🌐 Fetching ChromeDriver version for Chrome $majorVersion..."

    $versionUrl = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
    $versionJson = Invoke-RestMethod $versionUrl
    $entry = $versionJson.versions | Where-Object { $_.version.StartsWith("$majorVersion.") } | Select-Object -First 1

    if (-not $entry) {
        Write-Host "❌ Matching ChromeDriver version not found for Chrome $majorVersion." -ForegroundColor Red
        exit 1
    }

    $driverUrl = $entry.downloads.chromedriver | Where-Object { $_.platform -eq "win32" } | Select-Object -ExpandProperty url
    $version = $entry.version

    Write-Host "🔽 Downloading ChromeDriver $version..."
    $zipPath = "$driverDir\chromedriver-$version.zip"
    Invoke-WebRequest -Uri $driverUrl -OutFile $zipPath

    Expand-Archive -Path $zipPath -DestinationPath $driverDir -Force
    Move-Item "$driverDir\chromedriver-win32\chromedriver.exe" "$driverDir\chromedriver.exe" -Force
    Remove-Item "$driverDir\chromedriver-win32" -Recurse -Force
    Remove-Item $zipPath -Force

    Write-Host "✅ ChromeDriver downloaded and placed at: $driverDir\chromedriver.exe"
}

function Add-ToPath {
    if ($env:Path -notlike "*$driverDir*") {
        Write-Host "`n🛠️  Adding ChromeDriver path to current session..."
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$driverDir", "User")
    }
}

# Start setup
Write-Host "`n🚀 Setting up Flask + Selenium + ChromeDriver (Windows)" -ForegroundColor Cyan

# 1. Check Python
if (!(Check-Command python)) {
    Write-Host "❌ Python not found. Install from https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Python found: $(python --version)"

# 2. Check pip
if (!(Check-Command pip)) {
    Write-Host "❌ pip not found. Trying to install..."
    python -m ensurepip --upgrade
}
Write-Host "✅ pip found: $(pip --version)"

# 3. Install Flask + Selenium
Install-Packages

# 4. Get Chrome Version
$chromeVersion = Get-Chrome-Version
$major = Get-Major-Version -fullVersion $chromeVersion
Write-Host "✅ Detected Chrome version: $chromeVersion"

# 5. Download matching ChromeDriver
New-Item -ItemType Directory -Force -Path $driverDir | Out-Null
Download-ChromeDriver -majorVersion $major

# 6. Add path to environment
Add-ToPath

# 7. Verify Selenium
try {
    python -c "from selenium import webdriver; print('✅ Selenium is working')"
} catch {
    Write-Host "❌ Selenium test failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 All set! Run your app with: python app.py" -ForegroundColor Green
