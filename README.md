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
├── nexus-setup.tf          # Terraform configuration
├── nexus-setup.yml         # Ansible playbook
├── terraform.tfvars        # Terraform variables
├── versions.tf             # Terraform version requirements
└── .env                    # Environment variables
```

## Quick Start

### Method 1: Shell Script (Linux/macOS/Git Bash)
```bash
# Configure credentials in .env file
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=your-password" >> .env

# Run setup
./setup-nexus.sh
```

### Method 2: Windows Batch
```cmd
# Configure credentials in .env file
echo NEXUS_USER=admin > .env
echo NEXUS_PASS=your-password >> .env

# Run setup
setup-nexus.bat
```

### Method 3: Terraform
```bash
# Initialize Terraform
terraform init

# Configure variables
echo 'nexus_user = "admin"' > terraform.tfvars
echo 'nexus_pass = "your-password"' >> terraform.tfvars

# Apply configuration
terraform plan
terraform apply
```

### Method 4: Ansible
```bash
# Configure credentials in .env file
echo "NEXUS_USER=admin" > .env
echo "NEXUS_PASS=your-password" >> .env

# Run playbook
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
NEXUS_USER=admin
NEXUS_PASS=your-password
```

### Terraform Variables (terraform.tfvars)
```hcl
nexus_user = "admin"
nexus_pass = "your-password"
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
- Check credentials in `.env` or `terraform.tfvars`
- Ensure admin user has repository creation permissions

### Port Conflicts
- Docker repositories require unique ports (9072, 9082, 9083, 9092, 9093)
- Verify ports are not in use: `netstat -an | grep :9072`

### Repository Creation Failures
- Check Nexus logs: `docker logs nexus` (if running in Docker)
- Verify blob store "default" exists
- Ensure sufficient disk space

## Cleanup

### Terraform
```bash
terraform destroy
```

### Manual Cleanup
Access Nexus web UI at `http://localhost:8081` and delete repositories manually.

## License

MIT License