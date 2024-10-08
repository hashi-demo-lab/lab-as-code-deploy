resource "kubernetes_config_map_v1" "prometheus_scrape_config" {
  metadata {
    name      = "prometheus-scrape-config"
    namespace = kubernetes_namespace.prometheus.id
  }

  data = {
    "prometheus.yml" = local.prometheus_configmap
  }
}

resource "kubernetes_secret_v1" "prometheus-ca-secret" {
  metadata {
    name      = "prometheus-ca-secret"
    namespace = kubernetes_namespace.prometheus.id
  }
  data = {
    "ca.crt" = local.ca_cert_pem
  }
  type = "kubernetes.io/opaque"
}

resource "kubernetes_secret_v1" "prometheus-token-secret" {
  metadata {
    name      = "prometheus-token-secret"
    namespace = kubernetes_namespace.prometheus.id
  }
  data = {
    "token" = local.vault_root_token
  }
  type = "kubernetes.io/opaque"
}


resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_config_map_v1.prometheus_scrape_config,
    kubernetes_secret_v1.prometheus-ca-secret,
    kubernetes_secret_v1.prometheus-token-secret,
    helm_release.vault
  ]
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.prometheus.id
  version    = var.prometheus_helm_version

  values = [
    local.prometheus_helm # Reference your values.yaml
  ]
}
