@echo off
REM Nexus Repository Setup Script for Windows
REM Creates Maven, NPM, NuGet, and Docker repositories

REM Load environment variables from .env file
if exist "../.env" (
    for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
)

set NEXUS_URL=http://localhost:8081
if not defined NEXUS_USER set NEXUS_USER=admin
if not defined NEXUS_PASS set NEXUS_PASS=admin

echo 🚀 Setting up Nexus repositories...

REM Maven Repositories
echo 📦 Creating Maven repositories...

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

echo ✅ Nexus repository setup complete!
echo 🌐 Access Nexus UI: %NEXUS_URL%
echo 📋 Repositories created:
echo   - Maven: maven-group (http://localhost:8081/repository/maven-group/)
echo   - NPM: npm-group (http://localhost:8081/repository/npm-group/)
echo   - NuGet: nuget-group-v3 (http://localhost:8081/repository/nuget-group-v3/)
echo   - Docker: docker-group (localhost:9092)