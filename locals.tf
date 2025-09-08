# Configuration priority: .env file -> environment variables -> terraform variables -> defaults
locals {
  env_vars = {
    for line in split("\n", try(file(".env"), try(file("../.env"), ""))) :
    split("=", line)[0] => split("=", line)[1]
    if length(split("=", line)) == 2 && !startswith(line, "#")
  }
  
  nexus_user = coalesce(
    lookup(local.env_vars, "NEXUS_USER", null),
    var.nexus_user,
    "admin"
  )
  
  nexus_pass = coalesce(
    lookup(local.env_vars, "NEXUS_PASS", null),
    var.nexus_pass,
    "admin"
  )
  
  nexus_url = coalesce(
    lookup(local.env_vars, "NEXUS_URL", null),
    var.nexus_url,
    "http://localhost:8081"
  )
  
  # CORS configuration with priority: .env -> environment -> terraform vars -> defaults
  cors_enabled = coalesce(
    lookup(local.env_vars, "NEXUS_CORS_ENABLED", null) == "true" ? true : null,
    var.cors_enabled,
    true
  )
  
  cors_allow_credentials = coalesce(
    lookup(local.env_vars, "NEXUS_CORS_ALLOW_CREDENTIALS", null) == "true" ? true : null,
    var.cors_allow_credentials,
    true
  )
  
  cors_allowed_origins = split(",", coalesce(
    lookup(local.env_vars, "NEXUS_CORS_ALLOWED_ORIGINS", null),
    var.cors_allowed_origins,
    "http://localhost:8080,http://127.0.0.1:8080,https://*.github.io,https://*.githubusercontent.com,https://*.s3.amazonaws.com,https://*.s3-website-*.amazonaws.com,http://*.s3-website-*.amazonaws.com,https://cdn.jsdelivr.net,https://unpkg.com,*"
  ))
  
  cors_allowed_methods = split(",", coalesce(
    lookup(local.env_vars, "NEXUS_CORS_ALLOWED_METHODS", null),
    var.cors_allowed_methods,
    "GET,POST,PUT,DELETE,HEAD,OPTIONS"
  ))
  
  cors_allowed_headers = split(",", coalesce(
    lookup(local.env_vars, "NEXUS_CORS_ALLOWED_HEADERS", null),
    var.cors_allowed_headers,
    "*"
  ))
  
  cors_exposed_headers = split(",", coalesce(
    lookup(local.env_vars, "NEXUS_CORS_EXPOSED_HEADERS", null),
    var.cors_exposed_headers,
    "*"
  ))
  
  # CORS Proxy configuration (Community Edition)
  cors_proxy_port = coalesce(
    lookup(local.env_vars, "NEXUS_CORS_PROXY_PORT", null) != null ? tonumber(lookup(local.env_vars, "NEXUS_CORS_PROXY_PORT", null)) : null,
    var.cors_proxy_port,
    8082
  )
  
  cors_proxy_enabled = coalesce(
    lookup(local.env_vars, "NEXUS_CORS_PROXY_ENABLED", null) == "true" ? true : null,
    var.cors_proxy_enabled,
    true
  )
  
  cors_proxy_auto_start = coalesce(
    lookup(local.env_vars, "NEXUS_CORS_PROXY_AUTO_START", null) == "true" ? true : null,
    var.cors_proxy_auto_start,
    true
  )
}