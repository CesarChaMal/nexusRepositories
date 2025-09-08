@echo off
REM Nexus Repository Setup Script for Windows
REM Creates Maven, NPM, NuGet, and Docker repositories
REM Usage: setup-nexus.bat [cors-only]

REM Load environment variables from .env file (current dir, then parent dir)
if exist ".env" (
    echo 📄 Loading environment variables from .env...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
) else if exist "../.env" (
    echo 📄 Loading environment variables from ../.env...
    for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
) else (
    echo ⚠️ Warning: No .env file found, using environment variables only
)

REM Set Nexus configuration with fallback to environment variables
if not defined NEXUS_USER set NEXUS_USER=admin
if not defined NEXUS_PASS set NEXUS_PASS=admin
if not defined NEXUS_URL set NEXUS_URL=http://localhost:8081

echo 🔍 DEBUG: Nexus configuration - USER=%NEXUS_USER%, URL=%NEXUS_URL%

if "%NEXUS_PASS%"=="admin" (
    echo ⚠️ Warning: Using default password. Please set NEXUS_PASS in .env file or environment variables
)
set CORS_ONLY=%1

if "%CORS_ONLY%"=="cors-only" (
    echo 🔧 Configuring Nexus CORS only (skipping repository creation^)...
) else (
    echo 🚀 Setting up Nexus repositories...
)

if not "%CORS_ONLY%"=="cors-only" (
    REM Maven Repositories
    echo 📦 Creating Maven repositories...
) else (
    echo 📦 Skipping Maven repositories (CORS-only mode^)...
    goto cors_config
)

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/maven2/proxy" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"maven-proxy\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"proxy\":{\"remoteUrl\":\"https://repo1.maven.org/maven2\"},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440},\"httpClient\":{\"blocked\":false,\"autoBlock\":true}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/maven2/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"maven-hosted-releases\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW_ONCE\"},\"maven\":{\"versionPolicy\":\"RELEASE\",\"layoutPolicy\":\"STRICT\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/maven2/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"maven-hosted-snapshots\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW\"},\"maven\":{\"versionPolicy\":\"SNAPSHOT\",\"layoutPolicy\":\"STRICT\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/maven2/group" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"maven-group\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"group\":{\"memberNames\":[\"maven-proxy\",\"maven-hosted-releases\",\"maven-hosted-snapshots\"]}}"

REM NPM Repositories
echo 📦 Creating NPM repositories...

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/npm/proxy" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"npm-proxy\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"proxy\":{\"remoteUrl\":\"https://registry.npmjs.org\"},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440},\"httpClient\":{\"blocked\":false,\"autoBlock\":true}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/npm/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"npm-hosted-releases\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW_ONCE\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/npm/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"npm-hosted-snapshots\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/npm/group" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"npm-group\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"group\":{\"memberNames\":[\"npm-proxy\",\"npm-hosted-releases\",\"npm-hosted-snapshots\"]}}"

REM NuGet Repositories
echo 📦 Creating NuGet repositories...

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/nuget/proxy" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"nuget-proxy-v3\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"proxy\":{\"remoteUrl\":\"https://api.nuget.org/v3/index.json\"},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440},\"httpClient\":{\"blocked\":false,\"autoBlock\":true},\"nugetProxy\":{\"queryCacheItemMaxAge\":3600}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/nuget/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"nuget-hosted-releases\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW_ONCE\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/nuget/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"nuget-hosted-snapshots\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/nuget/group" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"nuget-group-v3\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"group\":{\"memberNames\":[\"nuget-proxy-v3\",\"nuget-hosted-releases\",\"nuget-hosted-snapshots\"]}}"

REM Docker Repositories
echo 📦 Creating Docker repositories...

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/docker/proxy" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"docker-proxy\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"proxy\":{\"remoteUrl\":\"https://registry-1.docker.io\"},\"negativeCache\":{\"enabled\":true,\"timeToLive\":1440},\"httpClient\":{\"blocked\":false,\"autoBlock\":true},\"docker\":{\"httpPort\":9072,\"forceBasicAuth\":true,\"v1Enabled\":false},\"dockerProxy\":{\"indexType\":\"HUB\",\"indexUrl\":\"https://index.docker.io\"}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/docker/hosted" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"docker-hosted\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\",\"writePolicy\":\"ALLOW\"},\"docker\":{\"httpPort\":9082,\"httpsPort\":9083,\"forceBasicAuth\":true,\"v1Enabled\":false}}"

curl -u %NEXUS_USER%:%NEXUS_PASS% -X POST "%NEXUS_URL%/service/rest/v1/repositories/docker/group" ^
    -H "Content-Type: application/json" ^
    -d "{\"name\":\"docker-group\",\"online\":true,\"storage\":{\"blobStoreName\":\"default\"},\"group\":{\"memberNames\":[\"docker-proxy\",\"docker-hosted\"]},\"docker\":{\"httpPort\":9092,\"httpsPort\":9093,\"forceBasicAuth\":true,\"v1Enabled\":false}}"

