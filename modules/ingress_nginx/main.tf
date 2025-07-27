resource "helm_release" "ingress_nginx" {
  name       = var.helm_release_name
  chart      = "ingress-nginx/ingress-nginx"
  namespace  = var.ingress_namespace
  dependency_update = true

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = "true"
  }

  set {
    name  = "controller.image.repository"
    value = "registry.k8s.io/ingress-nginx/controller"
  }

  set {
    name  = "controller.image.tag"
    value = "v1.12.1"
  }
}