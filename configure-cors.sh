#!/bin/bash

# Nexus CORS Configuration Script
# Configures CORS for all microfrontend modes without creating repositories

# Load environment variables from .env file
if [ -f "../.env" ]; then
    export $(grep -v '^#' ../.env | xargs)
fi

NEXUS_URL="http://localhost:8081"
NEXUS_USER="${NEXUS_USER:-admin}"
NEXUS_PASS="${NEXUS_PASS:-admin}"

echo "🔧 Configuring Nexus CORS for all microfrontend modes..."

# Configure CORS for browser access (all microfrontend modes)
curl -u $NEXUS_USER:$NEXUS_PASS -X PUT "$NEXUS_URL/service/rest/v1/security/cors" \
    -H "Content-Type: application/json" \
    -d '{
        "enabled": true,
        "allowCredentials": true,
        "allowedOrigins": [
            "http://localhost:8080",
            "http://127.0.0.1:8080",
            "https://*.github.io",
            "https://*.githubusercontent.com",
            "https://*.s3.amazonaws.com",
            "https://*.s3-website.*.amazonaws.com",
            "http://*.s3-website.*.amazonaws.com",
            "https://cdn.jsdelivr.net",
            "https://unpkg.com",
            "*"
        ],
        "allowedMethods": ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"],
        "allowedHeaders": ["*"],
        "exposedHeaders": ["*"]
    }'

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CORS configuration applied successfully!"
    echo "🌐 Nexus UI: $NEXUS_URL"
    echo "🔧 CORS enabled for all modes: Local, NPM, Nexus, GitHub, AWS"
    echo "🎯 Allowed origins:"
    echo "  - http://localhost:8080 (Local development)"
    echo "  - https://*.github.io (GitHub Pages)"
    echo "  - https://*.s3.amazonaws.com (AWS S3)"
    echo "  - https://cdn.jsdelivr.net (NPM CDN)"
    echo "  - * (All other origins)"
else
    echo "❌ Failed to configure CORS"
    exit 1
fi