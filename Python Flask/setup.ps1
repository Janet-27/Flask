# PowerShell Script to Setup Python Flask App with Selenium

Write-Host "🔍 Checking Python installation..."
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python not found. Please install Python manually from https://www.python.org/downloads/"
    exit 1
}

Write-Host "✅ Python found: $(python --version)"

Write-Host "🔍 Checking pip..."
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "❌ pip not found. Installing..."
    python -m ensurepip --upgrade
}

Write-Host "✅ pip found: $(pip --version)"

Write-Host "📦 Installing required packages..."
pip install flask selenium

Write-Host "🔍 Checking ChromeDriver..."
$driverPath = "chromedriver.exe"
if (-not (Test-Path $driverPath)) {
    Write-Host "❌ chromedriver.exe not found. Download it from https://chromedriver.chromium.org/downloads"
} else {
    Write-Host "✅ ChromeDriver found."
}

Write-Host "🚀 Setup complete. Run the app using: python app.py"
