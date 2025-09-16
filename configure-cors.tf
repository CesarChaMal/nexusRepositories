# Terraform configuration for Nexus CORS only
# Configures CORS without creating repositories

terraform {
  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = "~> 1.21"
    }
  }
}

provider "nexus" {
  url      = "http://localhost:8081"
  username = var.nexus_user
  password = var.nexus_pass
}

variable "nexus_user" {
  description = "Nexus username"
  type        = string
  default     = "admin"
}

variable "nexus_pass" {
  description = "Nexus password"
  type        = string
  default     = "admin"
  sensitive   = true
}

# Configure CORS for browser access (all microfrontend modes)
resource "null_resource" "nexus_cors_config" {
  provisioner "local-exec" {
    command = <<-EOT
      curl -u ${var.nexus_user}:${var.nexus_pass} -X PUT "http://localhost:8081/service/rest/v1/security/cors" \
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
    EOT
  }
}

# Output
output "cors_configuration" {
  description = "CORS configuration status"
  value = {
    enabled = "All microfrontend modes: Local, NPM, Nexus, GitHub, AWS"
    nexus_url = "http://localhost:8081"
    allowed_origins = [
      "http://localhost:8080 (Local development)",
      "https://*.github.io (GitHub Pages)",
      "https://*.s3.amazonaws.com (AWS S3)",
      "https://cdn.jsdelivr.net (NPM CDN)",
      "* (All other origins)"
    ]
  }
  depends_on = [null_resource.nexus_cors_config]
}