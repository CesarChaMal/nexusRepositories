# Nexus Repository Troubleshooting Guide

## Common Issues

### 🔧 CORS Proxy Issues

#### Problem: CORS proxy fails to start
```bash
❌ Proxy not accessible on port 8082
💡 Start proxy with: bash start-cors-proxy.sh
```

**Solutions**:
```bash
# Check if port is in use
netstat -an | grep :8082          # Linux/macOS
netstat -an | findstr ":8082"     # Windows

# Kill existing process
pkill -f cors-proxy.js            # Linux/macOS
taskkill /f /im node.exe          # Windows

# Restart proxy manually
./start-cors-proxy.sh             # Linux/macOS
start-cors-proxy.bat              # Windows
```

#### Problem: CORS headers missing
```bash
❌ CORS headers not found in response
```

**Solutions**:
```bash
# Test CORS manually
curl -H "Origin: http://localhost:8080" -I http://localhost:8082/

# Check proxy logs
cat cors-proxy.log                # Linux/macOS
type cors-proxy.log               # Windows

# Restart with verbose logging
DEBUG=* node cors-proxy.js
```

### 🔗 Connection Issues

#### Problem: Cannot connect to Nexus
```bash
curl: (7) Failed to connect to localhost port 8081
```

**Solutions**:
```bash
# Check Nexus status
curl http://localhost:8081/service/rest/v1/status

# Start Nexus (if using Docker)
docker run -d -p 8081:8081 --name nexus sonatype/nexus3

# Check Nexus logs
docker logs nexus
```

### 🏗️ Terraform Issues

#### Force CORS Recreation
```bash
# Mark resource as tainted (forces recreation)
terraform taint null_resource.nexus_cors_config

# Apply only CORS configuration
terraform apply -target=null_resource.nexus_cors_config --auto-approve
```

### 🧪 Manual CORS Testing

```bash
# Test basic connectivity
curl http://localhost:8082/

# Test CORS headers
curl -H "Origin: http://localhost:8080" -I http://localhost:8082/

# Test OPTIONS preflight
curl -X OPTIONS -H "Origin: http://localhost:8080" -H "Access-Control-Request-Method: GET" -I http://localhost:8082/

# Expected CORS headers:
# Access-Control-Allow-Origin: *
# Access-Control-Allow-Methods: GET, POST, PUT, DELETE, HEAD, OPTIONS
# Access-Control-Allow-Headers: *
# Access-Control-Allow-Credentials: true
```

### 📦 Node.js Dependencies

#### Problem: Missing Node.js or dependencies
```bash
❌ Node.js not found
```

**Solutions**:
```bash
# Install Node.js
# Windows: Download from https://nodejs.org
# Linux: sudo apt install nodejs npm
# macOS: brew install node

# Install dependencies manually
npm install express http-proxy-middleware
```

### 🔍 Debug Mode

```bash
# Enable debug logging
DEBUG=* ./start-cors-proxy.sh

# Verbose Terraform output
TF_LOG=DEBUG terraform apply

# Ansible verbose mode
ansible-playbook -vvv nexus-setup.yml
```