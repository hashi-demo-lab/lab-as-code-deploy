terraform {
  cloud {
    organization = "lab-as-code"
    workspaces {
      project = "deployments"
      name    = "lab-as-code-deploy"
    }
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_config_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config_path
    config_context = var.kube_config_context
  }
}

provider "vault" {
  token = local.vault_root_token
}