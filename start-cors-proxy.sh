#!/bin/bash

echo "🔧 Starting Node.js CORS proxy for Nexus..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js from https://nodejs.org"
    exit 1
fi

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install express http-proxy-middleware
fi

# Test Nexus connectivity
echo "🔍 Testing Nexus connectivity..."
if ! curl -s http://localhost:8081 > /dev/null; then
    echo "❌ Nexus not accessible on localhost:8081. Please start Nexus first."
    exit 1
fi

# Check if port 8082 is available
if netstat -an 2>/dev/null | grep -q ":8082.*LISTEN" || ss -an 2>/dev/null | grep -q ":8082.*LISTEN"; then
    echo "❌ Port 8082 is already in use. Please stop the service using this port."
    exit 1
fi

echo "🚀 Starting CORS proxy on port 8082..."
node cors-proxy.js