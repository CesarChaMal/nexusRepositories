# Terraform configuration for Nexus Repository Setup
# Creates Maven, NPM, NuGet, and Docker repositories

# Maven Repositories
resource "nexus_repository_maven_proxy" "maven_proxy" {
  name   = "maven-proxy"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
  }

  proxy {
    remote_url = "https://repo1.maven.org/maven2"
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }

  maven {
    version_policy = "MIXED"
    layout_policy  = "STRICT"
  }
}

resource "nexus_repository_maven_hosted" "maven_hosted_releases" {
  name   = "maven-hosted-releases"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }

  maven {
    version_policy = "RELEASE"
    layout_policy  = "STRICT"
  }
}

resource "nexus_repository_maven_hosted" "maven_hosted_snapshots" {
  name   = "maven-hosted-snapshots"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }

  maven {
    version_policy = "SNAPSHOT"
    layout_policy  = "STRICT"
  }
}

resource "nexus_repository_maven_group" "maven_group" {
  name   = "maven-group"
  online = true

  storage {
    blob_store_name = "default"
  }

  group {
    member_names = [
      nexus_repository_maven_proxy.maven_proxy.name,
      nexus_repository_maven_hosted.maven_hosted_releases.name,
      nexus_repository_maven_hosted.maven_hosted_snapshots.name
    ]
  }
}

# NPM Repositories
resource "nexus_repository_npm_proxy" "npm_proxy" {
  name   = "npm-proxy"
  online = true

  storage {
    blob_store_name = "default"
  }

  proxy {
    remote_url = "https://registry.npmjs.org"
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }
}

resource "nexus_repository_npm_hosted" "npm_hosted_releases" {
  name   = "npm-hosted-releases"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }
}

resource "nexus_repository_npm_hosted" "npm_hosted_snapshots" {
  name   = "npm-hosted-snapshots"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }
}

resource "nexus_repository_npm_group" "npm_group" {
  name   = "npm-group"
  online = true

  storage {
    blob_store_name = "default"
  }

  group {
    member_names = [
      nexus_repository_npm_proxy.npm_proxy.name,
      nexus_repository_npm_hosted.npm_hosted_releases.name,
      nexus_repository_npm_hosted.npm_hosted_snapshots.name
    ]
  }
}

# NuGet Repositories
resource "nexus_repository_nuget_proxy" "nuget_proxy_v3" {
  name                     = "nuget-proxy-v3"
  online                   = true
  nuget_version            = "V3"
  query_cache_item_max_age = 3600

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
  }

  proxy {
    remote_url = "https://api.nuget.org/v3/index.json"
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }
}

resource "nexus_repository_nuget_hosted" "nuget_hosted_releases" {
  name   = "nuget-hosted-releases"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }
}

resource "nexus_repository_nuget_hosted" "nuget_hosted_snapshots" {
  name   = "nuget-hosted-snapshots"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }
}

resource "nexus_repository_nuget_group" "nuget_group_v3" {
  name   = "nuget-group-v3"
  online = true

  storage {
    blob_store_name = "default"
  }

  group {
    member_names = [
      nexus_repository_nuget_proxy.nuget_proxy_v3.name,
      nexus_repository_nuget_hosted.nuget_hosted_releases.name,
      nexus_repository_nuget_hosted.nuget_hosted_snapshots.name
    ]
  }
}

# Docker Repositories
resource "nexus_repository_docker_proxy" "docker_proxy" {
  name   = "docker-proxy"
  online = true

  storage {
    blob_store_name = "default"
  }

  proxy {
    remote_url = "https://registry-1.docker.io"
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }

  docker {
    http_port         = 9072
    force_basic_auth  = true
    v1_enabled        = false
  }

  docker_proxy {
    index_type = "HUB"
    index_url  = "https://index.docker.io"
  }
}

resource "nexus_repository_docker_hosted" "docker_hosted" {
  name   = "docker-hosted"
  online = true

  storage {
    blob_store_name                = "default"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }

  docker {
    http_port        = 9082
    https_port       = 9083
    force_basic_auth = true
    v1_enabled       = false
  }
}

resource "nexus_repository_docker_group" "docker_group" {
  name   = "docker-group"
  online = true

  storage {
    blob_store_name = "default"
  }

  group {
    member_names = [
      nexus_repository_docker_proxy.docker_proxy.name,
      nexus_repository_docker_hosted.docker_hosted.name
    ]
  }

  docker {
    http_port        = 9092
    https_port       = 9093
    force_basic_auth = true
    v1_enabled       = false
  }
}

# Configure CORS for browser access (all microfrontend modes)
resource "null_resource" "nexus_cors_config" {
  depends_on = [
    nexus_repository_npm_group.npm_group,
    nexus_repository_maven_group.maven_group,
    nexus_repository_nuget_group.nuget_group_v3,
    nexus_repository_docker_group.docker_group
  ]

  provisioner "local-exec" {
    command = <<-EOT
      bash ./setup-nexus.sh cors-only
    EOT
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      timeout /t 3 /nobreak >nul 2>&1 || sleep 3 || echo "Waiting..."
      bash ./test-cors.sh || echo "CORS test completed with warnings"
    EOT
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      pkill -f cors-proxy.js || true
      rm -f cors-proxy.pid cors-proxy.log || true
    EOT
  }
}

