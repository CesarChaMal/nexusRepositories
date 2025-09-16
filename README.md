# Nexus Repository Automation

Automated setup scripts for creating Maven, NPM, NuGet, and Docker repositories in Sonatype Nexus Repository Manager.

## Prerequisites

- Nexus Repository Manager running on `localhost:8081`
- Admin credentials configured
- Terraform (for Infrastructure as Code approach)
- Ansible (for playbook approach)

## Repository Structure

```
nexusRepositories/
├── setup-nexus.sh          # Shell script automation
├── setup-nexus.bat         # Windows batch automation  
├── nexus-setup.tf          # Main Terraform config
├── vars.tf                 # Terraform variables
├── locals.tf               # Terraform locals
├── versions.tf             # Terraform versions & providers
├── outputs.tf              # Terraform outputs
├── terraform.tfvars        # Terraform variable values
├── nexus-setup.yml         # Ansible main playbook
├── configure-cors.yml      # Ansible CORS-only playbook
├── test-all-methods.sh     # Test script (Linux/macOS)
├── test-all-methods.bat    # Test script (Windows)
├── test-cors.sh            # CORS functionality test (Linux/macOS)
├── test-cors.bat           # CORS functionality test (Windows)
├── start-cors-proxy.sh     # CORS proxy starter (Linux/macOS)
├── start-cors-proxy.bat    # CORS proxy starter (Windows)
├── cors-proxy.js           # Node.js CORS proxy server
├── package.json            # Node.js dependencies
├── TROUBLESHOOTING.md      # Troubleshooting guide
└── .env                    # Environment variables
```

## Quick Start

### Shell Script (Linux/macOS/Git Bash)
```bash
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env
./setup-nexus.sh
```

### Windows Batch
```cmd
echo NEXUS_USER=admin > .env
echo NEXUS_PASS=yourpassword >> .env
setup-nexus.bat
```

### Terraform
```bash
# Using .env file
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env
terraform init && terraform apply

# Using terraform.tfvars
echo 'nexus_user = "admin"' > terraform.tfvars
echo 'nexus_pass = "yourpassword"' >> terraform.tfvars
terraform init && terraform apply
```

### Ansible
```bash
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env
ansible-playbook nexus-setup.yml
```

## Created Repositories

### Maven Repositories
- **maven-proxy** - Proxy to Maven Central
- **maven-hosted-releases** - Hosted releases repository
- **maven-hosted-snapshots** - Hosted snapshots repository  
- **maven-group** - Group combining all Maven repositories

### NPM Repositories
- **npm-proxy** - Proxy to npmjs.org
- **npm-hosted-releases** - Hosted releases repository
- **npm-hosted-snapshots** - Hosted snapshots repository
- **npm-group** - Group combining all NPM repositories

### NuGet Repositories
- **nuget-proxy-v3** - Proxy to NuGet.org v3 API
- **nuget-hosted-releases** - Hosted releases repository
- **nuget-hosted-snapshots** - Hosted snapshots repository
- **nuget-group-v3** - Group combining all NuGet repositories

### Docker Repositories
- **docker-proxy** - Proxy to Docker Hub (port 9072)
- **docker-hosted** - Hosted Docker registry (ports 9082/9083)
- **docker-group** - Group combining Docker repositories (ports 9092/9093)

## Repository URLs

After setup, repositories are available at:

- **Maven Group**: `http://localhost:8081/repository/maven-group/`
- **NPM Group**: `http://localhost:8081/repository/npm-group/`
- **NuGet Group**: `http://localhost:8081/repository/nuget-group-v3/`
- **Docker Group**: `localhost:9092` (HTTP) / `localhost:9093` (HTTPS)

## Configuration

### Environment Variables (.env)
```bash
# Required for Nexus setup
NEXUS_USER=admin
NEXUS_PASS=yourpassword

# Optional: Override Nexus server URL (default: localhost:8081)
NEXUS_URL=http://localhost:8081
NEXUS_REGISTRY=http://localhost:8081/repository/npm-group/
NEXUS_PUBLISH_REGISTRY=http://localhost:8081/repository/npm-hosted-releases/

# CORS Configuration (automatically configured by all methods)
NEXUS_CORS_ENABLED=true
NEXUS_CORS_ALLOW_CREDENTIALS=true
NEXUS_CORS_ALLOWED_ORIGINS=http://localhost:8080,http://127.0.0.1:8080,https://*.github.io,https://*.githubusercontent.com,https://*.s3.amazonaws.com,https://*.s3-website.*.amazonaws.com,http://*.s3-website.*.amazonaws.com,https://cdn.jsdelivr.net,https://unpkg.com,*
NEXUS_CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,HEAD,OPTIONS
NEXUS_CORS_ALLOWED_HEADERS=*
NEXUS_CORS_EXPOSED_HEADERS=*

# CORS Proxy Configuration (Community Edition)
NEXUS_CORS_PROXY_PORT=8082
NEXUS_CORS_PROXY_ENABLED=true
NEXUS_CORS_PROXY_AUTO_START=true
```

