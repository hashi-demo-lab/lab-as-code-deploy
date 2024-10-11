terraform {
  cloud {
    organization = "lab-as-code"
    workspaces {
      project = "deployments"
      name    = "ingress-nginx"
    }
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config_path
    config_context = var.kube_config_context
  }
}