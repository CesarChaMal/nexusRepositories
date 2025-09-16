variable "nexus_user" {
  description = "Nexus username (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "admin"
}

variable "nexus_pass" {
  description = "Nexus password (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "nexus_url" {
  description = "Nexus URL (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "http://localhost:8081"
}

variable "cors_enabled" {
  description = "Enable CORS (priority: .env -> environment -> terraform vars)"
  type        = bool
  default     = true
}

variable "cors_allow_credentials" {
  description = "CORS allow credentials (priority: .env -> environment -> terraform vars)"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins as comma-separated string (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "http://localhost:8080,http://127.0.0.1:8080,https://*.github.io,https://*.githubusercontent.com,https://*.s3.amazonaws.com,https://*.s3-website.*.amazonaws.com,http://*.s3-website.*.amazonaws.com,https://cdn.jsdelivr.net,https://unpkg.com,*"
}

variable "cors_allowed_methods" {
  description = "CORS allowed methods as comma-separated string (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "GET,POST,PUT,DELETE,HEAD,OPTIONS"
}

variable "cors_allowed_headers" {
  description = "CORS allowed headers as comma-separated string (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "*"
}

variable "cors_exposed_headers" {
  description = "CORS exposed headers as comma-separated string (priority: .env -> environment -> terraform vars)"
  type        = string
  default     = "*"
}

variable "cors_proxy_port" {
  description = "CORS proxy port for Community Edition (priority: .env -> environment -> terraform vars)"
  type        = number
  default     = 8082
}

variable "cors_proxy_enabled" {
  description = "Enable CORS proxy for Community Edition (priority: .env -> environment -> terraform vars)"
  type        = bool
  default     = true
}

variable "cors_proxy_auto_start" {
  description = "Auto-start CORS proxy for Community Edition (priority: .env -> environment -> terraform vars)"
  type        = bool
  default     = true
}
