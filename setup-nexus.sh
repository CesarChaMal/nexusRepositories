#!/bin/bash

# Nexus Repository Setup Script
# Creates Maven, NPM, NuGet, and Docker repositories
# Usage: ./setup-nexus.sh [cors-only]

# Load environment variables from .env file (current dir, then parent dir)
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env..."
    export $(grep -v '^#' ".env" | xargs)
elif [ -f "../.env" ]; then
    echo "📄 Loading environment variables from ../.env..."
    export $(grep -v '^#' "../.env" | xargs)
else
    echo "⚠️ Warning: No .env file found, using environment variables only"
fi

# Set Nexus configuration with fallback to environment variables
NEXUS_USER=${NEXUS_USER:-admin}
NEXUS_PASS=${NEXUS_PASS:-admin}
NEXUS_URL=${NEXUS_URL:-http://localhost:8081}

echo "🔍 DEBUG: Nexus configuration - USER=$NEXUS_USER, URL=$NEXUS_URL"

if [ -z "$NEXUS_PASS" ] || [ "$NEXUS_PASS" = "admin" ]; then
    echo "⚠️ Warning: Using default password. Please set NEXUS_PASS in .env file or environment variables"
fi
CORS_ONLY="${1:-false}"

if [ "$CORS_ONLY" = "cors-only" ]; then
    echo "🔧 Configuring Nexus CORS only (skipping repository creation)..."
else
    echo "🚀 Setting up Nexus repositories..."
fi

# Function to create repository
create_repo() {
    local name=$1
    local format=$2
    local type=$3
    local config=$4
    
    if [ "$CORS_ONLY" = "cors-only" ]; then
        echo "Skipping $format $type repository: $name (CORS-only mode)"
        return 0
    fi
    
    echo "Creating $format $type repository: $name"
    curl -u $NEXUS_USER:$NEXUS_PASS -X POST "$NEXUS_URL/service/rest/v1/repositories/$format/$type" \
        -H "Content-Type: application/json" \
        -d "$config"
}

if [ "$CORS_ONLY" != "cors-only" ]; then
    # Maven Repositories
    echo "📦 Creating Maven repositories..."
else
    echo "📦 Skipping Maven repositories (CORS-only mode)..."
fi

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

# Configure CORS for browser access (all microfrontend modes)
echo "🔧 Configuring CORS for browser access (all modes)..."

# Check if CORS API is available (Nexus Pro feature)
CORS_STATUS=$(curl -s -u $NEXUS_USER:$NEXUS_PASS -w "%{http_code}" -o /dev/null "$NEXUS_URL/service/rest/v1/security/cors")

if [ "$CORS_STATUS" = "404" ]; then
    echo "⚠️ CORS API not available (Nexus Community Edition)"
    echo "📝 CORS Configuration Options:"
    echo "   1. Use browser extension (CORS Unblock, CORS Everywhere)"
    echo "   2. Configure reverse proxy (nginx/Apache) with CORS headers"
    echo "   3. Upgrade to Nexus Pro for built-in CORS support"
    echo "   4. Use --disable-web-security flag in Chrome for development"
    echo ""
    echo "🔧 For development, you can disable CORS in Chrome:"
    echo "   chrome.exe --user-data-dir=/tmp/chrome_dev --disable-web-security --disable-features=VizDisplayCompositor"
else
    # Set CORS configuration with fallback to defaults
    CORS_ENABLED=${NEXUS_CORS_ENABLED:-true}
    CORS_ALLOW_CREDENTIALS=${NEXUS_CORS_ALLOW_CREDENTIALS:-true}
    CORS_ALLOWED_ORIGINS=${NEXUS_CORS_ALLOWED_ORIGINS:-"http://localhost:8080,http://127.0.0.1:8080,https://*.github.io,https://*.githubusercontent.com,https://*.s3.amazonaws.com,https://*.s3-website-*.amazonaws.com,http://*.s3-website-*.amazonaws.com,https://cdn.jsdelivr.net,https://unpkg.com,*"}
    CORS_ALLOWED_METHODS=${NEXUS_CORS_ALLOWED_METHODS:-"GET,POST,PUT,DELETE,HEAD,OPTIONS"}
    CORS_ALLOWED_HEADERS=${NEXUS_CORS_ALLOWED_HEADERS:-"*"}
    CORS_EXPOSED_HEADERS=${NEXUS_CORS_EXPOSED_HEADERS:-"*"}
    
    # Convert comma-separated strings to JSON arrays
    ORIGINS_JSON=$(echo "$CORS_ALLOWED_ORIGINS" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
    METHODS_JSON=$(echo "$CORS_ALLOWED_METHODS" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
    HEADERS_JSON=$(echo "$CORS_ALLOWED_HEADERS" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
    EXPOSED_JSON=$(echo "$CORS_EXPOSED_HEADERS" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
    
    curl -u $NEXUS_USER:$NEXUS_PASS -X PUT "$NEXUS_URL/service/rest/v1/security/cors" \
        -H "Content-Type: application/json" \
        -d "{
            \"enabled\": $CORS_ENABLED,
            \"allowCredentials\": $CORS_ALLOW_CREDENTIALS,
            \"allowedOrigins\": $ORIGINS_JSON,
            \"allowedMethods\": $METHODS_JSON,
            \"allowedHeaders\": $HEADERS_JSON,
            \"exposedHeaders\": $EXPOSED_JSON
        }"
    echo "✅ CORS configured successfully"
fi

# Start CORS proxy for Community Edition
if [ "$CORS_STATUS" = "404" ]; then
    echo "🔧 Starting CORS proxy for Community Edition..."
    
    # Check if Node.js is available
    if command -v node &> /dev/null; then
        # Install dependencies if needed
        if [ ! -f "package.json" ]; then
            cat > package.json << 'EOF'
{
  "name": "nexus-cors-proxy",
  "dependencies": {
    "express": "^4.18.2",
    "http-proxy-middleware": "^2.0.6"
  }
}
EOF
        fi
        
        if [ ! -d "node_modules" ]; then
            npm install --silent
        fi
        
        # Create proxy script if it doesn't exist
        if [ ! -f "cors-proxy.js" ]; then
            cat > cors-proxy.js << 'EOF'
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const PORT = 8082;

app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, HEAD, OPTIONS');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Credentials', 'true');
    if (req.method === 'OPTIONS') return res.status(204).end();
    next();
});

app.use('/', createProxyMiddleware({ target: 'http://localhost:8081', changeOrigin: true }));
app.listen(PORT, () => console.log(`🚀 CORS proxy running on http://localhost:${PORT}`));
EOF
        fi
        
        # Get proxy configuration from environment
        PROXY_PORT=${NEXUS_CORS_PROXY_PORT:-8082}
        PROXY_ENABLED=${NEXUS_CORS_PROXY_ENABLED:-true}
        PROXY_AUTO_START=${NEXUS_CORS_PROXY_AUTO_START:-true}
        
        if [ "$PROXY_ENABLED" = "true" ] && [ "$PROXY_AUTO_START" = "true" ]; then
            # Update proxy script with configurable port
            sed -i "s/const PORT = 8082;/const PORT = $PROXY_PORT;/" cors-proxy.js
            
            # Check if port is available
            if ! netstat -an 2>/dev/null | grep -q ":$PROXY_PORT.*LISTEN" && ! ss -an 2>/dev/null | grep -q ":$PROXY_PORT.*LISTEN"; then
                echo "🚀 Starting CORS proxy on port $PROXY_PORT..."
                nohup node cors-proxy.js > cors-proxy.log 2>&1 &
                echo $! > cors-proxy.pid
                sleep 2
                
                # Test if proxy is working
                if curl -s http://localhost:$PROXY_PORT > /dev/null; then
                    echo "✅ CORS proxy started successfully!"
                    
                    # Test CORS headers
                    echo "🧪 Testing CORS headers..."
                    CORS_TEST=$(curl -s -H "Origin: http://localhost:8080" -I http://localhost:$PROXY_PORT/ 2>/dev/null | grep -i "access-control-allow-origin" || echo "")
                    if [ -n "$CORS_TEST" ]; then
                        echo "✅ CORS headers verified: $CORS_TEST"
                        CORS_PROXY_RUNNING=true
                    else
                        echo "⚠️ CORS headers not found in response"
                        CORS_PROXY_RUNNING=false
                    fi
                else
                    echo "⚠️ CORS proxy failed to start. Check cors-proxy.log"
                    CORS_PROXY_RUNNING=false
                fi
            else
                echo "⚠️ Port $PROXY_PORT already in use"
                CORS_PROXY_RUNNING=false
            fi
        else
            echo "⚠️ CORS proxy disabled or auto-start disabled"
            CORS_PROXY_RUNNING=false
        fi
    else
        echo "⚠️ Node.js not found. CORS proxy not started."
        CORS_PROXY_RUNNING=false
    fi
else
    CORS_PROXY_RUNNING=false
fi

echo ""
echo "✅ Nexus repository setup complete!"
echo "🌐 Access Nexus UI: $NEXUS_URL"
if [ "$CORS_STATUS" = "404" ]; then
    if [ "$CORS_PROXY_RUNNING" = "true" ]; then
        echo "🔧 CORS: Proxy running on http://localhost:$PROXY_PORT (Community Edition workaround)"
        echo "📝 Use http://localhost:$PROXY_PORT for browser access instead of $NEXUS_URL"
    else
        echo "⚠️ CORS: Not available (Community Edition) - manual setup required"
    fi
else
    echo "🔧 CORS: Configured for browser access"
fi
echo "📋 Repositories created:"
echo "  - Maven: maven-group ($NEXUS_URL/repository/maven-group/)"
echo "  - NPM: npm-group ($NEXUS_URL/repository/npm-group/)"
echo "  - NuGet: nuget-group-v3 ($NEXUS_URL/repository/nuget-group-v3/)"
echo "  - Docker: docker-group (localhost:9092)"
if [ "$CORS_PROXY_RUNNING" = "true" ]; then
    echo ""
    echo "🌐 CORS-enabled URLs (for browser access):"
    echo "  - NPM: http://localhost:$PROXY_PORT/repository/npm-group/"
    echo "  - Maven: http://localhost:$PROXY_PORT/repository/maven-group/"
    echo "  - NuGet: http://localhost:$PROXY_PORT/repository/nuget-group-v3/"
    echo ""
    echo "🧪 Running CORS verification test..."
    if [ -f "test-cors.sh" ]; then
        bash test-cors.sh
    else
        echo "  Manual test: curl -H 'Origin: http://localhost:8080' -I http://localhost:$PROXY_PORT/"
    fi
fi