:cors_config
REM Configure CORS for browser access (all microfrontend modes)
echo 🔧 Configuring CORS for browser access (all modes)...

REM Check if CORS API is available (Nexus Pro feature)
for /f %%i in ('curl -s -u %NEXUS_USER%:%NEXUS_PASS% -w "%%{http_code}" -o nul "%NEXUS_URL%/service/rest/v1/security/cors"') do set CORS_STATUS=%%i

if "%CORS_STATUS%"=="404" (
    echo ⚠️ CORS API not available (Nexus Community Edition^)
    echo 📝 CORS Configuration Options:
    echo    1. Use browser extension (CORS Unblock, CORS Everywhere^)
    echo    2. Configure reverse proxy (nginx/Apache^) with CORS headers
    echo    3. Upgrade to Nexus Pro for built-in CORS support
    echo    4. Use --disable-web-security flag in Chrome for development
    echo.
    echo 🔧 For development, you can disable CORS in Chrome:
    echo    chrome.exe --user-data-dir=/tmp/chrome_dev --disable-web-security --disable-features=VizDisplayCompositor
    set CORS_CONFIGURED=false
) else (
    REM Set CORS configuration with fallback to defaults
    if not defined NEXUS_CORS_ENABLED set NEXUS_CORS_ENABLED=true
    if not defined NEXUS_CORS_ALLOW_CREDENTIALS set NEXUS_CORS_ALLOW_CREDENTIALS=true
    if not defined NEXUS_CORS_ALLOWED_ORIGINS set NEXUS_CORS_ALLOWED_ORIGINS=http://localhost:8080,http://127.0.0.1:8080,https://*.github.io,https://*.githubusercontent.com,https://*.s3.amazonaws.com,https://*.s3-website-*.amazonaws.com,http://*.s3-website-*.amazonaws.com,https://cdn.jsdelivr.net,https://unpkg.com,*
    if not defined NEXUS_CORS_ALLOWED_METHODS set NEXUS_CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,HEAD,OPTIONS
    if not defined NEXUS_CORS_ALLOWED_HEADERS set NEXUS_CORS_ALLOWED_HEADERS=*
    if not defined NEXUS_CORS_EXPOSED_HEADERS set NEXUS_CORS_EXPOSED_HEADERS=*
    
    REM Convert comma-separated strings to JSON arrays (simplified for batch)
    set ORIGINS_JSON=[\"http://localhost:8080\",\"http://127.0.0.1:8080\",\"https://*.github.io\",\"https://*.githubusercontent.com\",\"https://*.s3.amazonaws.com\",\"https://*.s3-website-*.amazonaws.com\",\"http://*.s3-website-*.amazonaws.com\",\"https://cdn.jsdelivr.net\",\"https://unpkg.com\",\"*\"]
    set METHODS_JSON=[\"GET\",\"POST\",\"PUT\",\"DELETE\",\"HEAD\",\"OPTIONS\"]
    set HEADERS_JSON=[\"*\"]
    set EXPOSED_JSON=[\"*\"]
    
    curl -u %NEXUS_USER%:%NEXUS_PASS% -X PUT "%NEXUS_URL%/service/rest/v1/security/cors" ^
        -H "Content-Type: application/json" ^
        -d "{\"enabled\":%NEXUS_CORS_ENABLED%,\"allowCredentials\":%NEXUS_CORS_ALLOW_CREDENTIALS%,\"allowedOrigins\":%ORIGINS_JSON%,\"allowedMethods\":%METHODS_JSON%,\"allowedHeaders\":%HEADERS_JSON%,\"exposedHeaders\":%EXPOSED_JSON%}"
    echo ✅ CORS configured successfully
    set CORS_CONFIGURED=true
)

REM Start CORS proxy for Community Edition
if "%CORS_CONFIGURED%"=="false" (
    echo 🔧 Starting CORS proxy for Community Edition...
    
    REM Check if Node.js is available
    node --version >nul 2>&1
    if %errorlevel% equ 0 (
        REM Create package.json if needed
        if not exist "package.json" (
            echo {"name":"nexus-cors-proxy","dependencies":{"express":"^4.18.2","http-proxy-middleware":"^2.0.6"}} > package.json
        )
        
        REM Install dependencies if needed
        if not exist "node_modules" (
            npm install --silent
        )
        
        REM Create proxy script if needed
        if not exist "cors-proxy.js" (
            (
                echo const express = require('express'^);
                echo const { createProxyMiddleware } = require('http-proxy-middleware'^);
                echo const app = express(^);
                echo const PORT = 8082;
                echo app.use((req, res, next^) =^> {
                echo     res.header('Access-Control-Allow-Origin', '*'^);
                echo     res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, HEAD, OPTIONS'^);
                echo     res.header('Access-Control-Allow-Headers', '*'^);
                echo     res.header('Access-Control-Allow-Credentials', 'true'^);
                echo     if (req.method === 'OPTIONS'^) return res.status(204^).end(^);
                echo     next(^);
                echo }^);
                echo app.use('/', createProxyMiddleware({ target: 'http://localhost:8081', changeOrigin: true }^)^);
                echo app.listen(PORT, (^) =^> console.log(`CORS proxy running on http://localhost:${PORT}`^)^);
            ) > cors-proxy.js
        )
        
        REM Get proxy configuration from environment
        if not defined NEXUS_CORS_PROXY_PORT set NEXUS_CORS_PROXY_PORT=8082
        if not defined NEXUS_CORS_PROXY_ENABLED set NEXUS_CORS_PROXY_ENABLED=true
        if not defined NEXUS_CORS_PROXY_AUTO_START set NEXUS_CORS_PROXY_AUTO_START=true
        
        if "%NEXUS_CORS_PROXY_ENABLED%"=="true" if "%NEXUS_CORS_PROXY_AUTO_START%"=="true" (
            REM Update proxy script with configurable port
            powershell -Command "(Get-Content cors-proxy.js) -replace 'const PORT = 8082;', 'const PORT = %NEXUS_CORS_PROXY_PORT%;' | Set-Content cors-proxy.js"
            
            REM Check if port is available
            netstat -an | findstr ":%NEXUS_CORS_PROXY_PORT%" >nul 2>&1
            if %errorlevel% neq 0 (
                echo 🚀 Starting CORS proxy on port %NEXUS_CORS_PROXY_PORT%...
            start /b node cors-proxy.js > cors-proxy.log 2>&1
            timeout /t 3 /nobreak >nul
            
            REM Test if proxy is working
            curl -s http://localhost:%NEXUS_CORS_PROXY_PORT% >nul 2>&1
            if %errorlevel% equ 0 (
                echo ✅ CORS proxy started successfully!
                
                REM Test CORS headers
                echo 🧪 Testing CORS headers...
                curl -s -H "Origin: http://localhost:8080" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/ 2>nul | findstr /i "access-control-allow-origin" >nul 2>&1
                if %errorlevel% equ 0 (
                    echo ✅ CORS headers verified successfully
                    set CORS_PROXY_RUNNING=true
                ) else (
                    echo ⚠️ CORS headers not found in response
                    set CORS_PROXY_RUNNING=false
                )
            ) else (
                echo ⚠️ CORS proxy failed to start. Check cors-proxy.log
                set CORS_PROXY_RUNNING=false
            )
            ) else (
                echo ⚠️ Port %NEXUS_CORS_PROXY_PORT% already in use
            )
        ) else (
            echo ⚠️ CORS proxy disabled or auto-start disabled
            set CORS_PROXY_RUNNING=false
        )
    ) else (
        echo ⚠️ Node.js not found. CORS proxy not started.
        set CORS_PROXY_RUNNING=false
    )
) else (
    set CORS_PROXY_RUNNING=false
)

echo.
echo ✅ Nexus repository setup complete!
echo 🌐 Access Nexus UI: %NEXUS_URL%
if "%CORS_CONFIGURED%"=="false" (
    if "%CORS_PROXY_RUNNING%"=="true" (
        echo 🔧 CORS: Proxy running on http://localhost:%NEXUS_CORS_PROXY_PORT% (Community Edition workaround^)
        echo 📝 Use http://localhost:%NEXUS_CORS_PROXY_PORT% for browser access instead of %NEXUS_URL%
    ) else (
        echo ⚠️ CORS: Not available (Community Edition^) - manual setup required
    )
) else (
    echo 🔧 CORS: Configured for browser access
)
echo 📋 Repositories created:
echo   - Maven: maven-group (%NEXUS_URL%/repository/maven-group/)
echo   - NPM: npm-group (%NEXUS_URL%/repository/npm-group/)
echo   - NuGet: nuget-group-v3 (%NEXUS_URL%/repository/nuget-group-v3/)
echo   - Docker: docker-group (localhost:9092)
if "%CORS_PROXY_RUNNING%"=="true" (
    echo.
    echo 🌐 CORS-enabled URLs (for browser access^):
    echo   - NPM: http://localhost:%NEXUS_CORS_PROXY_PORT%/repository/npm-group/
    echo   - Maven: http://localhost:%NEXUS_CORS_PROXY_PORT%/repository/maven-group/
    echo   - NuGet: http://localhost:%NEXUS_CORS_PROXY_PORT%/repository/nuget-group-v3/
    echo.
    echo 🧪 Running CORS verification test...
    if exist "test-cors.bat" (
        echo   Executing CORS test script...
        call test-cors.bat
    ) else (
        echo   Manual test: curl -H "Origin: http://localhost:8080" -I http://localhost:%NEXUS_CORS_PROXY_PORT%/
    )
)