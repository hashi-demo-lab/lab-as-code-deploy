resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.nginx.id

  set {
    name  = "controller.watchNamespace" # Ensure it watches all namespaces
    value = ""
  }

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = ""
  }
}