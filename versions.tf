terraform {
  required_version = ">= 1.3.9"
  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = "~> 1.21"
    }
  }
}

provider "nexus" {
  url      = local.nexus_url
  username = local.nexus_user
  password = local.nexus_pass
}