### Terraform Variables (terraform.tfvars)
```hcl
# Basic configuration
nexus_user = "admin"
nexus_pass = "yourpassword"
nexus_url = "http://localhost:8081"

# CORS configuration
cors_enabled = true
cors_allow_credentials = true
cors_allowed_origins = "http://localhost:8080,https://*.github.io,*"
cors_allowed_methods = "GET,POST,PUT,DELETE,HEAD,OPTIONS"
cors_allowed_headers = "*"
cors_exposed_headers = "*"
```



### Configuration Priority

All automation methods follow this configuration priority:
1. **.env file** (highest priority)
2. **Environment variables** (fallback)
3. **Configuration files** (terraform.tfvars, etc.)
4. **Default values** (lowest priority)

## CORS Configuration

### ⚠️ Nexus Community Edition Limitations

**CORS API is NOT available in Nexus Community Edition** (only in Nexus Pro). The setup scripts will detect this and provide alternative solutions:

```bash
# When running setup scripts on Community Edition:
./setup-nexus.sh cors-only
# Output:
# ⚠️ CORS API not available (Nexus Community Edition)
# 📝 CORS Configuration Options:
#    1. Use browser extension (CORS Unblock, CORS Everywhere)
#    2. Configure reverse proxy (nginx/Apache) with CORS headers
#    3. Upgrade to Nexus Pro for built-in CORS support
#    4. Use --disable-web-security flag in Chrome for development
```

### 🚀 Automatic CORS Proxy (Community Edition)

**All automation methods automatically detect Community Edition and start a CORS proxy:**

```bash
# When running any setup method on Community Edition:
./setup-nexus.sh
# Output:
# ⚠️ CORS API not available (Nexus Community Edition)
# 🔧 Starting CORS proxy for Community Edition...
# 📦 Installing dependencies...
# 🚀 Starting CORS proxy on port 8082...
# 🧪 Testing CORS headers...
# ✅ CORS headers verified: Access-Control-Allow-Origin: *
# 🌐 CORS-enabled URLs (for browser access):
#   - NPM: http://localhost:8082/repository/npm-group/
```

**Features:**
- ✅ **Auto-detection** of Nexus Community vs Pro Edition
- ✅ **Node.js CORS proxy** automatically installed and started
- ✅ **Integrated testing** verifies CORS functionality
- ✅ **Configurable port** (default: 8082)
- ✅ **Cross-platform** support (Linux, macOS, Windows)

### ✅ Unified CORS Configuration (All Editions)

All 4 automation methods provide **unified CORS configuration**:

- **Shell Script** (`setup-nexus.sh`) - Auto-detects edition, starts proxy if needed
- **Windows Batch** (`setup-nexus.bat`) - Auto-detects edition, starts proxy if needed  
- **Terraform** (all `.tf` files) - Includes proxy setup and testing
- **Ansible** (`nexus-setup.yml`) - Comprehensive proxy setup with testing

**Nexus Pro**: Uses native CORS API  
**Nexus Community**: Uses automatic CORS proxy on port 8082

### 🎯 CORS-Only Setup (Nexus Pro)
Configure CORS without creating repositories:

```bash
# Shell/Batch scripts with cors-only flag
./setup-nexus.sh cors-only
setup-nexus.bat cors-only

# Terraform CORS-only (target specific resource)
terraform apply -target=null_resource.nexus_cors_config --auto-approve

# Ansible CORS-only playbook
ansible-playbook configure-cors.yml
```

### 🔧 Benefits (Nexus Pro)
- **Single Source of Truth**: All CORS settings in `.env` file
- **Consistent Behavior**: Same CORS configuration across all methods
- **Easy Customization**: Change settings once, applies everywhere
- **Microfrontend Ready**: Supports Local, NPM, Nexus, GitHub, AWS modes

## Testing

### Comprehensive Test Suite

Test all automation methods with unified CORS configuration:

```bash
# Linux/macOS/Git Bash
./test-all-methods.sh

# Windows
test-all-methods.bat
```

**Test Coverage:**
- Nexus connectivity verification
- Shell/Batch script method testing
- Terraform configuration validation
- Ansible playbook dry-run
- CORS configuration verification
- Environment variables validation

### Manual Testing

```bash
# Test individual methods
./setup-nexus.sh cors-only          # Shell CORS-only
setup-nexus.bat cors-only            # Batch CORS-only
terraform plan                       # Terraform validation
ansible-playbook configure-cors.yml  # Ansible CORS-only

# Verify CORS configuration
curl -u admin:yourpassword http://localhost:8081/service/rest/v1/security/cors
```

