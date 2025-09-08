@echo off
REM Test All Nexus Automation Methods for Windows
REM Verifies that all automation methods work with unified CORS configuration

echo 🧪 Testing All Nexus Automation Methods
echo ========================================

REM Load environment variables from .env file
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
    echo ⚠️ Warning: No .env file found
)

if not defined NEXUS_URL set NEXUS_URL=http://localhost:8081
if not defined NEXUS_USER set NEXUS_USER=admin

echo 🔍 Testing Nexus connectivity...
curl -s -f -u %NEXUS_USER%:%NEXUS_PASS% "%NEXUS_URL%/service/rest/v1/status" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Nexus is not accessible at %NEXUS_URL%
    echo    Please ensure Nexus is running and credentials are correct
    exit /b 1
)
echo ✅ Nexus is accessible

REM Test 1: Batch Script Method
echo.
echo 1️⃣ Testing Batch Script Method
echo ------------------------------
if exist "setup-nexus.bat" (
    echo 🔧 Running setup-nexus.bat cors-only...
    call setup-nexus.bat cors-only >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Batch script method: PASSED
    ) else (
        echo ❌ Batch script method: FAILED
    )
) else (
    echo ⚠️ setup-nexus.bat not found
)

REM Test 2: Terraform Method
echo.
echo 2️⃣ Testing Terraform Method
echo ---------------------------
if exist "nexus-setup.tf" (
    echo 🔧 Checking terraform configuration...
    terraform validate >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Terraform method: PASSED (configuration valid)
    ) else (
        echo ❌ Terraform method: FAILED (configuration invalid)
    )
) else (
    echo ⚠️ nexus-setup.tf not found
)

REM Test 3: CORS Configuration Verification
echo.
echo 3️⃣ Testing CORS Configuration
echo -----------------------------
echo 🔧 Verifying CORS settings...
curl -s -u %NEXUS_USER%:%NEXUS_PASS% "%NEXUS_URL%/service/rest/v1/security/cors" > cors_response.tmp 2>nul
if exist cors_response.tmp (
    findstr /c:"\"enabled\":true" cors_response.tmp >nul
    if %errorlevel% equ 0 (
        echo ✅ CORS is enabled
        findstr /c:"localhost:8080" cors_response.tmp >nul
        if %errorlevel% equ 0 (
            echo ✅ CORS origins include localhost:8080
        ) else (
            echo ⚠️ CORS origins may not include localhost:8080
        )
    ) else (
        echo ❌ CORS is not enabled or not configured
    )
    del cors_response.tmp >nul 2>&1
) else (
    echo ❌ Failed to retrieve CORS configuration
)

REM Test 4: Environment Variables Verification
echo.
echo 4️⃣ Testing Environment Variables
echo --------------------------------
echo 🔍 Verifying CORS environment variables...
if defined NEXUS_CORS_ENABLED (
    echo ✅ NEXUS_CORS_ENABLED: %NEXUS_CORS_ENABLED%
) else (
    echo ⚠️ NEXUS_CORS_ENABLED not set
)

if defined NEXUS_CORS_ALLOWED_ORIGINS (
    echo ✅ NEXUS_CORS_ALLOWED_ORIGINS: %NEXUS_CORS_ALLOWED_ORIGINS:~0,50%...
) else (
    echo ⚠️ NEXUS_CORS_ALLOWED_ORIGINS not set
)

if defined NEXUS_CORS_ALLOWED_METHODS (
    echo ✅ NEXUS_CORS_ALLOWED_METHODS: %NEXUS_CORS_ALLOWED_METHODS%
) else (
    echo ⚠️ NEXUS_CORS_ALLOWED_METHODS not set
)

echo.
echo 🎯 Test Summary
echo ===============
echo All automation methods should now use unified CORS configuration from .env file
echo Configuration priority: .env file -^> environment variables -^> defaults
echo.
echo 🚀 Ready to use any automation method:
echo   - Batch: setup-nexus.bat
echo   - Terraform: terraform apply
echo   - Ansible: ansible-playbook nexus-setup.yml
echo   - CORS-only: configure-cors.bat