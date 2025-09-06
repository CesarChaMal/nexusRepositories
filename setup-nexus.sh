#!/bin/bash

# Nexus Repository Setup Script
# Creates Maven, NPM, NuGet, and Docker repositories

# Load environment variables from .env file
if [ -f "../.env" ]; then
    export $(grep -v '^#' ../.env | xargs)
fi

NEXUS_URL="http://localhost:8081"
NEXUS_USER="${NEXUS_USER:-admin}"
NEXUS_PASS="${NEXUS_PASS:-admin}"

echo "🚀 Setting up Nexus repositories..."

# Function to create repository
create_repo() {
    local name=$1
    local format=$2
    local type=$3
    local config=$4
    
    echo "Creating $format $type repository: $name"
    curl -u $NEXUS_USER:$NEXUS_PASS -X POST "$NEXUS_URL/service/rest/v1/repositories/$format/$type" \
        -H "Content-Type: application/json" \
        -d "$config"
}

# Maven Repositories
echo "📦 Creating Maven repositories..."

# Maven Proxy
create_repo "maven-proxy" "maven2" "proxy" '{
    "name": "maven-proxy",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "proxy": {"remoteUrl": "https://repo1.maven.org/maven2"},
    "negativeCache": {"enabled": true, "timeToLive": 1440},
    "httpClient": {"blocked": false, "autoBlock": true}
}'

# Maven Hosted Releases
create_repo "maven-hosted-releases" "maven2" "hosted" '{
    "name": "maven-hosted-releases",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW_ONCE"},
    "maven": {"versionPolicy": "RELEASE", "layoutPolicy": "STRICT"}
}'

# Maven Hosted Snapshots
create_repo "maven-hosted-snapshots" "maven2" "hosted" '{
    "name": "maven-hosted-snapshots",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW"},
    "maven": {"versionPolicy": "SNAPSHOT", "layoutPolicy": "STRICT"}
}'

# Maven Group
create_repo "maven-group" "maven2" "group" '{
    "name": "maven-group",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "group": {"memberNames": ["maven-proxy", "maven-hosted-releases", "maven-hosted-snapshots"]}
}'

# NPM Repositories
echo "📦 Creating NPM repositories..."

# NPM Proxy
create_repo "npm-proxy" "npm" "proxy" '{
    "name": "npm-proxy",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "proxy": {"remoteUrl": "https://registry.npmjs.org"},
    "negativeCache": {"enabled": true, "timeToLive": 1440},
    "httpClient": {"blocked": false, "autoBlock": true}
}'

# NPM Hosted Releases
create_repo "npm-hosted-releases" "npm" "hosted" '{
    "name": "npm-hosted-releases",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW_ONCE"}
}'

# NPM Hosted Snapshots
create_repo "npm-hosted-snapshots" "npm" "hosted" '{
    "name": "npm-hosted-snapshots",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW"}
}'

# NPM Group
create_repo "npm-group" "npm" "group" '{
    "name": "npm-group",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "group": {"memberNames": ["npm-proxy", "npm-hosted-releases", "npm-hosted-snapshots"]}
}'

# NuGet Repositories
echo "📦 Creating NuGet repositories..."

# NuGet Proxy v3
create_repo "nuget-proxy-v3" "nuget" "proxy" '{
    "name": "nuget-proxy-v3",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "proxy": {"remoteUrl": "https://api.nuget.org/v3/index.json"},
    "negativeCache": {"enabled": true, "timeToLive": 1440},
    "httpClient": {"blocked": false, "autoBlock": true},
    "nugetProxy": {"queryCacheItemMaxAge": 3600}
}'

# NuGet Hosted Releases
create_repo "nuget-hosted-releases" "nuget" "hosted" '{
    "name": "nuget-hosted-releases",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW_ONCE"}
}'

# NuGet Hosted Snapshots
create_repo "nuget-hosted-snapshots" "nuget" "hosted" '{
    "name": "nuget-hosted-snapshots",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW"}
}'

# NuGet Group
create_repo "nuget-group-v3" "nuget" "group" '{
    "name": "nuget-group-v3",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "group": {"memberNames": ["nuget-proxy-v3", "nuget-hosted-releases", "nuget-hosted-snapshots"]}
}'

# Docker Repositories
echo "📦 Creating Docker repositories..."

# Docker Proxy
create_repo "docker-proxy" "docker" "proxy" '{
    "name": "docker-proxy",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "proxy": {"remoteUrl": "https://registry-1.docker.io"},
    "negativeCache": {"enabled": true, "timeToLive": 1440},
    "httpClient": {"blocked": false, "autoBlock": true},
    "docker": {"httpPort": 9072, "forceBasicAuth": true, "v1Enabled": false},
    "dockerProxy": {"indexType": "HUB", "indexUrl": "https://index.docker.io"}
}'

# Docker Hosted
create_repo "docker-hosted" "docker" "hosted" '{
    "name": "docker-hosted",
    "online": true,
    "storage": {"blobStoreName": "default", "writePolicy": "ALLOW"},
    "docker": {"httpPort": 9082, "httpsPort": 9083, "forceBasicAuth": true, "v1Enabled": false}
}'

# Docker Group
create_repo "docker-group" "docker" "group" '{
    "name": "docker-group",
    "online": true,
    "storage": {"blobStoreName": "default"},
    "group": {"memberNames": ["docker-proxy", "docker-hosted"]},
    "docker": {"httpPort": 9092, "httpsPort": 9093, "forceBasicAuth": true, "v1Enabled": false}
}'

echo "✅ Nexus repository setup complete!"
echo "🌐 Access Nexus UI: $NEXUS_URL"
echo "📋 Repositories created:"
echo "  - Maven: maven-group (http://localhost:8081/repository/maven-group/)"
echo "  - NPM: npm-group (http://localhost:8081/repository/npm-group/)"
echo "  - NuGet: nuget-group-v3 (http://localhost:8081/repository/nuget-group-v3/)"
echo "  - Docker: docker-group (localhost:9092)"