## Complete Workflow

### 1. Initial Setup
```bash
# Configure environment
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env

# Test all methods
./test-all-methods.sh
```

### 2. Choose Your Method
```bash
# Method 1: Shell Script (recommended for quick setup)
./setup-nexus.sh

# Method 2: Terraform (recommended for infrastructure as code)
terraform init && terraform apply

# Method 3: Ansible (recommended for configuration management)
ansible-playbook nexus-setup.yml

# Method 4: CORS-only (for existing Nexus instances)
./setup-nexus.sh cors-only
```

### 3. Verification
```bash
# Verify repositories
curl -u admin:yourpassword http://localhost:8081/service/rest/v1/repositories

# Test NPM registry
npm config set registry http://localhost:8081/repository/npm-group/
npm ping
```

### Complete Usage Guide

#### Method 1: Shell Script (Linux/macOS/Git Bash)
```bash
# Basic setup
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env
./setup-nexus.sh



# Custom Nexus URL
echo "NEXUS_URL=http://nexus.company.com:8081" >> .env
./setup-nexus.sh
```

#### Method 2: Windows Batch
```cmd
# Basic setup
echo NEXUS_USER=admin > .env
echo NEXUS_PASS=yourpassword >> .env
setup-nexus.bat



# With environment variables
set NEXUS_USER=admin
set NEXUS_PASS=yourpassword
setup-nexus.bat
```

#### Method 3: Terraform Infrastructure as Code
```bash
# Option A: Using .env file (recommended)
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env
echo "NEXUS_URL=http://localhost:8081" >> .env
terraform init
terraform plan
terraform apply

# Option B: Using terraform.tfvars
cat > terraform.tfvars << EOF
nexus_user = "admin"
nexus_pass = "yourpassword"
nexus_url = "http://localhost:8081"
EOF
terraform init && terraform apply

# Option C: Using environment variables
export TF_VAR_nexus_user="admin"
export TF_VAR_nexus_pass="yourpassword"
terraform init && terraform apply

# Option D: Command line variables
terraform apply -var="nexus_user=admin" -var="nexus_pass=yourpassword"

# Destroy infrastructure
terraform destroy
```

#### Method 4: Ansible Playbook
```bash
# Using .env file
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env
ansible-playbook nexus-setup.yml

# Using environment variables
export NEXUS_USER=admin
export NEXUS_PASS=yourpassword
ansible-playbook nexus-setup.yml

# Using Ansible variables
ansible-playbook nexus-setup.yml -e nexus_user=admin -e nexus_pass=yourpassword


```



## Docker Port Configuration

Docker repositories require dedicated ports:
- **9072** - Docker proxy HTTP
- **9082** - Docker hosted HTTP  
- **9083** - Docker hosted HTTPS
- **9092** - Docker group HTTP
- **9093** - Docker group HTTPS

## Usage Examples

### Maven Configuration
```xml
<repositories>
  <repository>
    <id>nexus</id>
    <url>http://localhost:8081/repository/maven-group/</url>
  </repository>
</repositories>
```

### NPM Configuration
```bash
npm config set registry http://localhost:8081/repository/npm-group/
```

### Docker Configuration
```bash
# Login to Nexus Docker registry
docker login localhost:9092

# Pull from proxy
docker pull localhost:9092/nginx:latest

# Push to hosted
docker tag myimage:latest localhost:9092/myimage:latest
docker push localhost:9092/myimage:latest
```





## Troubleshooting

### Authentication Issues
- Verify Nexus is running: `curl http://localhost:8081`
- Check credentials in `.env` file or environment variables
- Test authentication: `curl -u admin:yourpassword http://localhost:8081/service/rest/v1/repositories`
- Ensure admin user has repository creation permissions

### Configuration Issues
- **Terraform**: Check `terraform plan` output for variable values
- **Ansible**: Review configuration display task output
- **Shell/Batch**: Check debug output for loaded configuration
- Verify .env file format (no spaces around `=`)

### .env File Format
```bash
# Correct format
NEXUS_USER=admin
NEXUS_PASS=yourpassword

# Incorrect format (spaces around =)
NEXUS_USER = admin
NEXUS_PASS = yourpassword
```

### Port Conflicts
- Docker repositories require unique ports (9072, 9082, 9083, 9092, 9093)
- Verify ports are not in use: `netstat -an | grep :9072`

### Repository Creation Failures
- Check Nexus logs: `docker logs nexus` (if running in Docker)
- Verify blob store "default" exists
- Ensure sufficient disk space

### Terraform Issues
- **Duplicate resource errors**: Ensure no conflicting `.tf` files in directory (remove any `configure-cors.tf` file)
- **Provider initialization**: Run `terraform init` after configuration changes
- **State conflicts**: Use `terraform refresh` to sync state with actual resources
- **Variable conflicts**: Check for duplicate variable declarations across files
- **Clean restart**: If errors persist, delete `.terraform/` directory and run `terraform init` again



