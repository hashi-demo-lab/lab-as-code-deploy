# Map of namespaces and their corresponding team labels
locals {
  namespaces = {
    nginx      = "nginx"
    vault      = "vault"
    prometheus = "prometheus"
    ldap       = "ldap"
    grafana    = "grafana"
    mysql      = "mysql"
    neo4j      = "neo4j"
    gitlab     = "gitlab"
  }
}

# Creating Kubernetes Namespaces dynamically using for_each
resource "kubernetes_namespace" "namespace" {
  for_each = local.namespaces

  metadata {
    name = each.key

    annotations = {
      name = each.key
    }

    labels = {
      team = each.value
    }
  }
}