@echo off
echo 🔧 Starting Node.js CORS proxy for Nexus...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install express http-proxy-middleware
)

REM Test Nexus connectivity
echo 🔍 Testing Nexus connectivity...
curl -s http://localhost:8081 >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Nexus not accessible on localhost:8081. Please start Nexus first.
    pause
    exit /b 1
)

REM Check if port 8082 is available
netstat -an | findstr ":8082" >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ Port 8082 is already in use. Please stop the service using this port.
    pause
    exit /b 1
)

echo 🚀 Starting CORS proxy on port 8082...
node cors-proxy.js