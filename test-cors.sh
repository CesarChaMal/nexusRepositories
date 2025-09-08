#!/bin/bash

echo "🧪 CORS Test Script"
echo "=================="

# Test configuration
PROXY_PORT=${NEXUS_CORS_PROXY_PORT:-8082}
TEST_ORIGIN="http://localhost:8080"

echo "🔍 Testing CORS on port $PROXY_PORT with origin $TEST_ORIGIN"
echo ""

# Test 1: Basic connectivity
echo "1️⃣ Testing basic connectivity..."
if curl -s --connect-timeout 3 http://localhost:$PROXY_PORT > /dev/null 2>&1; then
    echo "✅ Proxy is accessible on port $PROXY_PORT"
else
    echo "❌ Proxy not accessible on port $PROXY_PORT"
    echo "💡 Start proxy with: bash start-cors-proxy.sh"
    exit 1
fi

# Test 2: CORS headers
echo ""
echo "2️⃣ Testing CORS headers..."
RESPONSE=$(curl -s -H "Origin: $TEST_ORIGIN" -I http://localhost:$PROXY_PORT/ 2>/dev/null)

if echo "$RESPONSE" | grep -qi "access-control-allow-origin"; then
    echo "✅ CORS headers found:"
    echo "$RESPONSE" | grep -i "access-control" | sed 's/^/   /'
else
    echo "❌ CORS headers not found"
    echo "📋 Full response headers:"
    echo "$RESPONSE" | sed 's/^/   /'
fi

# Test 3: OPTIONS preflight
echo ""
echo "3️⃣ Testing OPTIONS preflight request..."
OPTIONS_RESPONSE=$(curl -s -X OPTIONS -H "Origin: $TEST_ORIGIN" -H "Access-Control-Request-Method: GET" -I http://localhost:$PROXY_PORT/ 2>/dev/null)

if echo "$OPTIONS_RESPONSE" | grep -qi "access-control-allow-methods"; then
    echo "✅ OPTIONS preflight working:"
    echo "$OPTIONS_RESPONSE" | grep -i "access-control" | sed 's/^/   /'
else
    echo "❌ OPTIONS preflight not working"
fi

echo ""
echo "🏁 CORS test complete!"