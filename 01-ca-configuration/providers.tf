terraform {
  cloud {
    organization = "lab-as-code"
    workspaces {
      project = "deployments"
      name    = "ca-configuration"
    }
  }

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
}