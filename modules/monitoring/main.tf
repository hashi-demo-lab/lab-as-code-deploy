# modules/monitoring/main.tf

# ConfigMap for Prometheus scrape configuration
resource "kubernetes_config_map_v1" "prometheus_scrape_config" {
  metadata {
    name      = "prometheus-scrape-config"
    namespace = var.prometheus_namespace
  }

  data = {
    "prometheus.yml" = var.prometheus_scrape_config
  }
}

# Secret for Prometheus CA certificate
resource "kubernetes_secret_v1" "prometheus_ca_secret" {
  metadata {
    name      = "prometheus-ca-secret"
    namespace = var.prometheus_namespace
  }

  data = {
    "ca.crt" = var.ca_cert_pem
  }

  type = "Opaque"
}

# Secret for Prometheus Vault token
resource "kubernetes_secret_v1" "prometheus_token_secret" {
  metadata {
    name      = "prometheus-token-secret"
    namespace = var.prometheus_namespace
  }

  data = {
    "token" = var.vault_root_token
  }

  type = "Opaque"
}

# Helm release for Prometheus
resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_config_map_v1.prometheus_scrape_config,
    kubernetes_secret_v1.prometheus_ca_secret,
    kubernetes_secret_v1.prometheus_token_secret,
  ]

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = var.prometheus_namespace
  version    = var.prometheus_helm_version

  values = [
    var.prometheus_helm_values
  ]
}

# ConfigMap for Grafana datasource configuration
resource "kubernetes_config_map_v1" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = var.grafana_namespace
  }

  data = {
    "datasources.yaml" = var.grafana_configmap
  }
}

# Secret for Grafana Vault token
resource "kubernetes_secret_v1" "grafana_token_secret" {
  metadata {
    name      = "grafana-token-secret"
    namespace = var.grafana_namespace
  }

  data = {
    "token" = var.vault_root_token
  }

  type = "Opaque"
}

# Helm release for Grafana
resource "helm_release" "grafana" {
  depends_on = [
    kubernetes_config_map_v1.grafana_config,
    kubernetes_secret_v1.grafana_token_secret,
  ]

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = var.grafana_namespace
  version    = var.grafana_helm_version

  values = [
    var.grafana_helm_values
  ]
}
