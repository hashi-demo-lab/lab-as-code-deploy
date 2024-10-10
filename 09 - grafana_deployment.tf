# ConfigMap for Grafana Datasources Configuration
resource "kubernetes_config_map_v1" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = kubernetes_namespace.namespace["grafana"].id
  }

  data = {
    "datasources.yaml" = local.grafana_configmap # Datasource configuration for Grafana
  }
}

# Secret for Grafana Vault Token (used for authentication with Vault)
resource "kubernetes_secret_v1" "grafana-token-secret" {
  metadata {
    name      = "grafana-token-secret"
    namespace = kubernetes_namespace.namespace["grafana"].id
  }

  data = {
    "token" = local.vault_root_token # Vault root token used by Grafana
  }

  type = "Opaque" # Secret type for non-TLS secrets
}

# Helm Release for Grafana
resource "helm_release" "grafana" {
  depends_on = [
    kubernetes_config_map_v1.grafana_config,   # Ensure ConfigMap is created first
    kubernetes_secret_v1.grafana-token-secret, # Ensure Token secret is created first
    helm_release.vault                         # Ensure Vault is deployed before Grafana
  ]

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.namespace["grafana"].id
  version    = var.grafana_helm_version

  values = [
    local.grafana_helm # Reference to Grafana Helm chart values from local file
  ]
  
  lifecycle {
    ignore_changes = [
      metadata,  # Ignores all changes within the metadata block
    ]
  }
}
