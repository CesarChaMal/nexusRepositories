# Outputs
output "nexus_repositories" {
  description = "Created Nexus repositories (configuration from .env file with fallback to environment variables)"
  value = {
    nexus_url      = local.nexus_url
    nexus_user     = local.nexus_user
    maven_group    = "${local.nexus_url}/repository/${nexus_repository_maven_group.maven_group.name}/"
    npm_group      = "${local.nexus_url}/repository/${nexus_repository_npm_group.npm_group.name}/"
    nuget_group_v3 = "${local.nexus_url}/repository/${nexus_repository_nuget_group.nuget_group_v3.name}/"
    docker_group   = "localhost:9092"
    cors_enabled   = "All microfrontend modes: Local, NPM, Nexus, GitHub, AWS"
  }
}