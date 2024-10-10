# Helm release for Ingress NGINX Controller
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.namespace["nginx"].id

  # Setting values to configure the NGINX controller
  set {
    name  = "controller.watchNamespace" # Ensure it watches all namespaces
    value = ""                          # Empty value means no restriction (all namespaces)
  }

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough" # Enable SSL passthrough
    value = "true"
  }
}
