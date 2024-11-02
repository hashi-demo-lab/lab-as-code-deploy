resource "helm_release" "ingress_nginx" {
  name       = var.helm_release_name
  repository = var.helm_repository
  chart      = var.helm_chart_name
  namespace  = var.ingress_namespace  # Set dynamically from input variable

  # Configuration for the NGINX controller
  set {
    name  = "controller.watchNamespace"
    value = var.controller_watch_namespace
  }

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = var.enable_ssl_passthrough ? "true" : "false"
  }
}
