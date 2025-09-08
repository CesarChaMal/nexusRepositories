#!/bin/bash

# Test All Nexus Automation Methods
# Verifies that all 4 automation methods work with unified CORS configuration

echo "🧪 Testing All Nexus Automation Methods"
echo "========================================"

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env..."
    export $(grep -v '^#' ".env" | xargs)
elif [ -f "../.env" ]; then
    echo "📄 Loading environment variables from ../.env..."
    export $(grep -v '^#' "../.env" | xargs)
else
    echo "⚠️ Warning: No .env file found"
fi

NEXUS_URL=${NEXUS_URL:-http://localhost:8081}
NEXUS_USER=${NEXUS_USER:-admin}

echo "🔍 Testing Nexus connectivity..."
if ! curl -s -f -u $NEXUS_USER:$NEXUS_PASS "$NEXUS_URL/service/rest/v1/status" > /dev/null; then
    echo "❌ Nexus is not accessible at $NEXUS_URL"
    echo "   Please ensure Nexus is running and credentials are correct"
    exit 1
fi
echo "✅ Nexus is accessible"

# Test 1: Shell Script Method
echo ""
echo "1️⃣ Testing Shell Script Method"
echo "------------------------------"
if [ -f "setup-nexus.sh" ]; then
    echo "🔧 Running setup-nexus.sh cors-only..."
    ./setup-nexus.sh cors-only
    if [ $? -eq 0 ]; then
        echo "✅ Shell script method: PASSED"
    else
        echo "❌ Shell script method: FAILED"
    fi
else
    echo "⚠️ setup-nexus.sh not found"
fi

# Test 2: Terraform Method
echo ""
echo "2️⃣ Testing Terraform Method"
echo "---------------------------"
if [ -f "nexus-setup.tf" ]; then
    echo "🔧 Running terraform plan..."
    if terraform plan -target=null_resource.nexus_cors_config > /dev/null 2>&1; then
        echo "✅ Terraform method: PASSED (plan successful)"
    else
        echo "❌ Terraform method: FAILED (plan failed)"
    fi
else
    echo "⚠️ nexus-setup.tf not found"
fi

# Test 3: Ansible Method
echo ""
echo "3️⃣ Testing Ansible Method"
echo "-------------------------"
if [ -f "configure-cors.yml" ]; then
    echo "🔧 Running ansible-playbook configure-cors.yml..."
    if ansible-playbook configure-cors.yml --check > /dev/null 2>&1; then
        echo "✅ Ansible method: PASSED (dry-run successful)"
    else
        echo "❌ Ansible method: FAILED (dry-run failed)"
    fi
else
    echo "⚠️ configure-cors.yml not found"
fi

# Test 4: CORS Configuration Verification
echo ""
echo "4️⃣ Testing CORS Configuration"
echo "-----------------------------"
echo "🔧 Verifying CORS settings..."
CORS_RESPONSE=$(curl -s -u $NEXUS_USER:$NEXUS_PASS "$NEXUS_URL/service/rest/v1/security/cors")
if echo "$CORS_RESPONSE" | grep -q "\"enabled\":true"; then
    echo "✅ CORS is enabled"
    if echo "$CORS_RESPONSE" | grep -q "localhost:8080"; then
        echo "✅ CORS origins include localhost:8080"
    else
        echo "⚠️ CORS origins may not include localhost:8080"
    fi
else
    echo "❌ CORS is not enabled or not configured"
fi

# Test 5: Environment Variables Verification
echo ""
echo "5️⃣ Testing Environment Variables"
echo "--------------------------------"
echo "🔍 Verifying CORS environment variables..."
if [ -n "$NEXUS_CORS_ENABLED" ]; then
    echo "✅ NEXUS_CORS_ENABLED: $NEXUS_CORS_ENABLED"
else
    echo "⚠️ NEXUS_CORS_ENABLED not set"
fi

if [ -n "$NEXUS_CORS_ALLOWED_ORIGINS" ]; then
    echo "✅ NEXUS_CORS_ALLOWED_ORIGINS: ${NEXUS_CORS_ALLOWED_ORIGINS:0:50}..."
else
    echo "⚠️ NEXUS_CORS_ALLOWED_ORIGINS not set"
fi

if [ -n "$NEXUS_CORS_ALLOWED_METHODS" ]; then
    echo "✅ NEXUS_CORS_ALLOWED_METHODS: $NEXUS_CORS_ALLOWED_METHODS"
else
    echo "⚠️ NEXUS_CORS_ALLOWED_METHODS not set"
fi

echo ""
echo "🎯 Test Summary"
echo "==============="
echo "All automation methods should now use unified CORS configuration from .env file"
echo "Configuration priority: .env file -> environment variables -> defaults"
echo ""
echo "🚀 Ready to use any automation method:"
echo "  - Shell: ./setup-nexus.sh"
echo "  - Terraform: terraform apply"
echo "  - Ansible: ansible-playbook nexus-setup.yml"
echo "  - CORS-only: ./configure-cors.sh"