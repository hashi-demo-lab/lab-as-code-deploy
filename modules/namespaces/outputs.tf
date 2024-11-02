# modules/namespaces/outputs.tf

output "nginx_namespace" {
  description = "The namespace for NGINX ingress"
  value       = kubernetes_namespace.namespace["nginx"].metadata[0].name
}

output "vault_namespace" {
  description = "The namespace for Vault"
  value       = kubernetes_namespace.namespace["vault"].metadata[0].name
}

output "prometheus_namespace" {
  description = "The namespace for Prometheus"
  value       = kubernetes_namespace.namespace["prometheus"].metadata[0].name
}

output "ldap_namespace" {
  description = "The namespace for LDAP"
  value       = kubernetes_namespace.namespace["ldap"].metadata[0].name
}

output "grafana_namespace" {
  description = "The namespace for Grafana"
  value       = kubernetes_namespace.namespace["grafana"].metadata[0].name
}

output "mysql_namespace" {
  description = "The namespace for MySQL"
  value       = kubernetes_namespace.namespace["mysql"].metadata[0].name
}
