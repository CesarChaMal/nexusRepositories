@echo off
REM Nexus CORS Configuration Script for Windows
REM Configures CORS for all microfrontend modes without creating repositories

REM Load environment variables from .env file
if exist "../.env" (
    for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
)

set NEXUS_URL=http://localhost:8081
if not defined NEXUS_USER set NEXUS_USER=admin
if not defined NEXUS_PASS set NEXUS_PASS=admin

echo 🔧 Configuring Nexus CORS for all microfrontend modes...

REM Configure CORS for browser access (all microfrontend modes)
curl -u %NEXUS_USER%:%NEXUS_PASS% -X PUT "%NEXUS_URL%/service/rest/v1/security/cors" ^
    -H "Content-Type: application/json" ^
    -d "{\"enabled\":true,\"allowCredentials\":true,\"allowedOrigins\":[\"http://localhost:8080\",\"http://127.0.0.1:8080\",\"https://*.github.io\",\"https://*.githubusercontent.com\",\"https://*.s3.amazonaws.com\",\"https://*.s3-website.*.amazonaws.com\",\"http://*.s3-website.*.amazonaws.com\",\"https://cdn.jsdelivr.net\",\"https://unpkg.com\",\"*\"],\"allowedMethods\":[\"GET\",\"POST\",\"PUT\",\"DELETE\",\"HEAD\",\"OPTIONS\"],\"allowedHeaders\":[\"*\"],\"exposedHeaders\":[\"*\"]}"

if %errorlevel% equ 0 (
    echo.
    echo ✅ CORS configuration applied successfully!
    echo 🌐 Nexus UI: %NEXUS_URL%
    echo 🔧 CORS enabled for all modes: Local, NPM, Nexus, GitHub, AWS
    echo 🎯 Allowed origins:
    echo   - http://localhost:8080 (Local development^)
    echo   - https://*.github.io (GitHub Pages^)
    echo   - https://*.s3.amazonaws.com (AWS S3^)
    echo   - https://cdn.jsdelivr.net (NPM CDN^)
    echo   - * (All other origins^)
) else (
    echo ❌ Failed to configure CORS
    exit /b 1
)