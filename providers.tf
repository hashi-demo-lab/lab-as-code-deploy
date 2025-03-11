terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
      version = "~> 4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
    onepassword = {
      source = "1Password/onepassword"
      version = "~> 2"
    }
  }
}

provider "tls" {
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

provider "onepassword" {
}