resource "kubernetes_config_map_v1" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = kubernetes_namespace.grafana.id
  }

  data = {
    "datasources.yaml" = local.grafana_configmap
  }
}

resource "kubernetes_secret_v1" "grafana-token-secret" {
  metadata {
    name      = "grafana-token-secret"
    namespace = kubernetes_namespace.grafana.id
  }
  data = {
    "token" = local.vault_root_token
  }
  type = "kubernetes.io/opaque"
}


resource "helm_release" "grafana" {
  depends_on = [
    kubernetes_config_map_v1.grafana_config,
    kubernetes_secret_v1.grafana-token-secret,
    helm_release.vault
  ]

  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.grafana.id
  version    = var.grafana_helm_version

  values = [
    local.grafana_helm
  ]
}
