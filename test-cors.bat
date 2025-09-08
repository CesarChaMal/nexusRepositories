@echo off
echo 🧪 CORS Test Script
echo ==================

REM Test configuration
if not defined NEXUS_CORS_PROXY_PORT set NEXUS_CORS_PROXY_PORT=8082
set TEST_ORIGIN=http://localhost:8080

echo 🔍 Testing CORS on port %NEXUS_CORS_PROXY_PORT% with origin %TEST_ORIGIN%
echo.

REM Test 1: Basic connectivity
echo 1️⃣ Testing basic connectivity...
curl -s --connect-timeout 3 http://localhost:%NEXUS_CORS_PROXY_PORT% >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Proxy is accessible on port %NEXUS_CORS_PROXY_PORT%
) else (
    echo ❌ Proxy not accessible on port %NEXUS_CORS_PROXY_PORT%
    echo 💡 Start proxy with: start-cors-proxy.bat
    exit /b 1
)

REM Test 2: CORS headers
echo.
echo 2️⃣ Testing CORS headers...
curl -s -H "Origin: %TEST_ORIGIN%" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/ 2>nul | findstr /i "access-control" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ CORS headers found:
    curl -s -H "Origin: %TEST_ORIGIN%" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/ 2>nul | findstr /i "access-control"
) else (
    echo ❌ CORS headers not found
    echo 📋 Full response headers:
    curl -s -H "Origin: %TEST_ORIGIN%" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/ 2>nul
)

REM Test 3: OPTIONS preflight
echo.
echo 3️⃣ Testing OPTIONS preflight request...
curl -s -X OPTIONS -H "Origin: %TEST_ORIGIN%" -H "Access-Control-Request-Method: GET" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/ 2>nul | findstr /i "access-control-allow-methods" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ OPTIONS preflight working:
    curl -s -X OPTIONS -H "Origin: %TEST_ORIGIN%" -H "Access-Control-Request-Method: GET" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/ 2>nul | findstr /i "access-control"
) else (
    echo ❌ OPTIONS preflight not working
)

echo.
echo 🏁 CORS test complete!