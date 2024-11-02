# ConfigMap for Prometheus scrape configuration
resource "kubernetes_config_map_v1" "prometheus_scrape_config" {
  metadata {
    name      = "prometheus-scrape-config"
    namespace = kubernetes_namespace.namespace["prometheus"].id
  }

  data = {
    "prometheus.yml" = local.prometheus_configmap # Scrape config content from local file
  }
}

# Secret for Prometheus CA certificate (used for secure communication)
resource "kubernetes_secret_v1" "prometheus-ca-secret" {
  metadata {
    name      = "prometheus-ca-secret"
    namespace = kubernetes_namespace.namespace["prometheus"].id
  }

  data = {
    "ca.crt" = local.ca_cert_pem # CA certificate loaded from local
  }

  type = "Opaque" # Correct secret type
}

# Secret for Prometheus Vault token (used for authentication)
resource "kubernetes_secret_v1" "prometheus-token-secret" {
  metadata {
    name      = "prometheus-token-secret"
    namespace = kubernetes_namespace.namespace["prometheus"].id
  }

  data = {
    "token" = local.vault_root_token # Root token loaded from local or Vault
  }

  type = "Opaque"
}

# Helm release for Prometheus
resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_config_map_v1.prometheus_scrape_config, # Ensure ConfigMap is created first
    kubernetes_secret_v1.prometheus-ca-secret,         # Ensure CA secret is created first
    kubernetes_secret_v1.prometheus-token-secret,      # Ensure Token secret is created first
    helm_release.vault                                 # Ensure Vault is deployed first
  ]

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.namespace["prometheus"].id
  version    = var.prometheus_helm_version

  values = [
    local.prometheus_helm # Prometheus Helm chart values from local file
  ]

  lifecycle {
    ignore_changes = [
      metadata,  # Ignores all changes within the metadata block
    ]
  }
}