## Cleanup

### Terraform
```bash
terraform destroy
```

### Manual Cleanup
```bash
# Via API
curl -u admin:yourpassword -X DELETE http://localhost:8081/service/rest/v1/repositories/npm-group

# Via Web UI
# Access http://localhost:8081 and delete repositories manually
```

## Unified CORS Configuration

### ✅ All Methods Use Same Configuration

All 4 automation methods now use **unified CORS configuration** from your `.env` file:

- **Shell Script** (`setup-nexus.sh`) 
- **Windows Batch** (`setup-nexus.bat`)
- **Terraform** (all `.tf` files)
- **Ansible** (`nexus-setup.yml` + `configure-cors.yml`)

### 🔧 Your Current Configuration
```bash
NEXUS_CORS_ENABLED=true
NEXUS_CORS_ALLOW_CREDENTIALS=true
NEXUS_CORS_ALLOWED_ORIGINS=http://localhost:8080,http://127.0.0.1:8080,https://*.github.io,https://*.githubusercontent.com,https://*.s3.amazonaws.com,https://*.s3-website.*.amazonaws.com,http://*.s3-website.*.amazonaws.com,https://cdn.jsdelivr.net,https://unpkg.com,*
NEXUS_CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,HEAD,OPTIONS
NEXUS_CORS_ALLOWED_HEADERS=*
NEXUS_CORS_EXPOSED_HEADERS=*
```

### 🎯 Benefits
- **Single Source of Truth**: All CORS settings in `.env` file
- **Consistent Behavior**: Same CORS configuration across all methods
- **Easy Customization**: Change settings once, applies everywhere
- **Priority Order**: `.env file -> environment variables -> defaults`

## Testing

### Comprehensive Test Suite

Test all automation methods with unified CORS configuration:

```bash
# Linux/macOS/Git Bash
./test-all-methods.sh

# Windows
test-all-methods.bat
```

**Test Coverage:**
- Nexus connectivity verification
- Shell/Batch script method testing
- Terraform configuration validation
- Ansible playbook dry-run
- CORS configuration verification
- Environment variables validation

### Manual Testing

```bash
# Test individual methods
./setup-nexus.sh cors-only          # Shell CORS-only
setup-nexus.bat cors-only            # Batch CORS-only
terraform plan                       # Terraform validation
ansible-playbook configure-cors.yml  # Ansible CORS-only

# Verify CORS configuration
curl -u admin:yourpassword http://localhost:8081/service/rest/v1/security/cors
```

## Complete Workflow

### 1. Initial Setup
```bash
# Configure environment
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env

# Test all methods
./test-all-methods.sh
```

### 2. Choose Your Method
```bash
# Method 1: Shell Script (recommended for quick setup)
./setup-nexus.sh

# Method 2: Terraform (recommended for infrastructure as code)
terraform init && terraform apply

# Method 3: Ansible (recommended for configuration management)
ansible-playbook nexus-setup.yml

# Method 4: CORS-only (for existing Nexus instances)
./setup-nexus.sh cors-only
```

### 3. Verification
```bash
# Verify repositories
curl -u admin:yourpassword http://localhost:8081/service/rest/v1/repositories

# Test NPM registry
npm config set registry http://localhost:8081/repository/npm-group/
npm ping
```bat
```

**Test Coverage:**
- Nexus connectivity verification
- Shell/Batch script method testing
- Terraform configuration validation
- Ansible playbook dry-run
- CORS configuration verification
- Environment variables validation

### Manual Testing

```bash
# Test individual methods
./setup-nexus.sh cors-only          # Shell CORS-only
setup-nexus.bat cors-only            # Batch CORS-only
terraform plan                       # Terraform validation
ansible-playbook configure-cors.yml  # Ansible CORS-only

# Verify CORS configuration
curl -u admin:yourpassword http://localhost:8081/service/rest/v1/security/cors
```

## Complete Workflow

### 1. Initial Setup
```bash
# Configure environment
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=yourpassword" >> .env

# Test all methods
./test-all-methods.sh
```

### 2. Choose Your Method
```bash
# Method 1: Shell Script (recommended for quick setup)
./setup-nexus.sh

# Method 2: Terraform (recommended for infrastructure as code)
terraform init && terraform apply

# Method 3: Ansible (recommended for configuration management)
ansible-playbook nexus-setup.yml

# Method 4: CORS-only (for existing Nexus instances)
./configure-cors.sh
```

### 3. Verification
```bash
# Verify repositories
curl -u admin:yourpassword http://localhost:8081/service/rest/v1/repositories

# Test NPM registry
npm config set registry http://localhost:8081/repository/npm-group/
npm ping
```

## License

MIT License